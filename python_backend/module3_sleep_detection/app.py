"""
Module 3 - Flask API Server for Sleep Detection
Exposes the ML model as REST API endpoints for smartwatch integration

Endpoints:
- POST /detect - Detect sleep state
- POST /batch-detect - Detect sleep state for multiple readings
- GET /health - Health check
- POST /train - Train or retrain model
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import sys
from datetime import datetime

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from sleep_detector import SleepDetector

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter/smartwatch requests

# Initialize detector
detector = SleepDetector()

# Try to load existing model, otherwise train new one
model_path = '../models/sleep_detection_model.pkl'
if os.path.exists(model_path):
    try:
        detector.load_model(model_path)
        print("Loaded existing sleep detection model")
    except Exception as e:
        print(f"Could not load model: {e}, training new model...")
        detector.train_model()
        detector.save_model()
else:
    print("Training new sleep detection model...")
    detector.train_model()
    detector.save_model()


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'Sleep Detection API',
        'timestamp': datetime.now().isoformat(),
        'model_loaded': detector.model is not None
    })


@app.route('/detect', methods=['POST'])
def detect_sleep():
    """
    Detect sleep state from smartwatch sensor data
    
    Expected JSON:
    {
        "heart_rate": 60,
        "movement_level": 2,
        "body_temperature": 36.5,
        "oxygen_saturation": 98,
        "time_of_day": 23
    }
    
    Returns:
    {
        "success": true,
        "state": "Yes|No",
        "is_sleeping": true|false,
        "confidence": "95.2%",
        "sleep_quality": "Deep Sleep|Light Sleep|Good|Awake",
        "vital_signs": {...},
        "alerts": [],
        "recommendation": "...",
        "timestamp": "2024-10-24T12:00:00"
    }
    """
    try:
        data = request.json
        
        # Validate required fields
        required_fields = ['heart_rate', 'movement_level', 'body_temperature', 'oxygen_saturation', 'time_of_day']
        if not all(field in data for field in required_fields):
            return jsonify({
                'success': False,
                'error': f'Missing required fields. Expected: {required_fields}'
            }), 400
        
        # Get prediction
        result = detector.detect_sleep_state(
            heart_rate=int(data['heart_rate']),
            movement_level=int(data['movement_level']),
            body_temperature=float(data['body_temperature']),
            oxygen_saturation=int(data['oxygen_saturation']),
            time_of_day=int(data['time_of_day'])
        )
        
        return jsonify({
            'success': True,
            'state': result['state'],
            'is_sleeping': result['is_sleeping'],
            'confidence': result['confidence'],
            'sleep_quality': result['sleep_quality'],
            'vital_signs': result['vital_signs'],
            'alerts': result['alerts'],
            'recommendation': result['recommendation'],
            'timestamp': datetime.now().isoformat()
        })
    
    except ValueError as e:
        return jsonify({
            'success': False,
            'error': f'Invalid input value: {str(e)}'
        }), 400
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/batch-detect', methods=['POST'])
def batch_detect_sleep():
    """
    Batch detect sleep state for multiple sensor readings
    Useful for processing multiple passengers or historical data
    
    Expected JSON:
    {
        "readings": [
            {
                "passenger_id": "P001",
                "heart_rate": 60,
                "movement_level": 2,
                "body_temperature": 36.5,
                "oxygen_saturation": 98,
                "time_of_day": 23
            },
            ...
        ]
    }
    """
    try:
        data = request.json
        readings = data.get('readings', [])
        
        if not readings:
            return jsonify({
                'success': False,
                'error': 'No sensor readings provided'
            }), 400
        
        predictions = []
        for reading in readings:
            result = detector.detect_sleep_state(
                heart_rate=int(reading['heart_rate']),
                movement_level=int(reading['movement_level']),
                body_temperature=float(reading['body_temperature']),
                oxygen_saturation=int(reading['oxygen_saturation']),
                time_of_day=int(reading['time_of_day'])
            )
            predictions.append({
                'passenger_id': reading.get('passenger_id', 'unknown'),
                **result
            })
        
        return jsonify({
            'success': True,
            'predictions': predictions,
            'total_readings': len(predictions),
            'timestamp': datetime.now().isoformat()
        })
    
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/alert-stats', methods=['POST'])
def get_alert_stats():
    """
    Get statistics about alerts from batch predictions
    
    Expected JSON:
    {
        "readings": [...]  (same as batch-detect)
    }
    """
    try:
        data = request.json
        readings = data.get('readings', [])
        
        if not readings:
            return jsonify({
                'success': False,
                'error': 'No sensor readings provided'
            }), 400
        
        predictions = detector.batch_detect(readings)
        
        # Calculate statistics
        sleeping_count = sum(1 for p in predictions if p['is_sleeping'])
        alert_count = sum(len(p['alerts']) for p in predictions)
        high_hr = sum(1 for p in predictions if p['vital_signs']['heart_rate'] > 100)
        low_oxygen = sum(1 for p in predictions if p['vital_signs']['oxygen_saturation'] < 95)
        
        return jsonify({
            'success': True,
            'statistics': {
                'total_passengers': len(predictions),
                'sleeping': sleeping_count,
                'awake': len(predictions) - sleeping_count,
                'total_alerts': alert_count,
                'high_heart_rate_count': high_hr,
                'low_oxygen_count': low_oxygen,
                'average_heart_rate': sum(p['vital_signs']['heart_rate'] for p in predictions) / len(predictions),
                'average_oxygen': sum(p['vital_signs']['oxygen_saturation'] for p in predictions) / len(predictions)
            },
            'timestamp': datetime.now().isoformat()
        })
    
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/train', methods=['POST'])
def train_model():
    """
    Retrain the model with existing data
    """
    try:
        print("Retraining sleep detection model...")
        detector.train_model()
        detector.save_model()
        
        return jsonify({
            'success': True,
            'message': 'Sleep detection model trained and saved successfully',
            'timestamp': datetime.now().isoformat()
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/info', methods=['GET'])
def get_info():
    """Get API information"""
    return jsonify({
        'name': 'Sleep Detection API',
        'version': '1.0.0',
        'description': 'ML-based sleep detection service for smartwatch integration',
        'endpoints': {
            'POST /detect': 'Detect sleep state from sensor data',
            'POST /batch-detect': 'Detect sleep state for multiple passengers',
            'POST /alert-stats': 'Get statistics about alerts',
            'POST /train': 'Retrain the model',
            'GET /health': 'Health check',
            'GET /info': 'API information'
        },
        'sensor_inputs': {
            'heart_rate': 'int (40-120 bpm)',
            'movement_level': 'int (0-15)',
            'body_temperature': 'float (°C)',
            'oxygen_saturation': 'int (90-100%)',
            'time_of_day': 'int (0-23 hours)'
        },
        'output_categories': ['Deep Sleep', 'Light Sleep', 'Awake']
    })


if __name__ == '__main__':
    print("\n" + "="*60)
    print("Starting Sleep Detection API Server")
    print("="*60)
    print("Available endpoints:")
    print("  GET  http://localhost:5001/health")
    print("  GET  http://localhost:5001/info")
    print("  POST http://localhost:5001/detect")
    print("  POST http://localhost:5001/batch-detect")
    print("  POST http://localhost:5001/alert-stats")
    print("  POST http://localhost:5001/train")
    print("="*60 + "\n")
    
    app.run(debug=True, host='0.0.0.0', port=5001)
