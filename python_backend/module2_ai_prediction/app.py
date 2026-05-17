"""
Module 2 - Flask API Server for Flight Delay Prediction
Exposes the ML model as REST API endpoints

Endpoints:
- POST /predict - Predict flight delay
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

from flight_delay_model import FlightDelayPredictor

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter requests

# Initialize predictor
predictor = FlightDelayPredictor()

# Try to load existing model, otherwise train new one
model_path = '../models/flight_delay_model.pkl'
if os.path.exists(model_path):
    try:
        predictor.load_model(model_path)
        print("Loaded existing model")
    except Exception as e:
        print(f"Could not load model: {e}, training new model...")
        predictor.train_model()
        predictor.save_model()
else:
    print("Training new model...")
    predictor.train_model()
    predictor.save_model()


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'Flight Delay Prediction API',
        'timestamp': datetime.now().isoformat(),
        'model_loaded': predictor.model is not None
    })


@app.route('/predict', methods=['POST'])
def predict_flight_delay():
    """
    Predict flight delay
    
    Expected JSON:
    {
        "weather": "Clear|Rain|Storm",
        "traffic_level": "Low|Medium|High",
        "departure_hour": 0-23,
        "aircraft_type": "Boeing 777|Boeing 747|Airbus A380|Airbus A320|Boeing 787"
    }
    
    Returns:
    {
        "success": true,
        "prediction": "Yes|No",
        "delay_predicted": true|false,
        "risk_level": "Very High|High|Low|Very Low",
        "confidence": "95.2%",
        "recommendation": "Consider arriving earlier",
        "timestamp": "2024-10-24T12:00:00"
    }
    """
    try:
        data = request.json
        
        # Validate required fields
        required_fields = ['weather', 'traffic_level', 'departure_hour', 'aircraft_type']
        if not all(field in data for field in required_fields):
            return jsonify({
                'success': False,
                'error': f'Missing required fields. Expected: {required_fields}'
            }), 400
        
        # Get prediction
        result = predictor.predict_delay(
            weather=data['weather'],
            traffic_level=data['traffic_level'],
            departure_hour=int(data['departure_hour']),
            aircraft_type=data['aircraft_type']
        )
        
        if 'error' in result:
            return jsonify({
                'success': False,
                'error': result['error']
            }), 400
        
        return jsonify({
            'success': True,
            'prediction': result['prediction'],
            'delay_predicted': result['delay_predicted'],
            'risk_level': result['risk_level'],
            'confidence': result['confidence'],
            'recommendation': result['recommendation'],
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
    
    Returns:
    {
        "success": true,
        "message": "Model trained successfully",
        "timestamp": "2024-10-24T12:00:00"
    }
    """
    try:
        print("Retraining model...")
        predictor.train_model()
        predictor.save_model()
        
        return jsonify({
            'success': True,
            'message': 'Model trained and saved successfully',
            'timestamp': datetime.now().isoformat()
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/batch-predict', methods=['POST'])
def batch_predict():
    """
    Batch predict multiple flights
    
    Expected JSON:
    {
        "flights": [
            {
                "flight_id": "FL001",
                "weather": "Clear",
                "traffic_level": "Low",
                "departure_hour": 8,
                "aircraft_type": "Boeing 777"
            },
            ...
        ]
    }
    """
    try:
        data = request.json
        flights = data.get('flights', [])
        
        if not flights:
            return jsonify({
                'success': False,
                'error': 'No flights provided'
            }), 400
        
        predictions = []
        for flight in flights:
            result = predictor.predict_delay(
                weather=flight['weather'],
                traffic_level=flight['traffic_level'],
                departure_hour=int(flight['departure_hour']),
                aircraft_type=flight['aircraft_type']
            )
            predictions.append({
                'flight_id': flight.get('flight_id', 'unknown'),
                **result
            })
        
        return jsonify({
            'success': True,
            'predictions': predictions,
            'total_flights': len(predictions),
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
        'name': 'Flight Delay Prediction API',
        'version': '1.0.0',
        'description': 'ML-based flight delay prediction service',
        'endpoints': {
            'POST /predict': 'Predict single flight delay',
            'POST /batch-predict': 'Predict multiple flights',
            'POST /train': 'Retrain the model',
            'GET /health': 'Health check',
            'GET /info': 'API information'
        },
        'supported_aircraft': ['Boeing 777', 'Boeing 747', 'Airbus A380', 'Airbus A320', 'Boeing 787'],
        'supported_weather': ['Clear', 'Rain', 'Storm'],
        'supported_traffic_levels': ['Low', 'Medium', 'High']
    })


if __name__ == '__main__':
    print("\n" + "="*60)
    print("Starting Flight Delay Prediction API Server")
    print("="*60)
    print("Available endpoints:")
    print("  GET  http://localhost:5000/health")
    print("  GET  http://localhost:5000/info")
    print("  POST http://localhost:5000/predict")
    print("  POST http://localhost:5000/batch-predict")
    print("  POST http://localhost:5000/train")
    print("="*60 + "\n")
    
    app.run(debug=True, host='0.0.0.0', port=5000)
