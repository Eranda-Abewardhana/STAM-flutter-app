# API Documentation

## Smart Passenger Alert System - REST API Reference

### Base URL
```
https://api.travelassistant.local/v1
```

### Authentication
All endpoints (except auth endpoints) require a valid JWT token in the `Authorization` header:
```
Authorization: Bearer <token>
```

### Response Format
All responses follow a standard format:
```json
{
  "success": true,
  "data": {...},
  "message": "Operation successful",
  "timestamp": "2024-10-24T12:00:00Z"
}
```

---

## 🛫 Flight Endpoints

### 1. Get All Flights
```
GET /flights
```

**Query Parameters:**
- `status` (optional): Filter by status (on-time, delayed, cancelled)
- `origin` (optional): Filter by origin airport code
- `destination` (optional): Filter by destination airport code
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "FL001",
      "flightNumber": "UL123",
      "airline": "Emirates",
      "origin": "CMB",
      "destination": "DXB",
      "originCity": "Colombo",
      "destinationCity": "Dubai",
      "departureTime": "2024-10-24T08:30:00Z",
      "arrivalTime": "2024-10-24T13:00:00Z",
      "gate": "B14",
      "terminal": "3",
      "status": "delayed",
      "delayMinutes": 30,
      "isFavorite": false,
      "hasAlert": true,
      "boardingStatus": "in-progress",
      "seatAssignment": "12K"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

### 2. Get Flight Details
```
GET /flights/{flightId}
```

