# Multilingual Voice AI Assistant

Flutter mobile app + FastAPI backend + Gemini.

Flow: microphone -> FastAPI -> Gemini transcription/language/answer -> Gemini TTS -> Flutter audio playback.

## 1. Backend

```powershell
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
# Edit .env and add GEMINI_API_KEY
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## 2. Flutter

This bundle contains the Flutter application source. Generate the standard platform scaffolding once:

```powershell
cd flutter_app
flutter create .
flutter pub get
flutter run
```

Then make the platform permission changes described below.

### Android
Add microphone permission to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

For local HTTP development, Android may need cleartext traffic enabled in the application element. The app uses `http://10.0.2.2:8000` for the Android emulator. For a physical phone, change `baseUrl` in `lib/services/api_service.dart` to your computer's LAN IP.

### iOS
Add to `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app uses the microphone to understand your voice questions.</string>
```

For a physical iPhone, use an HTTPS backend in production. For local development, configure networking appropriately for your simulator/device.

## 3. Supported idea

The assistant is designed to accept languages such as English, Tamil, Hindi, Telugu, Kannada and Malayalam, while allowing Gemini to identify the spoken language and answer in that language.
