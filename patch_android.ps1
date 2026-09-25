$manifest = "flutter_app/android/app/src/main/AndroidManifest.xml"
if (Test-Path $manifest) {
  $text = Get-Content $manifest -Raw
  if ($text -notmatch 'android.permission.RECORD_AUDIO') { $text = $text -replace '<manifest ', '<manifest ' + "`n    <uses-permission android:name=`"android.permission.RECORD_AUDIO`"/>`n    <uses-permission android:name=`"android.permission.ACCESS_FINE_LOCATION`"/>`n    <uses-permission android:name=`"android.permission.ACCESS_COARSE_LOCATION`"/>`n" }
  Set-Content $manifest $text
}
