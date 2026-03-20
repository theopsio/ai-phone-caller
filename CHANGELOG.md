# Changelog

All notable changes to this project will be documented in this file.

## [0.2.0] - 2026-03-20

### Added
- Inbound call support (receive calls, not just make them)
- German voice support (Cartesia Nico - native German)
- Deepgram Nova-3 STT for improved German recognition (54% fewer errors)
- Configurable VAD parameters for better conversation flow
- Generation config for TTS (speed, emotion control)

### Changed
- Updated to Pipecat 0.0.106 API patterns
- Rewrote bot.py to use OpenAILLMContext + create_context_aggregator (official pattern)
- Improved system prompt for natural German conversations
- Removed filler words from prompt (TTS renders them unnaturally)
- VAD tuned: confidence 0.8, start 0.4s, stop 1.0s (less interruption)
- Deepgram endpointing 400ms, utterance_end 1200ms (lets user finish speaking)

### Fixed
- Deepgram STT encoding parameter removed (not supported in Pipecat 0.0.106)
- LLM model parameter moved to Settings (deprecation warning fix)
- Bot speaks immediately on connect (no delay)

## [0.1.0] - 2026-03-19

### Added
- Initial release
- Outbound phone calls via Twilio
- Pipecat voice pipeline (STT → LLM → TTS)
- Support for Deepgram, Cartesia, OpenAI/Groq LLMs
- FastAPI server with REST API
- Docker support
