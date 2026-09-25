import asyncio
import base64
import io
import wave
from google import genai
from app.config import GEMINI_API_KEY, GEMINI_MODEL, GEMINI_TTS_MODEL

client = genai.Client(api_key=GEMINI_API_KEY)

LANGUAGE_RULE = """
Reply in the user's language when it is identifiable. If the language is not confidently identifiable, reply in English and say that the user can request another language. Preserve the user's requested language preference across turns when supplied by the application.
"""

VOICE_SCHEMA = {
    "type": "object",
    "properties": {
        "transcript": {"type": "string"},
        "language": {"type": "string"},
        "language_code": {"type": "string"},
        "answer": {"type": "string"},
        "intent": {"type": "string"}
    },
    "required": ["transcript", "language", "language_code", "answer", "intent"]
}

IMAGE_SCHEMA = {
    "type": "object",
    "properties": {
        "is_agriculture_related": {"type": "boolean"},
        "object_description": {"type": "string"},
        "crop": {"type": "string"},
        "plant_part": {"type": "string"},
        "possible_issue": {"type": "string"},
        "confidence_note": {"type": "string"},
        "answer": {"type": "string"}
    },
    "required": ["is_agriculture_related", "object_description", "crop", "plant_part", "possible_issue", "confidence_note", "answer"]
}

SYSTEM = """
You are an agriculture-focused multilingual voice assistant for farmers in India.
Be concise, practical and clear. Do not invent current weather, market prices, soil-test values, fertilizer quantities, or pesticide doses. If information is missing, ask for it. For disease/nutrient observations from an image, describe them as possibilities rather than definitive laboratory diagnoses. Never give a precise chemical/fertilizer dose unless validated data is supplied by the application. If an image is not agricultural, describe what you can and ask what the user wants to do with the image. If a request is outside your supported capabilities, say so clearly instead of fabricating an answer.
"""

async def analyze_audio(data: bytes, mime_type: str) -> dict:
    import json
    # client.interactions.create() is a blocking/synchronous SDK call. Calling it
    # directly here would block the whole asyncio event loop for its duration
    # (including any internal retry/backoff sleeps), stalling every other
    # request — even unrelated ones like /health — until it returns.
    # asyncio.to_thread runs it on a worker thread instead.
    interaction = await asyncio.to_thread(
        client.interactions.create,
        model=GEMINI_MODEL,
        input=[
            {"type": "text", "text": SYSTEM + "\n" + LANGUAGE_RULE + "\nAnalyze this user audio. Return a transcription, detected language, language code, intent and a direct answer."},
            {"type": "audio", "data": base64.b64encode(data).decode("ascii"), "mime_type": mime_type},
        ],
        response_format={"type": "text", "mime_type": "application/json", "schema": VOICE_SCHEMA},
    )
    return json.loads(interaction.output_text)

async def analyze_image(data: bytes, mime_type: str, language: str) -> dict:
    import json
    prompt = f"""{SYSTEM}\nPreferred response language: {language}.\nAnalyze this image. First determine whether it is agriculture-related. If it is agricultural, identify the likely crop/plant part and visible symptoms. Do not claim certainty where the image is insufficient. If it is not agricultural, briefly describe it and ask what the user wants to do with it. Return JSON."""
    interaction = await asyncio.to_thread(
        client.interactions.create,
        model=GEMINI_MODEL,
        input=[
            {"type": "text", "text": prompt},
            {"type": "image", "data": base64.b64encode(data).decode("ascii"), "mime_type": mime_type},
        ],
        response_format={"type": "text", "mime_type": "application/json", "schema": IMAGE_SCHEMA},
    )
    return json.loads(interaction.output_text)

async def generate_tts(text: str) -> bytes:
    interaction = await asyncio.to_thread(
        client.interactions.create,
        model=GEMINI_TTS_MODEL,
        input=text,
        response_format={"type": "audio"},
        generation_config={"speech_config": [{"voice": "Kore"}]},
    )
    raw = base64.b64decode(interaction.output_audio.data) if isinstance(interaction.output_audio.data, str) else interaction.output_audio.data
    return pcm_to_wav(raw)

def pcm_to_wav(pcm: bytes) -> bytes:
    buf = io.BytesIO()
    with wave.open(buf, "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(24000)
        wf.writeframes(pcm)
    return buf.getvalue()
