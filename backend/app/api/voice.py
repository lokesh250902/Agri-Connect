import base64
from fastapi import APIRouter, File, HTTPException, UploadFile
from fastapi.responses import JSONResponse
from app.services.gemini_service import process_voice, generate_speech

router = APIRouter()
SUPPORTED_TYPES = {"audio/m4a", "audio/aac", "audio/mp4", "audio/mpeg", "audio/mp3", "audio/wav", "audio/ogg", "audio/flac"}

@router.post("/voice")
async def voice_assistant(audio: UploadFile = File(...)):
    try:
        content_type = audio.content_type or ""
        if content_type not in SUPPORTED_TYPES:
            raise HTTPException(400, f"Unsupported audio type: {content_type}")
        audio_bytes = await audio.read()
        if not audio_bytes:
            raise HTTPException(400, "Empty audio file.")
        if len(audio_bytes) > 15 * 1024 * 1024:
            raise HTTPException(413, "Audio file is too large.")
        result = await process_voice(audio_bytes, content_type)
        wav_bytes = await generate_speech(result["answer"])
        return JSONResponse({
            "success": True,
            "transcript": result["transcript"],
            "language": result["language"],
            "language_code": result["language_code"],
            "answer": result["answer"],
            "audio_base64": base64.b64encode(wav_bytes).decode("utf-8"),
            "audio_mime_type": "audio/wav",
        })
    except HTTPException:
        raise
    except Exception as exc:
        print("Voice processing error:", repr(exc))
        raise HTTPException(500, str(exc))
