import truststore
truststore.inject_into_ssl()  # use the Windows trust store for outbound HTTPS (corporate TLS-inspecting proxy/AV isn't in certifi's bundle)

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.voice import router as voice_router
from app.api.image import router as image_router
from app.api.weather import router as weather_router
from app.api.crops import router as crops_router

app = FastAPI(title="Agri Voice AI Assistant", version="0.1.0")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])
app.include_router(voice_router, prefix="/api")
app.include_router(image_router, prefix="/api")
app.include_router(weather_router, prefix="/api")
app.include_router(crops_router, prefix="/api")

@app.get("/")
def root():
    return {"name": "Agri Voice AI Assistant", "version": "0.1.0"}

@app.get("/health")
def health():
    return {"status": "ok"}
