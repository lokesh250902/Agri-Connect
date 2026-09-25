import csv, json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CROPS = json.loads((ROOT / "data" / "crops.json").read_text(encoding="utf-8"))

async def recommend_crops(req: dict) -> dict:
    soil = (req.get("soil_type") or "").lower()
    month = req.get("planting_month")
    results = []
    for crop in CROPS:
        score = 0
        reasons = []
        if soil and soil in [s.lower() for s in crop["soil_types"]]:
            score += 2; reasons.append("soil type matches the crop profile")
        if month and month in crop["planting_months"]:
            score += 2; reasons.append("planting month is in the listed season")
        if req.get("water_availability") and req["water_availability"].lower() == crop["water_requirement"]:
            score += 1; reasons.append("water requirement matches the stated availability")
        results.append({"crop": crop["crop"], "score": score, "reasons": reasons, "duration_days": crop["duration_days"], "water_requirement": crop["water_requirement"], "market_note": crop["market_note"]})
    results.sort(key=lambda x: x["score"], reverse=True)
    return {"note": "MVP recommendations use a small curated dataset. Market notes are not live prices yet.", "recommendations": results[:5]}
