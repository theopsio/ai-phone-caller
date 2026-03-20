---
name: ai-phone-caller
description: Make AI-powered outbound phone calls. The agent calls real phone numbers, has natural conversations (German/English), and completes tasks like scheduling appointments, following up, or making inquiries. Built on Pipecat (open source) with Twilio/Telnyx telephony. Self-hostable, no vendor lock-in.
version: 0.1.0
---

# AI Phone Caller

Make real phone calls where the AI agent speaks naturally, listens, and completes tasks on your behalf.

## Architecture

```
OpenClaw Agent (this skill)
    ↓ HTTP POST /call
AI Phone Caller Server (Pipecat + FastAPI)
    ↓ Twilio/Telnyx API
Phone Network (PSTN)
    ↓
Recipient's Phone
```

The server runs separately (Docker or bare Python). This skill tells OpenClaw how to trigger and manage calls.

## Requirements

- AI Phone Caller server running (see: github.com/theopsio/ai-phone-caller)
- Server URL configured in environment: `AI_PHONE_CALLER_URL`

## Making a Call

```bash
# Simple call
curl -X POST $AI_PHONE_CALLER_URL/call \
  -H "Content-Type: application/json" \
  -d '{
    "to": "+4930123456",
    "task": "Make an appointment for a haircut next Tuesday at 2pm",
    "caller_name": "Max Mustermann"
  }'
```

## How to Use (Agent Instructions)

When the user asks you to make a phone call:

1. Extract: phone number, task/purpose, and caller name
2. POST to the server endpoint
3. Monitor the call status
4. Report back to the user

### Call via curl

```bash
curl -s -X POST "${AI_PHONE_CALLER_URL}/call" \
  -H "Content-Type: application/json" \
  -d "{
    \"to\": \"PHONE_NUMBER\",
    \"task\": \"TASK_DESCRIPTION\",
    \"caller_name\": \"CALLER_NAME\"
  }" | python3 -m json.tool
```

### Check server health

```bash
curl -s "${AI_PHONE_CALLER_URL}/health" | python3 -m json.tool
```

## Call Parameters

| Field | Required | Description |
|-------|----------|-------------|
| `to` | Yes | Phone number in E.164 format (e.g. +4930123456) |
| `task` | Yes | What the AI should accomplish on this call |
| `caller_name` | No | Who the AI represents (default from server config) |
| `greeting` | No | Custom opening line |

## Example Tasks

- "Make an appointment for a haircut on Tuesday at 2pm"
- "Call the dentist and ask for the next available appointment"
- "Follow up on order #12345 and ask about delivery status"
- "Cancel the appointment on Friday and reschedule to Monday"
- "Ask about opening hours and whether they accept walk-ins"

## Supported Languages

- German (Hochdeutsch) - default
- English
- The AI auto-detects and switches based on the recipient

## Self-Hosting the Server

```bash
git clone https://github.com/theopsio/ai-phone-caller
cd ai-phone-caller/server
cp .env.example .env
# Edit .env with your API keys
docker compose up -d
```

### Minimum Setup (cheapest)

| Component | Provider | Cost |
|-----------|----------|------|
| Telephony | Twilio | ~2¢/min |
| STT | Deepgram | $200 free credit |
| TTS | Cartesia | Free tier |
| LLM | Any (OpenAI, Google, Anthropic) | Varies |

### Fully Free (self-hosted TTS)

| Component | Provider | Cost |
|-----------|----------|------|
| Telephony | Telnyx | ~1¢/min |
| STT | Groq Whisper | Free |
| TTS | Coqui XTTS (self-hosted) | Free |
| LLM | Groq Llama/Kimi | Free |

## Environment Variables

Set `AI_PHONE_CALLER_URL` to your server URL:

```bash
export AI_PHONE_CALLER_URL=http://localhost:7860
```

## Notes

- Calls are limited to ~2 minutes by default (configurable)
- The AI waits for the recipient to speak first (no robocall behavior)
- Call recordings are NOT stored by default (privacy)
- All credentials stay on YOUR server, never shared
