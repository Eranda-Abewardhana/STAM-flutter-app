"""
Quick Test Script - Works in PowerShell
Just run: python quick_test.py

(No curl needed - Python does all the testing)
"""

import sys
import time

def wait_for_servers():
    """Wait for servers to start"""
    print("\nWaiting for servers to start...")
    print("(If they're not running, start them with: python main.py)")
    time.sleep(2)

def test_flight_delay():
    try:
        import requests
    except ImportError:
        print("❌ requests module not installed")
        print("   Run: pip install requests")
        return
    
    print("\n" + "="*70)
    print("Testing Module 2 - Flight Delay Prediction")
    print("="*70)
    
    test_cases = [
        {
            "name": "Clear weather, low traffic",
            "data": {
                "weather": "Clear",
                "traffic_level": "Low",
                "departure_hour": 8,
                "aircraft_type": "Boeing 777"
            }
        },
        {
            "name": "Rain, high traffic",
            "data": {
                "weather": "Rain",
                "traffic_level": "High",
                "departure_hour": 9,
                "aircraft_type": "Boeing 747"
            }
        },
        {
            "name": "Storm, very high traffic",
            "data": {
                "weather": "Storm",
                "traffic_level": "High",
                "departure_hour": 10,
                "aircraft_type": "Airbus A380"
            }
        },
    ]
    
    for i, test in enumerate(test_cases, 1):
        try:
            print(f"\n✓ Test {i}: {test['name']}")
            response = requests.post(
                'http://localhost:5000/predict',
                json=test['data'],
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get('success'):
                    print(f"   Prediction: {data['prediction']}")
                    print(f"   Risk Level: {data['risk_level']}")
                    print(f"   Confidence: {data['confidence']}")
                    print(f"   Recommendation: {data['recommendation']}")
                else:
                    print(f"   ❌ Error: {data.get('error')}")
            else:
                print(f"   ❌ HTTP {response.status_code}")
        except requests.exceptions.ConnectionError:
            print(f"   ❌ Cannot connect to Module 2 (Port 5000)")
            print(f"      Start servers: python main.py")
        except Exception as e:
            print(f"   ❌ Error: {e}")

def test_sleep_detection():
    try:
        import requests
    except ImportError:
        return
    
    print("\n" + "="*70)
    print("Testing Module 3 - Sleep Detection")
    print("="*70)
    
    test_cases = [
        {
            "name": "Sleeping (night, low HR, low movement)",
            "data": {
                "heart_rate": 58,
                "movement_level": 1,
                "body_temperature": 36.5,
                "oxygen_saturation": 98,
                "time_of_day": 23
            }
        },
        {
            "name": "Awake (morning, high HR, high movement)",
            "data": {
                "heart_rate": 85,
                "movement_level": 10,
                "body_temperature": 37.2,
                "oxygen_saturation": 96,
                "time_of_day": 8
            }
        },
        {
            "name": "Light activity (afternoon)",
            "data": {
                "heart_rate": 72,
                "movement_level": 4,
                "body_temperature": 36.8,
                "oxygen_saturation": 97,
                "time_of_day": 14
            }
        },
    ]
    
    for i, test in enumerate(test_cases, 1):
        try:
            print(f"\n✓ Test {i}: {test['name']}")
            response = requests.post(
                'http://localhost:5001/detect',
                json=test['data'],
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get('success'):
                    print(f"   State: {data['state']}")
                    print(f"   Sleep Quality: {data['sleep_quality']}")
                    print(f"   Confidence: {data['confidence']}")
                    if data.get('alerts'):
                        print(f"   Alerts: {', '.join(data['alerts'])}")
                    print(f"   Recommendation: {data['recommendation']}")
                else:
                    print(f"   ❌ Error: {data.get('error')}")
            else:
                print(f"   ❌ HTTP {response.status_code}")
        except requests.exceptions.ConnectionError:
            print(f"   ❌ Cannot connect to Module 3 (Port 5001)")
            print(f"      Start servers: python main.py")
        except Exception as e:
            print(f"   ❌ Error: {e}")

if __name__ == "__main__":
    print("\n" + "="*70)
    print("Python Backend - Quick Test")
    print("="*70)
    
    wait_for_servers()
    test_flight_delay()
    test_sleep_detection()
    
    print("\n" + "="*70)
    print("Testing Complete!")
    print("="*70)

