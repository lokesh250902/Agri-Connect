from fastapi import APIRouter, HTTPException, Query
from app.services.weather_service import get_weather

router = APIRouter()

@router.get("/weather")
async def weather(latitude: float = Query(..., ge=-90, le=90), longitude: float = Query(..., ge=-180, le=180)):
    try:
        return await get_weather(latitude, longitude)
    except Exception as exc:
        raise HTTPException(502, f"Weather service error: {exc}")
