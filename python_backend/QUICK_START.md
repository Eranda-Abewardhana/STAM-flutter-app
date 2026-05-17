# Quick Start Guide - Python Backend Modules

## 🚀 60-Second Setup

### Step 1: Install Python Dependencies
```bash
cd python_backend
pip install -r requirements.txt
```

### Step 2: Run Both Servers
```bash
python main.py
```

This starts both:
- **Module 2** (Flight Delay Prediction) on port 5000
- **Module 3** (Sleep Detection) on port 5001

---

## 📋 What You Get

### Module 2 - AI Flight Delay Prediction
**Predicts:**
- Flight delays (Yes/No)
- Risk level (Very High, High, Low, Very Low)
- Confidence score
- Recommendations

**Input:** Weather, Traffic Level, Departure Hour, Aircraft Type

**Example:**
```bash
curl -X POST http://localhost:5000/predict \
  -H "Content-Type: application/json" \
  -d '{
    "weather": "Rain",
    "traffic_level": "High",
    "departure_hour": 9,
    "aircraft_type": "Boeing 747"
  }'
```

**Output:**
```json
{
  "success": true,
  "prediction": "Yes",
  "delay_predicted": true,
  "risk_level": "Very High",
  "confidence": "92.5%",
  "recommendation": "Consider arriving earlier"
}
```

---

### Module 3 - Sleep Detection
**Detects:**
- Sleep state (Sleeping/Awake)
- Sleep quality (Deep Sleep, Light Sleep, Good, Awake)
- Vital sign alerts
- Passenger wellness recommendations

**Input:** Heart Rate, Movement Level, Body Temperature, Oxygen Saturation, Time of Day

**Example:**
```bash
curl -X POST http://localhost:5001/detect \
  -H "Content-Type: application/json" \
  -d '{
    "heart_rate": 58,
    "movement_level": 1,
    "body_temperature": 36.5,
    "oxygen_saturation": 98,
    "time_of_day": 23
  }'
```

**Output:**
```json
{
  "success": true,
  "state": "Yes",
  "is_sleeping": true,
  "confidence": "88.3%",
  "sleep_quality": "Deep Sleep",
  "alerts": [],
  "recommendation": "Passenger is in deep sleep - avoid sudden movements"
}
```

---

## 🔌 Flutter Integration

In your Flutter app:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

// Predict flight delay
final response = await http.post(
  Uri.parse('http://10.0.2.2:5000/predict'),
  body: jsonEncode({
    "weather": "Clear",
    "traffic_level": "Low",
    "departure_hour": 8,
    "aircraft_type": "Boeing 777"
  }),
);
var result = jsonDecode(response.body);
print('Risk: ${result["risk_level"]}');

// Detect sleep state
final response = await http.post(
  Uri.parse('http://10.0.2.2:5001/detect'),
  body: jsonEncode({
    "heart_rate": 60,
    "movement_level": 2,
    "body_temperature": 36.5,
    "oxygen_saturation": 98,
    "time_of_day": 23
  }),
);
var result = jsonDecode(response.body);
print('Sleeping: ${result["is_sleeping"]}');
```

See [FLUTTER_INTEGRATION.md](FLUTTER_INTEGRATION.md) for complete examples.

---

## 📁 Project Structure

```
python_backend/
├── module2_ai_prediction/          # Flight delay prediction
│   ├── app.py                      # Flask server
│   ├── flight_delay_model.py       # ML model
│   └── __init__.py
├── module3_sleep_detection/        # Sleep detection
│   ├── app.py                      # Flask server
│   ├── sleep_detector.py           # ML model
│   └── __init__.py
├── data/
│   ├── flight_training_data.csv    # Training dataset
│   └── sleep_training_data.csv     # Training dataset
├── models/                         # Trained models (auto-generated)
│   ├── flight_delay_model.pkl
│   ├── sleep_detection_model.pkl
│   └── ...
├── main.py                         # Start both servers
├── requirements.txt                # Python dependencies
├── README.md                       # Full documentation
├── QUICK_START.md                  # This file
└── FLUTTER_INTEGRATION.md          # Flutter setup guide
```

---

## 🎯 API Endpoints

### Module 2 - Flight Delay (Port 5000)
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/predict` | Predict single flight delay |
| POST | `/batch-predict` | Predict multiple flights |
| POST | `/train` | Retrain the model |
| GET | `/health` | Health check |
| GET | `/info` | API information |

