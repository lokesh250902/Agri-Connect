from typing import Optional
from fastapi import APIRouter
from pydantic import BaseModel, Field
from app.services.crop_service import recommend_crops

router = APIRouter()

class CropRequest(BaseModel):
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    soil_type: Optional[str] = None
    soil_ph: Optional[float] = None
    water_availability: Optional[str] = None
    planting_month: Optional[int] = Field(None, ge=1, le=12)

@router.post("/crops/recommend")
async def crops(req: CropRequest):
    return await recommend_crops(req.model_dump())
