"""
Testing Script - Verify Python Backend Modules

This script tests both Module 2 and Module 3 functionality
Run this after starting the servers with: python main.py

Usage:
    python test_apis.py
"""

import requests
import json
import time
from datetime import datetime

# API URLs
MODULE2_URL = "http://localhost:5000"
MODULE3_URL = "http://localhost:5001"

def print_header(text):
    print("\n" + "="*70)
    print(f"  {text}")
    print("="*70)

def print_result(success, message):
    symbol = "✅" if success else "❌"
    print(f"{symbol} {message}")

def test_module2_health():
    """Test Module 2 health endpoint"""
    print_header("Testing Module 2 Health")
    try:
        response = requests.get(f"{MODULE2_URL}/health", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print_result(True, f"Module 2 is healthy")
            print(f"   Status: {data['status']}")
            print(f"   Service: {data['service']}")
        else:
            print_result(False, f"Module 2 health check failed: {response.status_code}")
    except Exception as e:
        print_result(False, f"Could not connect to Module 2: {e}")

def test_module2_predict():
    """Test Module 2 single prediction"""
    print_header("Testing Module 2 Flight Delay Prediction")
    try:
        test_cases = [
            {
                "weather": "Clear",
                "traffic_level": "Low",
                "departure_hour": 8,
                "aircraft_type": "Boeing 777",
                "name": "Clear weather, low traffic"
            },
            {
                "weather": "Rain",
                "traffic_level": "High",
                "departure_hour": 9,
                "aircraft_type": "Boeing 747",
                "name": "Rain, high traffic"
            },
            {
                "weather": "Storm",
                "traffic_level": "High",
                "departure_hour": 10,
                "aircraft_type": "Airbus A380",
                "name": "Storm, very high traffic"
            },
        ]
        
        for i, test_case in enumerate(test_cases, 1):
            name = test_case.pop("name")
            
            response = requests.post(
                f"{MODULE2_URL}/predict",
                json=test_case,
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get('success'):
                    print_result(True, f"Test {i}: {name}")
                    print(f"   Prediction: {data['prediction']}")
                    print(f"   Risk Level: {data['risk_level']}")
                    print(f"   Confidence: {data['confidence']}")
                    print(f"   Recommendation: {data['recommendation']}")
                else:
                    print_result(False, f"Test {i}: {data.get('error', 'Unknown error')}")
            else:
                print_result(False, f"Test {i}: HTTP {response.status_code}")
    
    except Exception as e:
        print_result(False, f"Error testing predictions: {e}")

def test_module2_batch():
    """Test Module 2 batch prediction"""
    print_header("Testing Module 2 Batch Prediction")
    try:
        flights = [
            {
                "flight_id": "FL001",
                "weather": "Clear",
                "traffic_level": "Low",
                "departure_hour": 8,
                "aircraft_type": "Boeing 777"
            },
            {
                "flight_id": "FL002",
                "weather": "Rain",
                "traffic_level": "High",
                "departure_hour": 10,
                "aircraft_type": "Airbus A320"
            },
            {
                "flight_id": "FL003",
                "weather": "Storm",
                "traffic_level": "High",
                "departure_hour": 12,
                "aircraft_type": "Boeing 787"
            },
        ]
        
        response = requests.post(
            f"{MODULE2_URL}/batch-predict",
            json={"flights": flights},
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print_result(True, f"Batch prediction successful")
                print(f"   Processed {data['total_flights']} flights")
                
                for pred in data['predictions']:
                    print(f"\n   Flight {pred['flight_id']}:")
                    print(f"     Prediction: {pred['prediction']}")
                    print(f"     Risk: {pred['risk_level']}")
            else:
                print_result(False, data.get('error', 'Unknown error'))
        else:
            print_result(False, f"HTTP {response.status_code}")
    
    except Exception as e:
        print_result(False, f"Error in batch testing: {e}")

def test_module3_health():
    """Test Module 3 health endpoint"""
    print_header("Testing Module 3 Health")
    try:
        response = requests.get(f"{MODULE3_URL}/health", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print_result(True, f"Module 3 is healthy")
            print(f"   Status: {data['status']}")
            print(f"   Service: {data['service']}")
        else:
            print_result(False, f"Module 3 health check failed: {response.status_code}")
    except Exception as e:
        print_result(False, f"Could not connect to Module 3: {e}")

def test_module3_detect():
    """Test Module 3 sleep detection"""
    print_header("Testing Module 3 Sleep Detection")
    try:
        test_cases = [
            {
                "heart_rate": 58,
                "movement_level": 1,
                "body_temperature": 36.5,
                "oxygen_saturation": 98,
                "time_of_day": 23,
                "name": "Sleeping (night, low HR, low movement)"
            },
            {
                "heart_rate": 85,
                "movement_level": 10,
                "body_temperature": 37.2,
                "oxygen_saturation": 96,
                "time_of_day": 8,
                "name": "Awake (morning, high HR, high movement)"
            },
            {
                "heart_rate": 72,
                "movement_level": 4,
                "body_temperature": 36.8,
                "oxygen_saturation": 97,
                "time_of_day": 14,
                "name": "Light activity (afternoon)"
            },
        ]
        
        for i, test_case in enumerate(test_cases, 1):
            name = test_case.pop("name")
            
            response = requests.post(
                f"{MODULE3_URL}/detect",
                json=test_case,
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get('success'):
                    print_result(True, f"Test {i}: {name}")
                    print(f"   State: {data['state']}")
                    print(f"   Quality: {data['sleep_quality']}")
                    print(f"   Confidence: {data['confidence']}")
                    if data['alerts']:
                        print(f"   Alerts: {', '.join(data['alerts'])}")
                else:
                    print_result(False, f"Test {i}: {data.get('error', 'Unknown error')}")
            else:
                print_result(False, f"Test {i}: HTTP {response.status_code}")
    
    except Exception as e:
        print_result(False, f"Error testing sleep detection: {e}")

def test_module3_batch():
    """Test Module 3 batch sleep detection"""
    print_header("Testing Module 3 Batch Sleep Detection")
    try:
        readings = [
            {
                "passenger_id": "P001",
                "heart_rate": 60,
                "movement_level": 2,
                "body_temperature": 36.5,
                "oxygen_saturation": 98,
                "time_of_day": 23
            },
            {
                "passenger_id": "P002",
                "heart_rate": 90,
                "movement_level": 12,
                "body_temperature": 37.1,
                "oxygen_saturation": 95,
                "time_of_day": 14
            },
            {
                "passenger_id": "P003",
                "heart_rate": 65,
                "movement_level": 3,
                "body_temperature": 36.6,
                "oxygen_saturation": 97,
                "time_of_day": 2
            },
        ]
        
        response = requests.post(
            f"{MODULE3_URL}/batch-detect",
            json={"readings": readings},
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            if data.get('success'):
                print_result(True, f"Batch detection successful")
                print(f"   Processed {data['total_readings']} passengers")
                
                for pred in data['predictions']:
                    print(f"\n   Passenger {pred['passenger_id']}:")
                    print(f"     State: {pred['state']}")
                    print(f"     Quality: {pred['sleep_quality']}")
                    print(f"     Confidence: {pred['confidence']}")
            else:
                print_result(False, data.get('error', 'Unknown error'))
        else:
            print_result(False, f"HTTP {response.status_code}")
    
    except Exception as e:
        print_result(False, f"Error in batch testing: {e}")

def get_api_info():
    """Get API information"""
    print_header("API Information")
    
    try:
        response = requests.get(f"{MODULE2_URL}/info", timeout=5)
        if response.status_code == 200:
            print("\n📡 Module 2 - Flight Delay Prediction")
            print("   Supported Weather: Clear, Rain, Storm")
            print("   Supported Traffic: Low, Medium, High")
            print("   Supported Aircraft: Boeing 777, Boeing 747, Airbus A380, etc.")
    except:
        pass
    
    try:
        response = requests.get(f"{MODULE3_URL}/info", timeout=5)
        if response.status_code == 200:
            print("\n💓 Module 3 - Sleep Detection")
            print("   Heart Rate: 40-120 bpm")
            print("   Movement: 0-15 scale")
            print("   Temperature: 35-39°C")
            print("   Oxygen: 90-100%")
    except:
        pass

def main():
    """Run all tests"""
    print("\n" + "="*70)
    print("  Python Backend - API Test Suite")
    print("  Smart Passenger Alert System")
    print("="*70)
    print(f"  Testing at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"  Module 2 URL: {MODULE2_URL}")
    print(f"  Module 3 URL: {MODULE3_URL}")
    
    # Test Module 2
    test_module2_health()
    test_module2_predict()
    test_module2_batch()
    
    # Test Module 3
    test_module3_health()
    test_module3_detect()
    test_module3_batch()
    
    # Show API info
    get_api_info()
    
    print_header("Testing Complete")
    print("\n✅ All tests completed! Your Python backend is ready to use.")
    print("\nNext steps:")
    print("1. Keep the backend servers running (python main.py)")
    print("2. Integrate with Flutter using PythonApiService")
    print("3. See FLUTTER_INTEGRATION.md for code examples")
    print()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nTests interrupted by user")
    except Exception as e:
        print(f"\nFatal error: {e}")
