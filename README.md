# Agri Voice AI Assistant

Flutter + FastAPI + Gemini API agriculture assistant.

## MVP features
- Voice questions in multiple languages
- Gemini audio understanding + language detection
- Gemini image understanding for agriculture/non-agriculture images
- GPS from phone (no GPS API key)
- Weather using Open-Meteo (no API key for the initial prototype)
- Crop recommendation scaffold using local crop knowledge + weather + sample market data
- Gemini TTS response
- Flutter Android/iOS UI

## Architecture
Flutter -> FastAPI -> Gemini + Weather/market services

Gemini API key stays on the backend and is never shipped in the mobile app.

## Prerequisites
- Python 3.11+
- Flutter SDK 3.24+ (install separately)
- Android Studio for Android
- Xcode for iOS (macOS only)
- Gemini API key

## 1. Backend

Windows PowerShell:
```powershell
cd backend
python -m venv .venv
.venv\\Scripts\\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
# Edit .env and set GEMINI_API_KEY
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## 2. Flutter

From the project root:
```powershell
flutter create flutter_app
# Then run setup_flutter.ps1 from the project root
.\\setup_flutter.ps1
cd flutter_app
flutter pub get
flutter run
```

For a physical Android/iPhone, set the backend URL in `flutter_app/lib/services/api_service.dart` to the computer's LAN IP. Android emulator uses `10.0.2.2`.

## 3. API
- GET `/health`
- POST `/api/voice`
- POST `/api/image`
- GET `/api/weather?latitude=...&longitude=...`
- POST `/api/crops/recommend`

## Data strategy
Small curated JSON/CSV files are kept in `data/` during development. They are NOT bundled into the Flutter APK. In production, move them to a backend database/object storage and update them independently of the app.

## Safety
The app treats crop disease/nutrient observations as possible findings, not laboratory diagnosis. Fertilizer dosage is not invented by the LLM; the MVP only gives informational guidance and asks for crop/area/soil-test details before any quantified recommendation.
