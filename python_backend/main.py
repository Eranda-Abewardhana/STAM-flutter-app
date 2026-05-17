"""
Python Backend - Main Entry Point
Run both Module 2 and Module 3 servers simultaneously

Usage:
    python main.py              # Run both servers
    python main.py --m2-only    # Run only Module 2
    python main.py --m3-only    # Run only Module 3
"""

import subprocess
import sys
import os
import time
from pathlib import Path

def run_module2():
    """Run Flight Delay Prediction API (Module 2)"""
    print("\n" + "="*70)
    print("Starting Module 2 - Flight Delay Prediction API (Port 5000)")
    print("="*70)
    
    module2_path = Path(__file__).parent / "module2_ai_prediction" / "app.py"
    
    if not module2_path.exists():
        print(f"Error: {module2_path} not found")
        return None
    
    try:
        return subprocess.Popen(
            [sys.executable, str(module2_path)],
            cwd=str(module2_path.parent)
        )
    except Exception as e:
        print(f"Error starting Module 2: {e}")
        return None


def run_module3():
    """Run Sleep Detection API (Module 3)"""
    print("\n" + "="*70)
    print("Starting Module 3 - Sleep Detection API (Port 5001)")
    print("="*70)
    
    module3_path = Path(__file__).parent / "module3_sleep_detection" / "app.py"
    
    if not module3_path.exists():
        print(f"Error: {module3_path} not found")
        return None
    
    try:
        return subprocess.Popen(
            [sys.executable, str(module3_path)],
            cwd=str(module3_path.parent)
        )
    except Exception as e:
        print(f"Error starting Module 3: {e}")
        return None


def main():
    """Main orchestrator"""
    print("\n" + "="*70)
    print("Python Backend - Smart Passenger Alert System")
    print("="*70)
    
    args = sys.argv[1:]
    
    processes = []
    
    # Determine which modules to run
    run_m2 = not any(arg.startswith("--m3") for arg in args)
    run_m3 = not any(arg.startswith("--m2") for arg in args)
    
    if run_m2:
        p = run_module2()
        if p:
            processes.append(p)
        time.sleep(2)
    
    if run_m3:
        p = run_module3()
        if p:
            processes.append(p)
    
    if not processes:
        print("Error: No modules started successfully")
        sys.exit(1)
    
    print("\n" + "="*70)
    print("All services started successfully!")
    print("="*70)
    print("\nAvailable APIs:")
    if run_m2:
        print("  Module 2 (Flight Delay): http://localhost:5000")
        print("    - Docs:    GET  http://localhost:5000/info")
        print("    - Health:  GET  http://localhost:5000/health")
        print("    - Predict: POST http://localhost:5000/predict")
    if run_m3:
        print("  Module 3 (Sleep Detection): http://localhost:5001")
        print("    - Docs:    GET  http://localhost:5001/info")
        print("    - Health:  GET  http://localhost:5001/health")
        print("    - Detect:  POST http://localhost:5001/detect")
    print("\nPress Ctrl+C to stop all services\n")
    
    try:
        # Wait for processes
        for p in processes:
            p.wait()
    except KeyboardInterrupt:
        print("\n\nShutting down services...")
        for p in processes:
            try:
                p.terminate()
                p.wait(timeout=5)
            except:
                p.kill()
        print("Services stopped.")
        sys.exit(0)


if __name__ == "__main__":
    main()
