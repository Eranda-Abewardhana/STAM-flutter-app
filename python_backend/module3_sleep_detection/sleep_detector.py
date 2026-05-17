"""
Module 3 - Sleep Detection Module
Smartwatch Sleep Detection using Machine Learning

This module uses scikit-learn to detect:
- Sleeping vs Awake state
- Sleep quality
- Provides alerts for passenger wellness
"""

import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import joblib
import os

class SleepDetector:
    def __init__(self, data_path='../data/sleep_training_data.csv'):
        self.data_path = data_path
        self.model = None
        self.scaler = StandardScaler()
        self.label_encoder = LabelEncoder()
        self.features = ['heart_rate', 'movement_level', 'body_temperature', 'oxygen_saturation', 'time_of_day']
        
    def load_and_prepare_data(self):
        """Load and prepare training data"""
        print("Loading sleep training data...")
        df = pd.read_csv(self.data_path)
        
        X = df[self.features]
        y = df['is_sleeping']
        
        # Encode target
        y_encoded = self.label_encoder.fit_transform(y)
        
        # Scale features
        X_scaled = self.scaler.fit_transform(X)
        
        return X_scaled, y_encoded
    
    def train_model(self):
        """Train the sleep detection model"""
        print("Training sleep detection model...")
        X, y = self.load_and_prepare_data()
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
        
        # Train Gradient Boosting model (excellent for sleep detection)
        self.model = GradientBoostingClassifier(
            n_estimators=100,
            learning_rate=0.1,
            max_depth=5,
            random_state=42
        )
        self.model.fit(X_train, y_train)
        
        # Evaluate model
        y_pred = self.model.predict(X_test)
        accuracy = accuracy_score(y_test, y_pred)
        
        print(f"Model trained successfully!")
        print(f"Accuracy: {accuracy:.2%}")
        print("\nClassification Report:")
        print(classification_report(y_test, y_pred, target_names=self.label_encoder.classes_))
        print("\nConfusion Matrix:")
        print(confusion_matrix(y_test, y_pred))
        
        return self.model
    
    def detect_sleep_state(self, heart_rate, movement_level, body_temperature, oxygen_saturation, time_of_day):
        """
        Detect sleep state from smartwatch sensor data
        
        Args:
            heart_rate: int - beats per minute (typically 50-100 when sleeping)
            movement_level: int - 0-15 (0 = no movement, 15 = high activity)
            body_temperature: float - Celsius (typically 36-37.5)
            oxygen_saturation: int - percentage (95-99% healthy)
            time_of_day: int - 0-23 (hour of day)
        
        Returns:
            dict with sleep state and confidence
        """
        if self.model is None:
            raise ValueError("Model not trained. Call train_model() first.")
        
        # Prepare input
        features = np.array([[heart_rate, movement_level, body_temperature, oxygen_saturation, time_of_day]])
        features_scaled = self.scaler.transform(features)
        
        # Make prediction
        prediction_encoded = self.model.predict(features_scaled)[0]
        prediction = self.label_encoder.inverse_transform([prediction_encoded])[0]
        
        # Get prediction probability
        probabilities = self.model.predict_proba(features_scaled)[0]
        confidence = max(probabilities) * 100
        
        # Analyze vital signs for alerts
        alerts = []
        if heart_rate < 40 or heart_rate > 100:
            alerts.append("⚠️ Heart rate out of normal range")
        if oxygen_saturation < 95:
            alerts.append("⚠️ Low oxygen saturation - seek fresh air")
        if body_temperature > 38.5:
            alerts.append("⚠️ High body temperature - possible fever")
        if body_temperature < 35:
            alerts.append("⚠️ Low body temperature")
        
        # Sleep quality assessment
        sleep_quality = "Good"
        if prediction == "Yes":
            if movement_level < 2 and heart_rate < 65:
                sleep_quality = "Deep Sleep"
            elif movement_level < 5 and heart_rate < 70:
                sleep_quality = "Light Sleep"
        
        return {
            'state': prediction,
            'is_sleeping': prediction == 'Yes',
            'confidence': f'{confidence:.1f}%',
            'sleep_quality': sleep_quality if prediction == 'Yes' else 'Awake',
            'vital_signs': {
                'heart_rate': heart_rate,
                'movement_level': movement_level,
                'body_temperature': body_temperature,
                'oxygen_saturation': oxygen_saturation,
                'time_of_day': time_of_day
            },
            'alerts': alerts,
            'recommendation': self._get_recommendation(prediction, heart_rate, movement_level, oxygen_saturation)
        }
    
    def _get_recommendation(self, state, heart_rate, movement_level, oxygen_sat):
        """Generate recommendation based on sleep state"""
        if state == "Yes":
            if movement_level < 2:
                return "Passenger is in deep sleep - avoid sudden movements"
            else:
                return "Passenger is lightly sleeping - monitor for comfort"
        else:
            if heart_rate > 90 or movement_level > 10:
                return "Passenger appears stressed/active - offer assistance"
            else:
                return "Passenger is awake - normal monitoring"
    
    def batch_detect(self, sensor_readings):
        """
        Batch process multiple sensor readings
        
        Args:
            sensor_readings: list of dicts with sensor data
        
        Returns:
            list of predictions
        """
        predictions = []
        for reading in sensor_readings:
            result = self.detect_sleep_state(
                heart_rate=reading['heart_rate'],
                movement_level=reading['movement_level'],
                body_temperature=reading['body_temperature'],
                oxygen_saturation=reading['oxygen_saturation'],
                time_of_day=reading['time_of_day']
            )
            predictions.append(result)
        return predictions
    
    def save_model(self, model_path='../models/sleep_detection_model.pkl'):
        """Save trained model"""
        if self.model is None:
            raise ValueError("No model to save. Train model first.")
        
        os.makedirs(os.path.dirname(model_path), exist_ok=True)
        joblib.dump(self.model, model_path)
        joblib.dump(self.scaler, model_path.replace('.pkl', '_scaler.pkl'))
        joblib.dump(self.label_encoder, model_path.replace('.pkl', '_label_encoder.pkl'))
        print(f"Model saved to {model_path}")
    
    def load_model(self, model_path='../models/sleep_detection_model.pkl'):
        """Load pre-trained model"""
        self.model = joblib.load(model_path)
        self.scaler = joblib.load(model_path.replace('.pkl', '_scaler.pkl'))
        self.label_encoder = joblib.load(model_path.replace('.pkl', '_label_encoder.pkl'))
        print(f"Model loaded from {model_path}")