**Path Parameters:**
- `flightId`: Unique flight identifier

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "FL001",
    "flightNumber": "UL123",
    "airline": "Emirates",
    "aircraftType": "Boeing 777",
    "origin": "CMB",
    "destination": "DXB",
    "departureTime": "2024-10-24T08:30:00Z",
    "arrivalTime": "2024-10-24T13:00:00Z",
    "scheduledDeparture": "2024-10-24T08:30:00Z",
    "actualDeparture": "2024-10-24T09:00:00Z",
    "gate": "B14",
    "terminal": "3",
    "status": "departed",
    "delayMinutes": 30,
    "isFavorite": false,
    "hasAlert": true,
    "boardingStatus": "completed",
    "seatAssignment": "12K"
  }
}
```

### 3. Update Flight
```
PUT /flights/{flightId}
```

**Request Body:**
```json
{
  "status": "delayed",
  "delayMinutes": 45,
  "gate": "B16",
  "terminal": "3"
}
```

---

## 🔮 Prediction Endpoints

### 1. Get Prediction for Flight
```
GET /predictions/{flightId}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "PRED001",
    "flightId": "FL001",
    "delayProbability": 0.75,
    "estimatedDelayMinutes": 30,
    "impactFactor": "Storm Cell",
    "recommendation": "High probability of delay due to weather",
    "factors": [
      {
        "name": "Storm Cell",
        "weight": 0.45,
        "description": "Severe weather at origin",
        "severity": "high"
      },
      {
        "name": "Traffic",
        "weight": 0.30,
        "description": "Ground traffic at airport",
        "severity": "medium"
      }
    ],
    "confidence": 0.84,
    "timestamp": "2024-10-24T02:00:00Z",
    "modelVersion": "v2.1.0"
  }
}
```

### 2. Predict Flight Delay
```
POST /predictions/predict-delay
```

**Request Body:**
```json
{
  "flightNumber": "UL123",
  "airline": "Emirates",
  "origin": "CMB",
  "destination": "DXB",
  "departureTime": "2024-10-24T08:30:00Z",
  "weatherData": {
    "condition": "Thunderstorm",
    "temperature": 28,
    "windSpeed": 45,
    "visibility": 2
  },
  "historicalData": {
    "averageDelay": 25,
    "cancellationRate": 0.02,
    "onTimePercentage": 0.85
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "delayProbability": 0.78,
    "estimatedDelayMinutes": 35,
    "impactFactor": "Storm Cell",
    "recommendation": "High probability of delay",
    "confidence": 0.86
  }
}
```

---

## 🌦️ Weather Endpoints

### 1. Get Weather for Airport
```
GET /weather/{airportCode}
```

**Path Parameters:**
- `airportCode`: IATA airport code (e.g., CMB, DXB)

**Response:**
```json
{
  "success": true,
  "data": {
    "condition": "Thunderstorm",
    "temperature": 28.5,
    "feelsLike": 32.1,
    "humidity": 85,
    "windSpeed": 45.2,
    "windGust": 62.5,
    "visibility": 2000,
    "pressure": 1008,
    "description": "Heavy thunderstorms with strong winds",
    "icon": "⛈️",
    "lastUpdate": "2024-10-24T12:00:00Z"
  }
}
```

---

## 📊 Sensor Data Endpoints

### 1. Post Sensor Data
```
POST /sensor-data
```

**Request Body:**
```json
{
  "userId": "USER123",
  "heartRate": 62,
  "movement": 5.2,
  "temperature": 36.8,
  "oxygenLevel": 98,
  "sleepPhase": "LIGHT_SLEEP",
  "deviceId": "WATCH001"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "SENSOR001",
    "userId": "USER123",
    "heartRate": 62,
    "movement": 5.2,
    "temperature": 36.8,
    "oxygenLevel": 98,
    "sleepPhase": "LIGHT_SLEEP",
    "timestamp": "2024-10-24T02:30:00Z",
    "deviceId": "WATCH001"
  }
}
```

### 2. Get Latest Sensor Data
```
GET /sensor-data/{userId}/latest
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "SENSOR001",
    "userId": "USER123",
    "heartRate": 62,
    "movement": 5.2,
    "temperature": 36.8,
    "oxygenLevel": 98,
    "sleepPhase": "LIGHT_SLEEP",
    "timestamp": "2024-10-24T02:30:00Z",
    "deviceId": "WATCH001"
  }
}
```

### 3. Get Sleep Analysis
```
GET /sensor-data/{userId}/sleep-analysis?days=7
```

**Query Parameters:**
- `days`: Number of days to analyze (default: 7)

**Response:**
```json
{
  "success": true,
  "data": {
    "deepSleepPercentage": 0.25,
    "lightSleepPercentage": 0.32,
    "remCyclePercentage": 0.08,
    "awakePercentage": 0.35,
    "optimalWakeupWindow": "2024-10-24T07:15:00Z",
    "recommendation": "Your sleep quality is good. Continue maintaining consistent sleep schedule."
  }
}
```

### 4. Get Vitality Metrics
```
GET /sensor-data/{userId}/vitality
```

**Response:**
```json
{
  "success": true,
  "data": {
    "currentHeartRate": 62,
    "averageHeartRate": 68,
    "heartRateVariability": 45,
    "stressLevel": 0.3,
    "energyLevel": 0.75,
    "currentPhase": "LIGHT_SLEEP",
    "lastUpdate": "2024-10-24T02:30:00Z"
  }
}
```

---

## 🚨 Alert Endpoints

### 1. Get Alerts
```
GET /alerts?userId=USER123&limit=20
```

**Query Parameters:**
- `userId`: User identifier
- `limit`: Number of alerts (default: 20)
- `type` (optional): Filter by alert type
- `severity` (optional): Filter by severity

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "ALERT001",
      "userId": "USER123",
      "flightId": "FL001",
      "type": "flight_delay",
      "title": "Flight Delayed",
      "message": "Your flight UL123 has been delayed by 30 minutes",
      "severity": "warning",
      "action": "View details",
      "read": false,
      "timestamp": "2024-10-24T02:00:00Z",
      "actionTakenAt": null
    }
  ],
  "pagination": {
    "total": 45,
    "page": 1,
    "limit": 20
  }
}
```

### 2. Mark Alert as Read
```
PUT /alerts/{alertId}/mark-read
```

**Response:**
```json
{
  "success": true,
  "message": "Alert marked as read"
}
```

### 3. Delete Alert
```
DELETE /alerts/{alertId}
```

**Response:**
```json
{
  "success": true,
  "message": "Alert deleted successfully"
}
```

---

## 👤 User Endpoints

