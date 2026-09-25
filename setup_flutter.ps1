$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { throw 'Flutter is not installed or not in PATH.' }
if (-not (Test-Path 'flutter_app/android')) { flutter create --platforms=android,ios flutter_app }
Copy-Item 'flutter_source/pubspec.yaml' 'flutter_app/pubspec.yaml' -Force
Copy-Item 'flutter_source/lib/*' 'flutter_app/lib/' -Recurse -Force
$manifest='flutter_app/android/app/src/main/AndroidManifest.xml'
$text=Get-Content $manifest -Raw
if ($text -notmatch 'android.permission.RECORD_AUDIO') { $text=$text -replace '<manifest xmlns:android="http://schemas.android.com/apk/res/android">', '<manifest xmlns:android="http://schemas.android.com/apk/res/android">`n    <uses-permission android:name="android.permission.RECORD_AUDIO"/>`n    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>`n    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>' }
Set-Content $manifest $text
$plist='flutter_app/ios/Runner/Info.plist'
if (Test-Path $plist) {
  $p=Get-Content $plist -Raw
  if ($p -notmatch 'NSMicrophoneUsageDescription') { $p=$p -replace '</dict>', '    <key>NSMicrophoneUsageDescription</key><string>This app uses the microphone for voice questions.</string>`n    <key>NSLocationWhenInUseUsageDescription</key><string>This app uses your location for local weather and agriculture recommendations.</string>`n</dict>' }
  Set-Content $plist $p
}
Write-Host 'Run: cd flutter_app; flutter pub get; flutter run'
