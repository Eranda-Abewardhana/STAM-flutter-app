# Real Flight Data Integration Guide

## Overview

The app now has the capability to fetch **real departure data** from the Colombo International Airport API and display it with AI-powered delay predictions.

## How It Works

### 1. **Flight Data Service** (`lib/services/flight_data_service.dart`)

Provides two main methods:

```dart
// Fetch real departures
List<FlightData> flights = await FlightDataService.fetchRealDepartures(
  apiToken: 'your_api_token_here',
);

// Or use fallback data (for testing)
List<FlightData> flights = await FlightDataService.fetchRealDepartures(
  apiToken: null, // Uses fallback sample flights
);
```

### 2. **Fallback Flight Data**

When the airport API is unavailable or no token is provided, the app displays sample flights:

| Flight | Airline | Aircraft | Departure | Destination | Status |
|--------|---------|----------|-----------|-------------|--------|
| UL101 | SriLankan Airlines | Airbus A330 | 08:00 | KUL | Boarding |
| FD230 | FitsAir | Boeing 737 | 09:30 | MAA | On Time |
| SQ412 | Singapore Airlines | Boeing 777 | 11:15 | SIN | Delayed |
| BA121 | British Airways | Boeing 747 | 14:00 | LHR | On Time |
| EK501 | Emirates | Boeing 777 | 16:45 | DXB | On Time |
| MI601 | Malindo Air | Boeing 737 | 18:20 | KUL | On Time |

### 3. **Real Airport API Integration**

To use **real flight data** from Colombo Airport:

#### Step 1: Get API Access Token
1. Contact Colombo International Airport IT Department
2. Request access to: `https://www.airport.lk/fids_api/api/bia?type=dep`
3. Receive authentication token (Bearer token format)

#### Step 2: Store API Token
Add to your environment or config:

```dart
// Option A: In constants.dart (for development)
const String COLOMBO_AIRPORT_API_TOKEN = 'your_token_here';

// Option B: Use Firebase Remote Config (for production)
final token = await FirebaseRemoteConfig.instance.getString('airport_api_token');
```

#### Step 3: Update Flight Details Screen
```dart
// In flight_details_screen.dart
final flights = await FlightDataService.fetchRealDepartures(
  apiToken: COLOMBO_AIRPORT_API_TOKEN, // Use your token
);
```

### 4. **API Response Format**

The airport API is expected to return data like this:

```json
{
  "flights": [
    {
      "flight_number": "UL101",
      "airline": "SriLankan Airlines",
      "aircraft_type": "Airbus A330",
      "departure_time": "08:00",
      "scheduled_time": "08:00",
      "destination": "Kuala Lumpur (KUL)",
      "route": "CMB-KUL",
      "status": "Boarding",
      "weather": "Clear",
      "traffic_level": "Low"
    }
  ]
}
```

Or as a direct array:
```json
[
  {
    "flight_number": "UL101",
    "airline": "SriLankan Airlines",
    ...
  }
]
```

## Integration with AI Module

Each flight automatically gets AI predictions:

1. **Flight Selected** → App extracts flight data (weather, aircraft, departure hour, traffic)
2. **API Call** → Sends data to Python Module 2 (Flight Delay Predictor)
3. **Prediction** → Returns risk level, confidence, and recommendations
4. **Display** → Shows results with visual indicators

## Example Flow

```
User opens "Flight Details" Screen
    ↓
App loads departures (real or fallback)
    ↓
User sees list of flights with status badges
    ↓
User taps a flight
    ↓
App fetches delay prediction for that flight
    ↓
Prediction shown with risk color and confidence score
    ↓
User sees recommendation (e.g., "Arrive 30 mins early")
```

## Data Models

### FlightData Class
```dart
class FlightData {
  final String flightNumber;
  final String airline;
  final String aircraftType;
  final String departureTime;
  final String destination;
  final String status;
  final String weather;
  final String trafficLevel;

  int get departureHour { /* returns hour as int */ }
  bool get isDelayed { /* checks if status contains "Delayed" */ }
  bool get isCancelled { /* checks if status contains "Cancelled" */ }
}
```

## Error Handling

The service gracefully handles failures:

```
Try real API
  └─ Success → Display real flights ✓
  └─ Timeout → Use fallback flights
  └─ Auth Error → Use fallback flights
  └─ Network Error → Use fallback flights
```

All errors are logged but don't crash the app.

## Production Checklist

- [ ] Obtain airport API authentication token
- [ ] Store token securely (Firebase Remote Config or secure storage)
- [ ] Test with real flights in staging environment
- [ ] Verify weather/traffic data accuracy
- [ ] Set up monitoring for API availability
- [ ] Create fallback data strategy
- [ ] Document update process for fallback flights

## Testing

### With Fallback Data (Current)
```dart
// Automatically uses sample flights
await FlightDataService.fetchRealDepartures(apiToken: null);
```

### With Real API
```dart
// Replace with your token
await FlightDataService.fetchRealDepartures(
  apiToken: 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
);
```

### Test API Endpoint
```bash
# PowerShell
$headers = @{'Authorization' = 'Bearer YOUR_TOKEN'}
Invoke-WebRequest -Uri 'https://www.airport.lk/fids_api/api/bia?type=dep' `
    -Headers $headers | Select-Object -ExpandProperty Content
```

## Customization

### Add Custom Airports
Create similar service for other airports:

```dart
class FlightDataService {
  static const String _colomboAirportUrl = 'https://...';
  // Add more:
  static const String _dubaiAirportUrl = 'https://...';
  static const String _singaporeAirportUrl = 'https://...';
  
  static Future<List<FlightData>> fetchFromDubai(String token) async {
    // Implementation
  }
}
```

### Customize Fallback Data
Edit `_fallbackFlights` array in `flight_data_service.dart` to match your needs.

## Troubleshooting

### "No token was received to authorize the operation"
- Verify your API token is correct
- Check token hasn't expired
- Ensure Bearer token format: `Bearer <token>`

### Missing weather/traffic data
- Fallback service generates random data
- Real API should provide this in response
- Check API response format matches expected schema

### Flights not updating
- Set up polling timer for periodic updates:
```dart
Timer.periodic(Duration(minutes: 5), (_) async {
  final flights = await FlightDataService.fetchRealDepartures(apiToken: token);
  setState(() { _flights = flights; });
});
```

## Next Steps

1. **Get Airport API Token** - Contact Colombo Airport IT
2. **Configure Token Storage** - Add to Firebase Remote Config or constants
3. **Update Flight Details Screen** - Pass token to `fetchRealDepartures()`
4. **Test Live** - Run app with real flight data
5. **Monitor API Health** - Set up alerts for API failures

---

**Last Updated:** April 2026  
**Status:** Ready for production integration  
**Tested With:** Sample fallback data, real API pending authentication
