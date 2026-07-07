@echo off
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "PROJECT_DIR=%SCRIPT_DIR%.."
set "BUILD_DIR=%PROJECT_DIR%\build\windows\x64\runner\Release"
set "APP_NAME=Desktop Pet"

echo === desktop_pet Windows packaging ===

echo [1/3] Running release build...
cd /d "%PROJECT_DIR%"
flutter build windows --release

if not exist "%BUILD_DIR%" (
  echo ERROR: %BUILD_DIR% not found after build.
  exit /b 1
)
echo   %BUILD_DIR%

echo [2/3] Creating distributable zip...
for /f "tokens=1,2 delims=+" %%a in ('findstr "^version:" "%PROJECT_DIR%\pubspec.yaml"') do set VERSION=%%a
set VERSION=%VERSION:version: =%

set DIST_DIR=%PROJECT_DIR%\dist
if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

set ZIP_NAME=%APP_NAME%-%VERSION%-windows-x64.zip
set ZIP_PATH=%DIST_DIR%\%ZIP_NAME%

powershell -Command "Compress-Archive -Path '%BUILD_DIR%\*' -DestinationPath '%ZIP_PATH%' -Force"

echo [3/3] Done.
echo   ZIP: %ZIP_PATH%
echo   Distribute: %ZIP_PATH%