### 1. Get User Profile
```
GET /users/{userId}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "USER123",
    "firstName": "Javindi",
    "lastName": "Nethnika",
    "email": "javindi@example.com",
    "phone": "+94712345678",
    "profileImage": "https://...",
    "fcmToken": "FCM_TOKEN_HERE",
    "notificationsEnabled": true,
    "emailNotifications": true,
    "smartwatchConnected": true,
    "preferredAirline": "Emirates",
    "frequentAirports": ["CMB", "DXB", "SIN"],
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-10-24T02:00:00Z"
  }
}
```

### 2. Update User Profile
```
PUT /users/{userId}
```

**Request Body:**
```json
{
  "firstName": "Javindi",
  "lastName": "Nethnika",
  "phone": "+94712345678",
  "profileImage": "base64_encoded_image",
  "fcmToken": "NEW_FCM_TOKEN",
  "notificationsEnabled": true,
  "emailNotifications": false,
  "smartwatchConnected": true,
  "preferredAirline": "Emirates",
  "frequentAirports": ["CMB", "DXB", "SIN"]
}
```

### 3. Register User
```
POST /auth/register
```

**Request Body:**
```json
{
  "firstName": "Javindi",
  "lastName": "Nethnika",
  "email": "javindi@example.com",
  "password": "SecurePassword123!",
  "phone": "+94712345678"
}
```

### 4. Login User
```
POST /auth/login
```

**Request Body:**
```json
{
  "email": "javindi@example.com",
  "password": "SecurePassword123!"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "JWT_TOKEN_HERE",
    "refreshToken": "REFRESH_TOKEN_HERE",
    "user": {
      "id": "USER123",
      "email": "javindi@example.com",
      "firstName": "Javindi"
    },
    "expiresIn": 3600
  }
}
```

---

## 🛣️ Travel Optimization Endpoints

### 1. Get Travel Optimization
```
GET /travel-optimization?flightId=FL001&currentLat=6.9271&currentLng=80.7743&destinationAirport=CMB
```

**Query Parameters:**
- `flightId`: Flight identifier
- `currentLat`: Current latitude
- `currentLng`: Current longitude
- `destinationAirport`: Destination airport code

**Response:**
```json
{
  "success": true,
  "data": {
    "flightId": "FL001",
    "timeToAirport": "PT25M",
    "recommendedLeaveMinutes": 25,
    "recommendation": "Leave now for optimal arrival time",
    "trafficStatus": "light",
    "weatherImpact": "minimal",
    "updateTime": "2024-10-24T02:00:00Z"
  }
}
```

---

## Error Responses

### 4xx Client Errors
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request parameters",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  },
  "timestamp": "2024-10-24T12:00:00Z"
}
```

### 5xx Server Errors
```json
{
  "success": false,
  "error": {
    "code": "INTERNAL_SERVER_ERROR",
    "message": "An unexpected error occurred",
    "requestId": "req_12345"
  },
  "timestamp": "2024-10-24T12:00:00Z"
}
```

---

## Rate Limiting

- **Rate Limit**: 1000 requests per hour
- **Headers**: 
  - `X-RateLimit-Limit`: 1000
  - `X-RateLimit-Remaining`: Remaining requests
  - `X-RateLimit-Reset`: Reset time (Unix timestamp)

---

## Webhooks

### Flight Status Changed
```
POST https://your-webhook-url.com/webhooks/flight-status-changed
```

**Payload:**
```json
{
  "event": "flight.status_changed",
  "timestamp": "2024-10-24T12:00:00Z",
  "data": {
    "flightId": "FL001",
    "oldStatus": "on-time",
    "newStatus": "delayed",
    "delayMinutes": 30
  }
}
```

---

## SDKs & Libraries

- **Dart/Flutter**: Use `dio` package with REST API
- **JavaScript**: Use `axios` or `fetch` API
- **Python**: Use `requests` library
- **Java**: Use `OkHttp` or `Retrofit`

---

## Changelog

### v1.0.0 (2024-10-24)
- Initial API release
- Flight tracking endpoints
- Prediction endpoints
- Sensor data endpoints
- Authentication endpoints

---

## Support

For API support, contact: api-support@smartpassenger.local

Last Updated: April 2026
