from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.voice import router as voice_router

app = FastAPI(title="Voice AI Assistant API", version="1.0.0")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])
app.include_router(voice_router, prefix="/api")

@app.get("/")
async def root():
    return {"message": "Voice AI Assistant API is running"}

@app.get("/health")
async def health():
    return {"status": "ok"}
