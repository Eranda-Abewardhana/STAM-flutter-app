# PowerShell Testing Guide

## Quick Fixes

### Issue 1: Missing 'requests' module
```powershell
pip install requests
```

### Issue 2: curl doesn't work in PowerShell
PowerShell uses `Invoke-WebRequest` instead of `curl`. The syntax is different.

---

## Option 1: Python Test (Easiest ✅)

```powershell
cd D:\SMART TRAVELLING ASSISTANT MB\python_backend
python quick_test.py
```

This is the simplest - it tests everything automatically!

---

## Option 2: PowerShell Invoke-WebRequest

### Test Module 2 (Flight Delay)
```powershell
$body = @{
    weather = "Clear"
    traffic_level = "Low"
    departure_hour = 8
    aircraft_type = "Boeing 777"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:5000/predict" `
    -Method POST `
    -Headers @{"Content-Type"="application/json"} `
    -Body $body | Select-Object -ExpandProperty Content
```

### Test Module 3 (Sleep Detection)
```powershell
$body = @{
    heart_rate = 58
    movement_level = 1
    body_temperature = 36.5
    oxygen_saturation = 98
    time_of_day = 23
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:5001/detect" `
    -Method POST `
    -Headers @{"Content-Type"="application/json"} `
    -Body $body | Select-Object -ExpandProperty Content
```

### Health Check
```powershell
# Module 2
Invoke-WebRequest -Uri "http://localhost:5000/health" | Select-Object -ExpandProperty Content

# Module 3
Invoke-WebRequest -Uri "http://localhost:5001/health" | Select-Object -ExpandProperty Content
```

---

## Option 3: Use curl.exe (if you have Git Bash installed)

If you have Git for Windows or WSL, you can use the real `curl`:

```bash
# In Git Bash terminal
curl -X POST http://localhost:5000/predict \
  -H "Content-Type: application/json" \
  -d '{"weather":"Clear","traffic_level":"Low","departure_hour":8,"aircraft_type":"Boeing 777"}'
```

---

## Full Testing Workflow

### Step 1: Install Dependencies
```powershell
cd D:\SMART TRAVELLING ASSISTANT MB\python_backend
pip install -r requirements.txt
```

### Step 2: Start Servers
```powershell
python main.py
```

### Step 3: In Another PowerShell Window
```powershell
cd D:\SMART TRAVELLING ASSISTANT MB\python_backend
python quick_test.py
```

---

## What Each Test Does

### quick_test.py
- Tests Module 2 with 3 flight scenarios
- Tests Module 3 with 3 sleep scenarios
- Shows all results clearly
- Handles errors gracefully

### Module 2 Tests
1. **Clear weather, low traffic** → Should be LOW risk
2. **Rain, high traffic** → Should be MEDIUM/HIGH risk
3. **Storm, very high traffic** → Should be VERY HIGH risk

### Module 3 Tests
1. **Sleeping state** → Should detect "Yes" (Sleeping)
2. **Awake state** → Should detect "No" (Awake)
3. **Light activity** → Should be borderline

---

## Expected Output

```
======================================================================
Python Backend - Quick Test
======================================================================

Waiting for servers to start...
(If they're not running, start them with: python main.py)

======================================================================
Testing Module 2 - Flight Delay Prediction
======================================================================

✓ Test 1: Clear weather, low traffic
   Prediction: No
   Risk Level: Very Low
   Confidence: 92.3%
   Recommendation: Flight on time expected

✓ Test 2: Rain, high traffic
   Prediction: Yes
   Risk Level: High
   Confidence: 88.7%
   Recommendation: Consider arriving earlier

✓ Test 3: Storm, very high traffic
   Prediction: Yes
   Risk Level: Very High
   Confidence: 95.2%
   Recommendation: Consider arriving earlier

======================================================================
Testing Module 3 - Sleep Detection
======================================================================

✓ Test 1: Sleeping (night, low HR, low movement)
   State: Yes
   Sleep Quality: Deep Sleep
   Confidence: 91.5%
   Recommendation: Passenger is in deep sleep - avoid sudden movements

✓ Test 2: Awake (morning, high HR, high movement)
   State: No
   Sleep Quality: Awake
   Confidence: 94.2%
   Recommendation: Passenger appears stressed/active - offer assistance

✓ Test 3: Light activity (afternoon)
   State: No
   Sleep Quality: Good
   Confidence: 87.3%
   Recommendation: Passenger is awake - normal monitoring

======================================================================
Testing Complete!
======================================================================
```

---

## Troubleshooting

### "Cannot connect to Module 2 (Port 5000)"
```powershell
# Make sure servers are running
python main.py
```

### "requests module not found"
```powershell
pip install requests
```

### Servers don't start
```powershell
# Check if ports are in use
netstat -ano | Select-String "5000|5001"

# If in use, kill the process:
Get-Process -Id (Get-NetTCPConnection -LocalPort 5000).OwningProcess | Stop-Process
```

---

## Summary

1. **Install deps**: `pip install -r requirements.txt`
2. **Start servers**: `python main.py`
3. **Test**: `python quick_test.py` (in another PowerShell)

That's it! The test script handles everything 🚀
