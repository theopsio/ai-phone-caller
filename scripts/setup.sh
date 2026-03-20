#!/bin/bash
# AI Phone Caller - Quick Setup Script
# Run this on your VPS after configuring .env

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SERVER_DIR="$PROJECT_DIR/server"

echo "=== AI Phone Caller Setup ==="

# Check .env exists
if [ ! -f "$SERVER_DIR/.env" ]; then
    echo "ERROR: $SERVER_DIR/.env not found!"
    echo "Copy .env.example to .env and fill in your API keys:"
    echo "  cp $SERVER_DIR/.env.example $SERVER_DIR/.env"
    exit 1
fi

# Create venv if not exists
if [ ! -d "$SERVER_DIR/.venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv "$SERVER_DIR/.venv"
fi

# Activate and install deps
echo "Installing dependencies..."
source "$SERVER_DIR/.venv/bin/activate"
pip install -q -r "$SERVER_DIR/requirements.txt"

echo ""
echo "=== Setup complete ==="
echo ""
echo "To start the server:"
echo "  cd $SERVER_DIR"
echo "  source .venv/bin/activate"
echo "  python server.py"
echo ""
echo "In another terminal, start ngrok:"
echo "  ngrok http 7860"
echo ""
echo "Then update LOCAL_SERVER_URL in .env with your ngrok URL."
