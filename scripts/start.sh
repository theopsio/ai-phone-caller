#!/bin/bash
# Start AI Phone Caller server + ngrok tunnel
# Usage: ./start.sh [--ngrok-token YOUR_TOKEN]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$(dirname "$SCRIPT_DIR")/server"

# Parse args
NGROK_TOKEN=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --ngrok-token) NGROK_TOKEN="$2"; shift 2 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

# Check .env
if [ ! -f "$SERVER_DIR/.env" ]; then
    echo "ERROR: $SERVER_DIR/.env not found! Run setup.sh first."
    exit 1
fi

# Configure ngrok if token provided
if [ -n "$NGROK_TOKEN" ]; then
    ngrok config add-authtoken "$NGROK_TOKEN" 2>/dev/null || \
    /snap/bin/ngrok config add-authtoken "$NGROK_TOKEN" 2>/dev/null
fi

# Start ngrok in background
echo "Starting ngrok tunnel on port 7860..."
(ngrok http 7860 --log=stdout > /tmp/ngrok.log 2>&1 || \
 /snap/bin/ngrok http 7860 --log=stdout > /tmp/ngrok.log 2>&1) &
NGROK_PID=$!
sleep 3

# Get ngrok URL
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null | python3 -c "import sys,json; tunnels=json.load(sys.stdin)['tunnels']; print(next(t['public_url'] for t in tunnels if t['public_url'].startswith('https')))" 2>/dev/null || echo "")

if [ -z "$NGROK_URL" ]; then
    echo "WARNING: Could not get ngrok URL. Check /tmp/ngrok.log"
    echo "You may need to set --ngrok-token first."
    kill $NGROK_PID 2>/dev/null
    exit 1
fi

echo "ngrok URL: $NGROK_URL"

# Update .env with ngrok URL
sed -i "s|^LOCAL_SERVER_URL=.*|LOCAL_SERVER_URL=$NGROK_URL|" "$SERVER_DIR/.env"
echo "Updated LOCAL_SERVER_URL in .env"

# Start server
echo "Starting AI Phone Caller server..."
cd "$SERVER_DIR"
source .venv/bin/activate 2>/dev/null || true
python server.py

# Cleanup
kill $NGROK_PID 2>/dev/null
