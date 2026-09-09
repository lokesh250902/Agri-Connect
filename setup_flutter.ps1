$ErrorActionPreference = 'Stop'
Set-Location "$PSScriptRoot/flutter_app"
flutter create .
flutter pub get
Write-Host "Flutter project generated. Add microphone permissions from README.md, then run: flutter run"
