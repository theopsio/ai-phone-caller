#!/bin/bash
# AI Phone Caller - Interactive Onboarding
# Guides the user through setup step by step

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

ENV_FILE="server/.env"

echo ""
echo -e "${BOLD}================================================${NC}"
echo -e "${BOLD}  AI Phone Caller - Setup Wizard${NC}"
echo -e "${BOLD}================================================${NC}"
echo ""
echo "This will guide you through setting up your AI phone agent."
echo "You'll need accounts with a few services (all have free tiers)."
echo ""

# --- Language ---
echo -e "${BLUE}Step 1/6: Language${NC}"
echo "Which language should your phone agent speak?"
echo "  1) German (Deutsch)"
echo "  2) English"
echo ""
read -p "Choose [1/2] (default: 1): " LANG_CHOICE
case "$LANG_CHOICE" in
  2) CALLER_LANGUAGE="en"; LANG_NAME="English" ;;
  *) CALLER_LANGUAGE="de"; LANG_NAME="German" ;;
esac
echo -e "${GREEN}✓ Language: ${LANG_NAME}${NC}"
echo ""

# --- Telephony ---
echo -e "${BLUE}Step 2/6: Telephony (makes the actual phone calls)${NC}"
echo "You need a telephony provider to make real phone calls."
echo ""
echo "  1) Twilio (~2¢/min, most popular, easiest setup)"
echo "     → Sign up: https://twilio.com/try-twilio"
echo ""
echo "  2) Telnyx (~1¢/min, cheaper, EU-friendly)"
echo "     → Sign up: https://telnyx.com"
echo ""
read -p "Choose [1/2] (default: 1): " TEL_CHOICE
case "$TEL_CHOICE" in
  2) TELEPHONY_PROVIDER="telnyx" ;;
  *) TELEPHONY_PROVIDER="twilio" ;;
esac

if [ "$TELEPHONY_PROVIDER" = "twilio" ]; then
  echo ""
  echo -e "${YELLOW}Twilio Setup:${NC}"
  echo "1. Sign up at https://twilio.com/try-twilio"
  echo "2. Get a phone number (free with trial)"
  echo "3. Find your Account SID and Auth Token in the console"
  echo ""
  read -p "Twilio Account SID: " TWILIO_ACCOUNT_SID
  read -p "Twilio Auth Token: " TWILIO_AUTH_TOKEN
  read -p "Twilio Phone Number (e.g. +1234567890): " TWILIO_PHONE_NUMBER
  echo -e "${GREEN}✓ Twilio configured${NC}"
else
  echo ""
  echo -e "${YELLOW}Telnyx Setup:${NC}"
  echo "1. Sign up at https://telnyx.com"
  echo "2. Create a SIP Connection"
  echo "3. Get a phone number"
  echo ""
  read -p "Telnyx API Key: " TELNYX_API_KEY
  read -p "Telnyx Connection ID: " TELNYX_CONNECTION_ID
  read -p "Telnyx Phone Number (e.g. +4930123456): " TELNYX_PHONE_NUMBER
  echo -e "${GREEN}✓ Telnyx configured${NC}"
fi
echo ""

# --- STT ---
echo -e "${BLUE}Step 3/6: Speech-to-Text (understands what the caller says)${NC}"
echo ""
echo "Deepgram is the recommended STT provider."
echo "→ Sign up: https://deepgram.com (comes with \$200 free credit!)"
echo ""
read -p "Deepgram API Key: " DEEPGRAM_API_KEY
echo -e "${GREEN}✓ Deepgram configured${NC}"
echo ""

# --- TTS ---
echo -e "${BLUE}Step 4/6: Text-to-Speech (the voice your agent speaks with)${NC}"
echo ""
echo "  1) Cartesia (recommended, natural voices, free tier)"
echo "     → Sign up: https://cartesia.ai"
echo ""
echo "  2) OpenAI TTS (good quality, requires OpenAI API key)"
echo ""
read -p "Choose [1/2] (default: 1): " TTS_CHOICE
case "$TTS_CHOICE" in
  2) TTS_PROVIDER="openai"
     echo ""
     read -p "OpenAI API Key: " TTS_OPENAI_KEY
     echo -e "${GREEN}✓ OpenAI TTS configured${NC}"
     ;;
  *) TTS_PROVIDER="cartesia"
     echo ""
     echo "→ Sign up at https://cartesia.ai and get your API key"
     read -p "Cartesia API Key: " CARTESIA_API_KEY
     echo -e "${GREEN}✓ Cartesia configured${NC}"
     ;;
esac
echo ""

