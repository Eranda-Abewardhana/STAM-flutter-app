# Python Backend Configuration

## Installation

### 1. Create Virtual Environment
```bash
cd python_backend

# Windows
python -m venv venv
venv\Scripts\activate

# Linux/Mac
python3 -m venv venv
source venv/bin/activate
```

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

## Running the Servers

### Module 2 - Flight Delay Prediction API (Port 5000)
```bash
cd module2_ai_prediction
python app.py
```

**Endpoints:**
- `GET /health` - Health check
- `GET /info` - API information
- `POST /predict` - Single flight prediction
- `POST /batch-predict` - Multiple flights prediction
- `POST /train` - Retrain model

**Example Request:**
```bash
curl -X POST http://localhost:5000/predict \
  -H "Content-Type: application/json" \
  -d '{
    "weather": "Clear",
    "traffic_level": "Low",
    "departure_hour": 8,
    "aircraft_type": "Boeing 777"
  }'
```

### Module 3 - Sleep Detection API (Port 5001)
```bash
cd module3_sleep_detection
python app.py
```

**Endpoints:**
- `GET /health` - Health check
- `GET /info` - API information
- `POST /detect` - Single sleep detection
- `POST /batch-detect` - Multiple passengers
- `POST /alert-stats` - Alert statistics
- `POST /train` - Retrain model

**Example Request:**
```bash
curl -X POST http://localhost:5001/detect \
  -H "Content-Type: application/json" \
  -d '{
    "heart_rate": 60,
    "movement_level": 2,
    "body_temperature": 36.5,
    "oxygen_saturation": 98,
    "time_of_day": 23
  }'
```

## Flutter Integration

### Module 2 Integration (in Flutter)
```dart
final response = await http.post(
  Uri.parse("http://10.0.2.2:5000/predict"),
  headers: {"Content-Type": "application/json"},
  body: jsonEncode({
    "weather": "Clear",
    "traffic_level": "Low",
    "departure_hour": 8,
    "aircraft_type": "Boeing 777"
  }),
);

var data = jsonDecode(response.body);
print(data['risk_level']); // High, Very High, Low, Very Low
```

### Module 3 Integration (in Flutter)
```dart
final response = await http.post(
  Uri.parse("http://10.0.2.2:5001/detect"),
  headers: {"Content-Type": "application/json"},
  body: jsonEncode({
    "heart_rate": 60,
    "movement_level": 2,
    "body_temperature": 36.5,
    "oxygen_saturation": 98,
    "time_of_day": 23
  }),
);

var data = jsonDecode(response.body);
print(data['sleep_quality']); // Deep Sleep, Light Sleep, Awake
```

## File Structure

```
python_backend/
├── module2_ai_prediction/
│   ├── app.py                    # Flask API server
│   └── flight_delay_model.py     # ML model
├── module3_sleep_detection/
│   ├── app.py                    # Flask API server
│   └── sleep_detector.py         # ML model
├── models/                       # Trained models (auto-generated)
│   ├── flight_delay_model.pkl
│   ├── sleep_detection_model.pkl
│   └── ...
├── data/
│   ├── flight_training_data.csv
│   └── sleep_training_data.csv
├── requirements.txt
└── README.md
```

## Model Training

Models are automatically trained on first run. To retrain:

**Flight Delay Model:**
```bash
cd module2_ai_prediction
python flight_delay_model.py
```

**Sleep Detection Model:**
```bash
cd module3_sleep_detection
python sleep_detector.py
```

## API Response Format

All APIs follow this standard response format:

```json
{
  "success": true,
  "data": {...},
  "message": "Operation successful",
  "timestamp": "2024-10-24T12:00:00Z"
}
```

## Troubleshooting

### Port Already in Use
If ports 5000 or 5001 are in use:
- Modify port in `app.py`: `app.run(port=5002)`
- Or kill the process using the port

### Module Not Found Error
Ensure you're in the correct directory when running:
```bash
# For Module 2
cd python_backend/module2_ai_prediction
python app.py
```

### CORS Issues
CORS is enabled with `CORS(app)` but if Flutter requests fail:
1. Ensure `flask-cors` is installed
2. Check Flutter URL (use `10.0.2.2` for emulator)
3. Verify port is correct

## Performance Notes

- **First load**: Models are trained on first run (5-10 seconds)
- **Inference**: ~50-100ms per prediction
- **Batch processing**: ~5-10ms per item
- Models are cached in memory after training

## Security Considerations

- Add authentication headers if needed
- Validate all inputs
- Rate limit API calls in production
- Use HTTPS in production
- Keep dependencies updated