if __name__ == "__main__":
    # Example usage
    detector = SleepDetector()
    
    # Train model
    detector.train_model()
    
    # Save model
    detector.save_model()
    
    # Test detections
    print("\n" + "="*60)
    print("TESTING SLEEP DETECTION")
    print("="*60)
    
    test_cases = [
        {'heart_rate': 55, 'movement_level': 1, 'body_temperature': 36.5, 'oxygen_saturation': 98, 'time_of_day': 23},
        {'heart_rate': 85, 'movement_level': 10, 'body_temperature': 37.2, 'oxygen_saturation': 96, 'time_of_day': 8},
        {'heart_rate': 60, 'movement_level': 2, 'body_temperature': 36.6, 'oxygen_saturation': 98, 'time_of_day': 3},
        {'heart_rate': 92, 'movement_level': 14, 'body_temperature': 37.4, 'oxygen_saturation': 95, 'time_of_day': 14},
    ]
    
    for i, reading in enumerate(test_cases, 1):
        result = detector.detect_sleep_state(**reading)
        print(f"\nTest Case {i}:")
        print(f"  HR: {reading['heart_rate']}, Movement: {reading['movement_level']}, Time: {reading['time_of_day']}:00")
        print(f"  State: {result['state']} (Confidence: {result['confidence']})")
        print(f"  Quality: {result['sleep_quality']}")
        if result['alerts']:
            for alert in result['alerts']:
                print(f"  {alert}")
        print(f"  Recommendation: {result['recommendation']}")