# --- LLM ---
echo -e "${BLUE}Step 5/6: LLM (the brain that thinks about what to say)${NC}"
echo ""
echo "  1) Groq (FREE, fast, recommended for starting out)"
echo "     → Sign up: https://console.groq.com"
echo ""
echo "  2) OpenAI (GPT-4, best quality, paid)"
echo "     → Sign up: https://platform.openai.com"
echo ""
echo "  3) Google Gemini (free tier available)"
echo "     → Sign up: https://aistudio.google.com"
echo ""
echo "  4) Anthropic Claude (great quality, paid)"
echo "     → Sign up: https://console.anthropic.com"
echo ""
read -p "Choose [1/2/3/4] (default: 1): " LLM_CHOICE
case "$LLM_CHOICE" in
  2) LLM_PROVIDER="openai"
     read -p "OpenAI API Key: " LLM_API_KEY
     LLM_MODEL="gpt-4.1"
     OPENAI_BASE_URL=""
     ;;
  3) LLM_PROVIDER="google"
     read -p "Google API Key: " LLM_API_KEY
     LLM_MODEL="gemini-2.5-flash"
     ;;
  4) LLM_PROVIDER="anthropic"
     read -p "Anthropic API Key: " LLM_API_KEY
     LLM_MODEL="claude-sonnet-4-20250514"
     ;;
  *) LLM_PROVIDER="openai"
     echo "→ Sign up at https://console.groq.com and get your API key"
     read -p "Groq API Key: " LLM_API_KEY
     LLM_MODEL="llama-3.3-70b-versatile"
     OPENAI_BASE_URL="https://api.groq.com/openai/v1"
     ;;
esac
echo -e "${GREEN}✓ LLM configured${NC}"
echo ""

# --- Server URL ---
echo -e "${BLUE}Step 6/6: Server URL (how the phone provider reaches your server)${NC}"
echo ""
echo "Your telephony provider needs to reach your server via HTTPS."
echo "Options:"
echo "  - ngrok: ngrok http 7860 (free, for testing)"
echo "  - Your own domain with reverse proxy"
echo "  - Cloud deployment (Railway, Render, etc.)"
echo ""
read -p "Public HTTPS URL (e.g. https://your-domain.com/phone): " LOCAL_SERVER_URL
echo -e "${GREEN}✓ Server URL configured${NC}"
echo ""

# --- Write .env ---
echo -e "${YELLOW}Writing configuration to ${ENV_FILE}...${NC}"

cat > "$ENV_FILE" << ENVEOF
# AI Phone Caller - Configuration
# Generated by setup wizard on $(date -u +%Y-%m-%d)

# === Telephony ===
TELEPHONY_PROVIDER=${TELEPHONY_PROVIDER}
ENVEOF

if [ "$TELEPHONY_PROVIDER" = "twilio" ]; then
cat >> "$ENV_FILE" << ENVEOF
TWILIO_ACCOUNT_SID=${TWILIO_ACCOUNT_SID}
TWILIO_AUTH_TOKEN=${TWILIO_AUTH_TOKEN}
TWILIO_PHONE_NUMBER=${TWILIO_PHONE_NUMBER}
ENVEOF
else
cat >> "$ENV_FILE" << ENVEOF
TELNYX_API_KEY=${TELNYX_API_KEY}
TELNYX_CONNECTION_ID=${TELNYX_CONNECTION_ID}
TELNYX_PHONE_NUMBER=${TELNYX_PHONE_NUMBER}
ENVEOF
fi

cat >> "$ENV_FILE" << ENVEOF

# === Speech-to-Text ===
DEEPGRAM_API_KEY=${DEEPGRAM_API_KEY}

# === Text-to-Speech ===
TTS_PROVIDER=${TTS_PROVIDER}
ENVEOF

if [ "$TTS_PROVIDER" = "cartesia" ]; then
  echo "CARTESIA_API_KEY=${CARTESIA_API_KEY}" >> "$ENV_FILE"
fi

cat >> "$ENV_FILE" << ENVEOF

# === LLM ===
LLM_PROVIDER=${LLM_PROVIDER}
LLM_MODEL=${LLM_MODEL}
ENVEOF

if [ "$LLM_PROVIDER" = "openai" ]; then
  echo "OPENAI_API_KEY=${LLM_API_KEY}" >> "$ENV_FILE"
  [ -n "$OPENAI_BASE_URL" ] && echo "OPENAI_BASE_URL=${OPENAI_BASE_URL}" >> "$ENV_FILE"
elif [ "$LLM_PROVIDER" = "google" ]; then
  echo "GOOGLE_API_KEY=${LLM_API_KEY}" >> "$ENV_FILE"
elif [ "$LLM_PROVIDER" = "anthropic" ]; then
  echo "ANTHROPIC_API_KEY=${LLM_API_KEY}" >> "$ENV_FILE"
fi

if [ "$TTS_PROVIDER" = "openai" ] && [ "$LLM_PROVIDER" != "openai" ]; then
  echo "OPENAI_API_KEY=${TTS_OPENAI_KEY}" >> "$ENV_FILE"
fi

cat >> "$ENV_FILE" << ENVEOF

# === Server ===
LOCAL_SERVER_URL=${LOCAL_SERVER_URL}
PORT=7860
CALLER_LANGUAGE=${CALLER_LANGUAGE}
ENVEOF

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  Setup complete!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo "Your configuration is saved in ${ENV_FILE}"
echo ""
echo "Next steps:"
echo "  1. Start the server:  cd server && python server.py"
echo "  2. Or with Docker:    cd server && docker compose up -d"
echo "  3. Make a test call:  curl -X POST http://localhost:7860/call \\"
echo "       -H 'Content-Type: application/json' \\"
echo "       -d '{\"to\": \"+YOUR_NUMBER\", \"task\": \"Say hello and ask how they are\"}'"
echo ""
echo -e "${BLUE}Estimated cost per call: 2-5 cents${NC}"
echo ""
