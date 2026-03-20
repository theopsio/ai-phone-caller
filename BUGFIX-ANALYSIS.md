# AI Phone Caller - Bug Analysis (2026-03-19)

## Timeline of Test Calls

| # | Call SID | WebSocket | LLM | Result |
|---|----------|-----------|-----|--------|
| 1 | CA3525.. | No | - | python-multipart missing, form parsing crashed |
| 2 | CA1aeb.. | No | - | python-multipart fixed, but server restart killed process |
| 3 | CAf329.. | No | - | Server OK but no /twiml callback (Cloudflare Tunnel issue) |
| 4 | CA8e42.. | No | - | Switched to direct HTTPS, still no /twiml (port 8443) |
| 5 | CA334d.. | No | - | Inline TwiML, but Twilio can't WSS to port 8443 |
| 6 | CA06ef.. | YES! | - | WebSocket connected but "closed before handshake" (no PyTorch) |
| 7 | CA4ad9.. | YES! | Google crashed | Pipeline ran, VAD detected speech, but Google LLM error: `'dict' object has no attribute 'to_json_dict'` |
| 8 | CAa976.. | YES! | Google crashed | Same Google LLM error. LLMMessagesFrame deprecated. |
| 9 | CAcc33.. | No | - | User didn't press key in time (Twilio Trial requirement) |

## Root Causes Identified

### PROBLEM 1: Deepgram STT returns no transcripts (CRITICAL)
- VAD detects "User started speaking" and "User stopped speaking"
- But ZERO transcripts come back from Deepgram
- Processing time: 0.001s (suspiciously fast = no actual processing)
- TTFB: 23.801s (way too slow = Deepgram is not recognizing anything)
- **Root cause**: Likely Deepgram language config issue. Audio is 8kHz mulaw from Twilio, Deepgram might need explicit `encoding` and `sample_rate` config.
- **Fix**: Set `encoding="mulaw"`, `sample_rate=8000` in Deepgram settings.

### PROBLEM 2: Google LLM incompatible with Pipecat's message format
- Error: `'dict' object has no attribute 'to_json_dict'`
- Google's Pipecat service expects proto-based message objects, not dicts
- LLMMessagesFrame is deprecated
- **Fix**: Switch to OpenAI-compatible LLM (Groq via OpenAI base_url). Already done in .env but Call 9 didn't connect (key press issue).

### PROBLEM 3: Bot doesn't speak first
- Outbound call = bot should greet immediately
- Using deprecated LLMMessagesFrame caused crash
- **Fix**: Use `LLMMessagesUpdateFrame(messages=..., run_llm=True)` or seed the context at pipeline creation time.

### PROBLEM 4: Twilio Trial "Press any key" gate
- Every trial call plays ~7s English message
- User must press a DTMF key to proceed
- This is unavoidable without upgrading ($20 one-time)
- **Workaround**: Document it clearly, or upgrade Twilio account.

## Fixes for Tomorrow

1. **Deepgram encoding fix** (bot.py):
```python
DeepgramSTTService(
    api_key=os.getenv("DEEPGRAM_API_KEY"),
    settings=DeepgramSTTService.Settings(
        language="de",
        model="nova-2",
        encoding="mulaw",
        sample_rate=8000,
        smart_format=True,
        interim_results=True,
        endpointing=300,
        utterance_end_ms=1000,
    ),
)
```

2. **LLM: Use Groq via OpenAI-compatible API** (already in .env):
```
LLM_PROVIDER=openai
OPENAI_API_KEY=<groq_key>
OPENAI_BASE_URL=https://api.groq.com/openai/v1
LLM_MODEL=llama-3.3-70b-versatile
```

3. **Bot greeting fix** - seed system prompt + initial user message into context before pipeline starts:
```python
context = LLMContext()
context.add_message({"role": "system", "content": full_prompt})
context.add_message({"role": "user", "content": "Anruf verbunden. Stelle dich vor."})
```
Then in on_client_connected, trigger LLM with context frame.

4. **Remove deprecated vad_events** from Deepgram settings.
