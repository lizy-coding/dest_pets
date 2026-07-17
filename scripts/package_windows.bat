@echo off
setlocal EnableExtensions DisableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "PROJECT_DIR=%SCRIPT_DIR%.."
set "BUILD_DIR=%PROJECT_DIR%\build\windows\x64\runner\Release"
set "APP_NAME=Desktop Pet"
set "APP_EXE=%BUILD_DIR%\DesktopPet.exe"

echo === desktop_pet Windows packaging ===

echo [1/4] Running clean release build...
cd /d "%PROJECT_DIR%"
if errorlevel 1 (
  echo ERROR: Could not enter project directory: %PROJECT_DIR%
  exit /b 1
)

if exist "%BUILD_DIR%" (
  rmdir /s /q "%BUILD_DIR%"
  if exist "%BUILD_DIR%" (
    echo ERROR: Could not remove stale build directory: %BUILD_DIR%
    exit /b 1
  )
)

call flutter build windows --release
if errorlevel 1 (
  echo ERROR: Windows release build failed.
  exit /b 1
)

if not exist "%APP_EXE%" (
  echo ERROR: Expected executable not found: %APP_EXE%
  exit /b 1
)
echo   %BUILD_DIR%

echo [2/4] Verifying release bundle...
if not exist "%BUILD_DIR%\flutter_windows.dll" (
  echo ERROR: flutter_windows.dll is missing.
  exit /b 1
)
if not exist "%BUILD_DIR%\desktop_multi_window_plugin.dll" (
  echo ERROR: desktop_multi_window_plugin.dll is missing.
  exit /b 1
)
if not exist "%BUILD_DIR%\screen_retriever_windows_plugin.dll" (
  echo ERROR: screen_retriever_windows_plugin.dll is missing.
  exit /b 1
)
if not exist "%BUILD_DIR%\window_manager_plugin.dll" (
  echo ERROR: window_manager_plugin.dll is missing.
  exit /b 1
)
if not exist "%BUILD_DIR%\data\icudtl.dat" (
  echo ERROR: data\icudtl.dat is missing.
  exit /b 1
)
if not exist "%BUILD_DIR%\data\app.so" (
  echo ERROR: data\app.so is missing.
  exit /b 1
)
if not exist "%BUILD_DIR%\data\flutter_assets\assets\pets\default_pet\pet.json" (
  echo ERROR: Bundled pet manifest is missing.
  exit /b 1
)
if not exist "%BUILD_DIR%\data\flutter_assets\assets\pets\default_pet\spritesheet.webp" (
  echo ERROR: Bundled pet spritesheet is missing.
  exit /b 1
)
echo   Required runtime files found.

for /f "tokens=2" %%V in ('findstr /b /c:"version:" "%PROJECT_DIR%\pubspec.yaml"') do set "FULL_VERSION=%%V"
if not defined FULL_VERSION (
  echo ERROR: Could not read version from pubspec.yaml.
  exit /b 1
)
for /f "tokens=1 delims=+" %%V in ("%FULL_VERSION%") do set "VERSION=%%V"

set "DIST_DIR=%PROJECT_DIR%\dist"
if not exist "%DIST_DIR%" (
  mkdir "%DIST_DIR%"
  if errorlevel 1 (
    echo ERROR: Could not create dist directory: %DIST_DIR%
    exit /b 1
  )
)

set "ZIP_NAME=%APP_NAME%-%VERSION%-windows-x64.zip"
set "ZIP_PATH=%DIST_DIR%\%ZIP_NAME%"
set "CHECKSUM_PATH=%ZIP_PATH%.sha256"

echo [3/4] Creating distributable zip...
if exist "%ZIP_PATH%" del /f /q "%ZIP_PATH%"
if exist "%CHECKSUM_PATH%" del /f /q "%CHECKSUM_PATH%"

powershell.exe -NoLogo -NoProfile -NonInteractive -Command "Compress-Archive -Path (Join-Path $env:BUILD_DIR '*') -DestinationPath $env:ZIP_PATH -Force"
if errorlevel 1 (
  echo ERROR: Failed to create Windows zip.
  exit /b 1
)
if not exist "%ZIP_PATH%" (
  echo ERROR: Expected zip was not created: %ZIP_PATH%
  exit /b 1
)
for %%I in ("%ZIP_PATH%") do if %%~zI LEQ 0 (
  echo ERROR: Created zip is empty: %ZIP_PATH%
  exit /b 1
)

echo [4/4] Writing SHA-256 checksum...
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "$hash = (Get-FileHash -LiteralPath $env:ZIP_PATH -Algorithm SHA256).Hash.ToLowerInvariant(); Set-Content -LiteralPath $env:CHECKSUM_PATH -Value ($hash + '  ' + [IO.Path]::GetFileName($env:ZIP_PATH)) -Encoding ascii"
if errorlevel 1 (
  echo ERROR: Failed to write SHA-256 checksum.
  exit /b 1
)
if not exist "%CHECKSUM_PATH%" (
  echo ERROR: Expected checksum was not created: %CHECKSUM_PATH%
  exit /b 1
)

echo Done.
echo   ZIP: %ZIP_PATH%
echo   SHA-256: %CHECKSUM_PATH%
exit /b 0
