# AI Phone Caller

> Open-source AI agent that makes real phone calls. Built on [Pipecat](https://pipecat.ai) + [OpenClaw](https://openclaw.ai).

Your AI assistant calls a real phone number, has a natural conversation in German or English, and completes a task — like scheduling an appointment, following up on an order, or making an inquiry.

## How it works

```
You (via OpenClaw/API)
  → "Call +49301234567, make a haircut appointment for Tuesday 2pm"
    → Server initiates call via Twilio/Telnyx
      → Recipient answers their phone
        → AI speaks naturally, listens, responds in real-time
          → Task completed, result reported back
```

**Stack:**
- **Framework:** [Pipecat](https://github.com/pipecat-ai/pipecat) (open source, Python)
- **Telephony:** Twilio or Telnyx (PSTN via WebSocket)
- **STT:** Deepgram ($200 free credit) or Groq Whisper (free)
- **TTS:** Cartesia (free tier), OpenAI, or Coqui XTTS (self-hosted, free)
- **LLM:** OpenAI, Google, or Anthropic

## Quick Start

### 1. Clone & configure

```bash
git clone https://github.com/theopsio/ai-phone-caller
cd ai-phone-caller/server
cp .env.example .env
# Edit .env with your credentials
```

### 2. Run with Docker

```bash
docker compose up -d
```

### 3. Or run directly

```bash
pip install -r requirements.txt
python server.py
```

### 4. Make a call

```bash
curl -X POST http://localhost:7860/call \
  -H "Content-Type: application/json" \
  -d '{
    "to": "+4930123456",
    "task": "Schedule a haircut for next Tuesday at 2pm",
    "caller_name": "Max Mustermann"
  }'
```

## Twilio Setup

1. Create a [Twilio account](https://www.twilio.com/try-twilio) (free trial includes credits)
2. Buy a phone number with Voice capability
3. Note your Account SID, Auth Token, and phone number
4. For local development, use [ngrok](https://ngrok.com): `ngrok http 7860`
5. Set `LOCAL_SERVER_URL` to your ngrok HTTPS URL

## Cost Breakdown

| Component | Provider | Cost per minute |
|-----------|----------|----------------|
| Phone call | Twilio | ~$0.02 |
| Phone call | Telnyx | ~$0.01 |
| STT | Deepgram | ~$0.004 |
| TTS | Cartesia | Free tier / ~$0.002 |
| LLM | GPT-4o | ~$0.01 |
| **Total** | | **~$0.03-0.05/min** |

Compare to commercial solutions: Bland AI ($0.07-0.12/min), Synthflow ($0.08+/min), VAPI ($0.05+/min).

## OpenClaw Integration

Install the companion skill for seamless integration:

```bash
clawhub install ai-phone-caller
```

Then tell your OpenClaw agent: *"Call the dentist at +4930123456 and ask for the next available appointment"*

## API Reference

### POST /call

Start an outbound call.

```json
{
  "to": "+4930123456",     // Required: E.164 phone number
  "task": "Schedule...",    // Required: what to accomplish
  "caller_name": "Name",   // Optional: who the AI represents
  "greeting": "Guten Tag"  // Optional: custom opening
}
```

Response:
```json
{
  "call_sid": "CA...",
  "status": "initiated",
  "to": "+4930123456"
}
```

### GET /health

Health check.

## Configuration

See [.env.example](server/.env.example) for all options.

### Provider Matrix

| Role | Options |
|------|---------|
| Telephony | Twilio, Telnyx |
| STT | Deepgram |
| TTS | Cartesia, OpenAI, Coqui XTTS |
| LLM | OpenAI, Google Gemini, Anthropic Claude |

## Privacy & Security

- **No call recordings** stored by default
- **All credentials** stay on your server
- **No data sent** to third parties beyond the configured providers
- **Open source** — audit the code yourself

## Roadmap

- [ ] Telnyx WebSocket support (currently Twilio only)
- [ ] Coqui XTTS self-hosted TTS integration
- [ ] Voice cloning support (clone a specific voice from 6s audio)
- [ ] Call transcription logging
- [ ] IVR/phone menu navigation
- [ ] Human takeover (pause AI, join call)
- [ ] Inbound call handling
- [ ] Multi-language auto-detection

## License

MIT

## Credits

- [Pipecat](https://pipecat.ai) by Daily — the voice AI framework
- [OpenClaw](https://openclaw.ai) — the AI agent platform
- Built by [@theopsio](https://github.com/theopsio)
