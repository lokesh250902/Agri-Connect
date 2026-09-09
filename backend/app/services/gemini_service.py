import base64
import io
import json
import wave
from google import genai
from app.config import GEMINI_API_KEY

client = genai.Client(api_key=GEMINI_API_KEY)
VOICE_MODEL = "gemini-3.8-flash"
TTS_MODEL = "gemini-3.1-flash-tts-preview"

VOICE_RESPONSE_SCHEMA = {
    "type": "object",
    "properties": {
        "transcript": {"type": "string"},
        "language": {"type": "string"},
        "language_code": {"type": "string"},
        "answer": {"type": "string"},
    },
    "required": ["transcript", "language", "language_code", "answer"],
}

async def process_voice(audio_bytes: bytes, mime_type: str) -> dict:
    audio_b64 = base64.b64encode(audio_bytes).decode("utf-8")
    prompt = """
You are a multilingual voice assistant. Analyze the attached audio.
Return JSON containing:
- transcript: accurate transcription
- language: primary spoken language name
- language_code: short code such as en, ta, hi, te, kn, ml
- answer: accurate answer to the user's question
Answer in the same language used by the user. If the user naturally mixes languages,
preserve that style. Keep the answer conversational because it will be spoken aloud.
"""
    response = client.models.generate_content(
        model=VOICE_MODEL,
        contents=[
            {"text": prompt},
            {"inline_data": {"mime_type": mime_type, "data": audio_b64}},
        ],
        config={"response_mime_type": "application/json", "response_schema": VOICE_RESPONSE_SCHEMA},
    )
    return json.loads(response.text)

async def generate_speech(text: str) -> bytes:
    response = client.models.generate_content(
        model=TTS_MODEL,
        contents=text,
        config={
            "response_modalities": ["AUDIO"],
            "speech_config": {"voice_config": {"prebuilt_voice_config": {"voice_name": "Kore"}}},
        },
    )
    pcm = response.candidates[0].content.parts[0].inline_data.data
    if isinstance(pcm, str):
        pcm = base64.b64decode(pcm)
    return pcm_to_wav(pcm)

def pcm_to_wav(pcm: bytes, channels: int = 1, sample_rate: int = 24000, sample_width: int = 2) -> bytes:
    buf = io.BytesIO()
    with wave.open(buf, "wb") as wf:
        wf.setnchannels(channels)
        wf.setsampwidth(sample_width)
        wf.setframerate(sample_rate)
        wf.writeframes(pcm)
    return buf.getvalue()