### Module 3 - Sleep Detection (Port 5001)
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/detect` | Detect single sleep state |
| POST | `/batch-detect` | Detect multiple passengers |
| POST | `/alert-stats` | Get alert statistics |
| POST | `/train` | Retrain the model |
| GET | `/health` | Health check |
| GET | `/info` | API information |

---

## ⚙️ Configuration

### For Physical Device
Edit `python_backend/main.py` or Flutter's `PythonApiService`:

```dart
// Replace 10.0.2.2 with your machine's IP
static const String module2BaseUrl = 'http://192.168.1.100:5000';
static const String module3BaseUrl = 'http://192.168.1.100:5001';
```

### Change Ports
Edit the Flask server files:

```python
# module2_ai_prediction/app.py
app.run(debug=True, host='0.0.0.0', port=5002)  # Change port here

# module3_sleep_detection/app.py
app.run(debug=True, host='0.0.0.0', port=5003)  # Change port here
```

---

## 🐛 Troubleshooting

### "Connection refused"
```bash
# Check if servers are running
netstat -an | grep 500  # Linux/Mac
netstat -ano | find "500"  # Windows

# Restart servers
python main.py
```

### "Module not found"
```bash
# Make sure you're in the right directory
cd python_backend
python main.py
```

### Slow first request
- First prediction trains the model (5-10 seconds)
- Subsequent requests are ~50-100ms
- Models are cached in memory

### CORS errors in Flutter
- CORS is enabled by default (flask-cors)
- Ensure Flask is running before Flutter requests

---

## 📊 Model Information

### Flight Delay Model
- **Algorithm:** Random Forest (100 trees)
- **Features:** Weather, Traffic Level, Hour, Aircraft Type
- **Output:** Binary (Delay Yes/No)
- **Accuracy:** ~85-90% on test data
- **Training:** CSV dataset
- **Auto-trains** on first run

### Sleep Detection Model
- **Algorithm:** Gradient Boosting
- **Features:** Heart Rate, Movement, Temperature, O2, Hour
- **Output:** Binary (Sleeping/Awake)
- **Accuracy:** ~88-92% on test data
- **Classes:** Deep Sleep, Light Sleep, Awake
- **Auto-trains** on first run

---

## 🔄 Workflow

```
1. Start Python servers
   python main.py

2. Flutter requests prediction
   POST /predict with flight data

3. ML model processes
   (50-100ms response time)

4. Flutter gets risk level
   Displays to passenger

5. Real-time monitoring
   Continuous sleep detection
   from smartwatch sensors
```

---

## 📝 Example Use Cases

### Use Case 1: Flight Booking
```
User books flight
→ System calls /predict with flight details
→ AI returns delay risk
→ App suggests early arrival
```

### Use Case 2: In-Flight Monitoring
```
Smartwatch sends sensor data
→ System calls /detect with vital signs
→ AI detects if passenger sleeping
→ App sends wellness alerts if needed
```

### Use Case 3: Batch Analysis
```
Flight has 300 passengers
→ System calls /batch-detect with all vitals
→ Gets sleep states for all
→ Alerts crew about potential issues
```

---

## 🚀 Next Steps

1. **Test locally** - Run `python main.py`
2. **Try the APIs** - Use curl or Postman
3. **Integrate with Flutter** - Follow [FLUTTER_INTEGRATION.md](FLUTTER_INTEGRATION.md)
4. **Customize** - Modify training data or model parameters
5. **Deploy** - Move to production servers

---

## 📚 Additional Resources

- Full API Documentation: [README.md](README.md)
- Flutter Integration: [FLUTTER_INTEGRATION.md](FLUTTER_INTEGRATION.md)
- Model Details: See source files in module directories

---

## 💡 Tips

- Keep Python backend running while testing
- Use `10.0.2.2` for Android emulator (not `localhost`)
- Models auto-save after training
- All predictions include confidence scores
- Check `/info` endpoints for API details

---

**Ready to go!** 🎉 Start with `python main.py`
