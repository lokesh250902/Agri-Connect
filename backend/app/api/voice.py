import base64
from fastapi import APIRouter, File, HTTPException, UploadFile
from app.services.gemini_service import analyze_audio, generate_tts

router = APIRouter()
ALLOWED = {"audio/m4a", "audio/mp4", "audio/aac", "audio/mpeg", "audio/mp3", "audio/wav", "audio/ogg", "audio/flac"}

@router.post("/voice")
async def voice(audio: UploadFile = File(...)):
    content_type = audio.content_type or ""
    if content_type not in ALLOWED:
        raise HTTPException(400, f"Unsupported audio type: {content_type}")
    data = await audio.read()
    if not data:
        raise HTTPException(400, "Empty audio file")
    if len(data) > 20 * 1024 * 1024:
        raise HTTPException(413, "Audio exceeds the 20 MB inline limit")
    result = await analyze_audio(data, content_type)
    audio_out = await generate_tts(result["answer"])
    result["audio_base64"] = base64.b64encode(audio_out).decode("ascii")
    result["audio_mime_type"] = "audio/wav"
    return result
