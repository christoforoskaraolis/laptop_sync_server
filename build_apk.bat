@echo off
cd /d "%~dp0"
echo Running flutter pub get...
call flutter pub get
if errorlevel 1 exit /b 1
echo.
echo Building APK...
call flutter build apk
if errorlevel 1 exit /b 1
echo.
echo Done! APK is at: build\app\outputs\flutter-apk\app-release.apk
pause
