import base64
from fastapi import APIRouter, File, HTTPException, UploadFile
from app.services.gemini_service import analyze_image, generate_tts

router = APIRouter()
ALLOWED = {"image/jpeg", "image/png", "image/webp", "image/heic", "image/heif"}

@router.post("/image")
async def image(image: UploadFile = File(...), language: str = "English"):
    content_type = image.content_type or ""
    if content_type not in ALLOWED:
        raise HTTPException(400, f"Unsupported image type: {content_type}")
    data = await image.read()
    if not data:
        raise HTTPException(400, "Empty image")
    if len(data) > 15 * 1024 * 1024:
        raise HTTPException(413, "Image too large")
    result = await analyze_image(data, content_type, language)
    audio = await generate_tts(result["answer"])
    result["audio_base64"] = base64.b64encode(audio).decode("ascii")
    result["audio_mime_type"] = "audio/wav"
    return result
