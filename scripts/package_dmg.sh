#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build/macos/Build/Products/Release"
APP_NAME="Desktop Pet"
APP_PATH="$BUILD_DIR/$APP_NAME.app"

VERSION=$(grep '^version:' "$PROJECT_DIR/pubspec.yaml" | sed 's/version: *//' | sed 's/+.*//')
DMG_NAME="$APP_NAME-$VERSION.dmg"
DIST_DIR="$PROJECT_DIR/dist"
DMG_PATH="$DIST_DIR/$DMG_NAME"
VOLUME_NAME="$APP_NAME $VERSION"

echo "=== desktop_pet DMG packaging ==="
echo "Version: $VERSION"
echo ""

echo "[1/5] Running release build..."
cd "$PROJECT_DIR"
flutter build macos --release

if [ ! -d "$APP_PATH" ]; then
  echo "ERROR: $APP_PATH not found after build."
  exit 1
fi
echo "  $APP_PATH"

echo ""
echo "[2/5] Signing app with ad-hoc identity..."
codesign --force --deep --sign - "$APP_PATH"
echo "  signed"

echo ""
echo "[3/5] Creating DMG source..."

DMG_ROOT=$(mktemp -d /tmp/dmg_root.XXXXXX)
trap 'rm -rf "$DMG_ROOT"' EXIT

cp -R "$APP_PATH" "$DMG_ROOT/"
ln -s /Applications "$DMG_ROOT/Applications"

echo "  source ready: $DMG_ROOT"

echo ""
echo "[4/5] Building DMG..."

mkdir -p "$DIST_DIR"
rm -f "$DMG_PATH"

hdiutil create \
  -volname "$VOLUME_NAME" \
  -srcfolder "$DMG_ROOT" \
  -ov \
  -format UDZO \
  -imagekey zlib-level=9 \
  "$DMG_PATH"

echo ""
echo "[5/5] Done."
echo ""
echo "  DMG: $DMG_PATH"
echo ""
LS_OUTPUT=$(ls -lh "$DMG_PATH" | awk '{print $5}')
echo "  Size: $LS_OUTPUT"
echo ""
echo "Distribute: $DMG_PATH"
