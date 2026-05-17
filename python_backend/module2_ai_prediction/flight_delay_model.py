"""
Module 2 - AI Prediction Module
Flight Delay Prediction using Machine Learning

This module uses scikit-learn to train a model that predicts:
- Flight delays
- Risk level
- Best departure time
"""

import pandas as pd
import numpy as np
from sklearn.preprocessing import LabelEncoder
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, classification_report
import joblib
import os

class FlightDelayPredictor:
    def __init__(self, data_path='../data/flight_training_data.csv'):
        self.data_path = data_path
        self.model = None
        self.feature_encoders = {}
        self.label_encoder = LabelEncoder()
        self.features = ['weather', 'traffic_level', 'departure_hour', 'aircraft_type']
        
    def load_and_prepare_data(self):
        """Load and prepare training data"""
        print("Loading flight training data...")
        df = pd.read_csv(self.data_path)
        
        # Encode categorical features
        df_encoded = df.copy()
        for feature in ['weather', 'traffic_level', 'aircraft_type']:
            encoder = LabelEncoder()
            df_encoded[feature] = encoder.fit_transform(df[feature])
            self.feature_encoders[feature] = encoder
        
        # Encode target variable
        df_encoded['delay_category'] = self.label_encoder.fit_transform(df['delay_category'])
        
        X = df_encoded[self.features]
        y = df_encoded['delay_category']
        
        return X, y
    
    def train_model(self):
        """Train the delay prediction model"""
        print("Training flight delay prediction model...")
        X, y = self.load_and_prepare_data()
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
        
        # Train Random Forest model (better than Decision Tree for this use case)
        self.model = RandomForestClassifier(n_estimators=100, random_state=42, max_depth=10)
        self.model.fit(X_train, y_train)
        
        # Evaluate model
        y_pred = self.model.predict(X_test)
        accuracy = accuracy_score(y_test, y_pred)
        
        print(f"Model trained successfully!")
        print(f"Accuracy: {accuracy:.2%}")
        print("\nClassification Report:")
        print(classification_report(y_test, y_pred, target_names=self.label_encoder.classes_))
        
        return self.model
    
    def predict_delay(self, weather, traffic_level, departure_hour, aircraft_type):
        """
        Predict flight delay
        
        Args:
            weather: str - 'Clear', 'Rain', 'Storm'
            traffic_level: str - 'Low', 'Medium', 'High'
            departure_hour: int - 0-23
            aircraft_type: str - 'Boeing 777', 'Boeing 747', etc.
        
        Returns:
            dict with prediction and risk level
        """
        if self.model is None:
            raise ValueError("Model not trained. Call train_model() first.")
        
        # Encode input features
        features_dict = {
            'weather': weather,
            'traffic_level': traffic_level,
            'departure_hour': departure_hour,
            'aircraft_type': aircraft_type
        }
        
        features_encoded = []
        try:
            features_encoded.append(self.feature_encoders['weather'].transform([weather])[0])
            features_encoded.append(self.feature_encoders['traffic_level'].transform([traffic_level])[0])
            features_encoded.append(departure_hour)
            features_encoded.append(self.feature_encoders['aircraft_type'].transform([aircraft_type])[0])
        except Exception as e:
            return {
                'error': f'Invalid input: {str(e)}',
                'prediction': 'Unknown'
            }
        
        # Make prediction
        prediction_encoded = self.model.predict([features_encoded])[0]
        prediction = self.label_encoder.inverse_transform([prediction_encoded])[0]
        
        # Get prediction probability for confidence score
        probabilities = self.model.predict_proba([features_encoded])[0]
        confidence = max(probabilities) * 100
        
        # Determine risk level
        if prediction == 'Yes':
            risk_level = 'High'
            if confidence > 80:
                risk_level = 'Very High'
        else:
            risk_level = 'Low'
            if confidence > 80:
                risk_level = 'Very Low'
        
        return {
            'prediction': prediction,
            'delay_predicted': prediction == 'Yes',
            'risk_level': risk_level,
            'confidence': f'{confidence:.1f}%',
            'recommendation': 'Consider arriving earlier' if prediction == 'Yes' else 'Flight on time expected'
        }
    
    def save_model(self, model_path='../models/flight_delay_model.pkl'):
        """Save trained model"""
        if self.model is None:
            raise ValueError("No model to save. Train model first.")
        
        os.makedirs(os.path.dirname(model_path), exist_ok=True)
        joblib.dump(self.model, model_path)
        joblib.dump(self.feature_encoders, model_path.replace('.pkl', '_encoders.pkl'))
        joblib.dump(self.label_encoder, model_path.replace('.pkl', '_label_encoder.pkl'))
        print(f"Model saved to {model_path}")
    
    def load_model(self, model_path='../models/flight_delay_model.pkl'):
        """Load pre-trained model"""
        self.model = joblib.load(model_path)
        self.feature_encoders = joblib.load(model_path.replace('.pkl', '_encoders.pkl'))
        self.label_encoder = joblib.load(model_path.replace('.pkl', '_label_encoder.pkl'))
        print(f"Model loaded from {model_path}")


if __name__ == "__main__":
    # Example usage
    predictor = FlightDelayPredictor()
    
    # Train model
    predictor.train_model()
    
    # Save model
    predictor.save_model()
    
    # Test predictions
    print("\n" + "="*60)
    print("TESTING FLIGHT DELAY PREDICTIONS")
    print("="*60)
    
    test_cases = [
        ('Clear', 'Low', 8, 'Boeing 777'),
        ('Rain', 'High', 9, 'Boeing 747'),
        ('Storm', 'High', 10, 'Airbus A380'),
        ('Clear', 'Low', 15, 'Airbus A320'),
    ]
    
    for weather, traffic, hour, aircraft in test_cases:
        result = predictor.predict_delay(weather, traffic, hour, aircraft)
        print(f"\nWeather: {weather}, Traffic: {traffic}, Hour: {hour}, Aircraft: {aircraft}")
        print(f"Result: {result}")
