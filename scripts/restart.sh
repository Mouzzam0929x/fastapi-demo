#!/bin/bash

# Simple restart script for FastAPI application

set -e

echo "=========================================="
echo "Restarting Application"
echo "=========================================="

# Get the directory where script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(dirname "$SCRIPT_DIR")"

cd "$APP_DIR"

# Activate virtual environment if exists
if [ -d "venv" ]; then
    source venv/bin/activate
fi

# Install dependencies
if [ -f "requirements.txt" ]; then
    echo "Installing dependencies..."
    pip install -q -r requirements.txt
fi

# Stop existing application
echo "Stopping existing processes..."
pkill -f "uvicorn.*main:app" || true
sleep 2

# Create logs directory
mkdir -p logs

# Start application
echo "Starting application..."
nohup uvicorn main:app --host 0.0.0.0 --port 8000 > logs/app.log 2>&1 &

echo "Application started with PID: $!"
sleep 3

# Check if running
if pgrep -f "uvicorn.*main:app" > /dev/null; then
    echo "✅ Application is running"
else
    echo "❌ Application failed to start"
    tail -n 20 logs/app.log
    exit 1
fi

echo "=========================================="
echo "Restart Complete"
echo "=========================================="