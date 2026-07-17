# Release Notes

## v0.6.0

Date: pending Windows validation.

Type: Windows internal alpha candidate; not yet published.

### Scope

This candidate prepares the existing Windows scaffold for controlled internal
testing:

- Uses the final `Desktop Pet` product identity and project icon in the Windows
  runner.
- Produces `Desktop Pet-0.6.0-windows-x64.zip` and a matching SHA-256 file.
- Fails packaging when the build, runtime bundle verification, archive, or
  checksum step fails.
- Adds focused Windows bootstrap and capability coverage while preserving the
  shared desktop boundaries.

### Automated Verification

Run on the Windows release host from a clean checkout:

```bat
flutter doctor -v
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
scripts\package_windows.bat
```

The packaging script performs the release build and must produce:

```text
dist/Desktop Pet-0.6.0-windows-x64.zip
dist/Desktop Pet-0.6.0-windows-x64.zip.sha256
```

### Manual Smoke Gate

Complete and record every item in `WINDOWS_INTERNAL_ALPHA_CHECKLIST.md` against
the final extracted zip. The gate covers launch, transparent and frameless
rendering, always-on-top, drag and persistence, menu actions and blur-close,
resource discovery, invalid-resource reporting, multi-display placement,
screen-edge placement, clean exit, and a second Windows account or machine.

### Publishing Notes

- Do not create or push the `v0.6.0` tag until the Windows checklist is fully
  passed and references the exact release commit and artifact SHA-256.
- This internal artifact is not Authenticode signed. Testers may see Microsoft
  Defender SmartScreen and must receive the documented internal exception
  procedure.
- Do not describe Windows as generally supported; this is a controlled internal
  alpha until the recorded Windows validation passes.

## v0.5.0

Date: 2026-07-08

Type: macOS internal alpha candidate.

### Scope

This candidate completes the planned v0.2-v0.5 architecture and UX polish that can be validated on macOS without claiming Windows support:

- Keeps settings controls in the compact auxiliary right-click menu rather than adding a broad settings page.
- Shows ignored local resource reasons in the menu while keeping invalid resources out of runtime state.
- Routes behavior animation state through animation ids for dragging and error states, with `idle` fallback for resources that only define `idle`.
- Keeps desktop platform capability checks centralized in the desktop layer.
- Keeps main and auxiliary window placement guarded against display API failures.
- Adds macOS utility-category bundle metadata.
- Adds app-specific macOS icon assets.

### Manual Smoke Test

Run before publishing a v0.5 artifact:

- Launch the app, drag the pet, quit, and relaunch to confirm position persistence.
- Open the menu near each screen edge and confirm it stays inside the visible display area.
- On multi-display setups, right-click on each display and confirm the menu opens on the corresponding display.
- Click away from the menu and confirm auxiliary window blur closes it.
- Switch to a valid local resource, refresh resources, then switch back to the bundled resource.
- Add an invalid local resource and confirm the menu summarizes why it was ignored.
- Toggle always-on-top, change scale, reset scale, reset config, and recover from an induced error.

### Verification Commands

Run before publishing artifacts:

```sh
dart format lib test
flutter analyze
flutter test
flutter build macos --debug
flutter build macos --release
bash scripts/package_dmg.sh
```

### Publishing Notes

Do not mark Windows supported from this candidate. Windows still requires host validation with `flutter build windows --release`, `scripts\package_windows.bat`, and manual smoke coverage.

This candidate is still not Developer ID signed or notarized.

Expected macOS desktop behavior: the main pet window remains a normal Dock app window, is transparent and borderless, defaults to always-on-top, is visible across Spaces, and uses a temporary auxiliary window for the right-click menu that closes on blur.

## v0.1.1

Date: 2026-07-05

Type: macOS internal alpha patch.

### Scope

This patch improves the right-click pet menu:

- Moves the pet context menu into a lightweight auxiliary desktop window.
- Anchors the menu from the actual mouse screen position.
- Keeps the existing display visible-area clamp for screen-edge avoidance.
- Adds menu actions for always-on-top, refresh resources, reset config, recovery, and quit.
- Shows compact pet status, current scale, and error/recovery feedback in the menu.
- Removes the unimplemented Settings entry until the focused v0.2 settings surface is built.
- Closes the menu when the auxiliary window loses focus.

### Manual Smoke Test

Run before publishing artifacts:

- Launch the app, drag the pet, quit, and relaunch to confirm position persistence.
- Open the menu near the lower-right screen edge and confirm it opens near the cursor.
- Open the menu near each screen edge and confirm it stays inside the visible display area.
- On multi-display setups, right-click on each display and confirm the menu opens on the corresponding display.
- Click away from the menu and confirm auxiliary window blur closes it.
- Switch to a valid local resource, refresh resources, then switch back to the bundled resource.

### Verification Commands

Run before publishing artifacts:

```sh
dart format lib test
flutter analyze
flutter test
flutter build macos --debug
flutter build macos --release
bash scripts/package_dmg.sh
```

### Artifacts

Release build:

```text
build/macos/Build/Products/Release/Desktop Pet.app
```

Packaged DMG:

```text
dist/Desktop Pet-0.1.1.dmg
```

### Publishing Notes

This release is not signed with a Developer ID and is not notarized. The packaging script applies ad-hoc signing only.

Users opening the DMG for the first time may need to right-click the app and select Open to bypass Gatekeeper.

## v0.1.0

Date: 2026-07-04

Type: first macOS internal alpha.

### Scope

This release establishes the first usable desktop pet build:

- Shows the bundled default pet in a transparent macOS window.
- Supports drag-to-move and remembers window position.
- Supports local pet resource discovery and switching.
- Supports size increase, decrease, and reset from the right-click menu.
- Persists config through the current-version `SettingsStore` keys.

### Manual Smoke Test

Passed:

- App launches on macOS.
- Default pet displays.
- Window is transparent, borderless, draggable, and always on top.
- Pet size changes from the right-click menu.
- Selected size and window position persist after restart.
- Core local resource switching path works.

Known issue:

- The right-click menu view is rough and does not reliably dismiss when clicking outside it.

### Verification Commands

Run before publishing artifacts:

```sh
dart format lib test
flutter analyze
flutter test
flutter build macos --debug
flutter build macos --release
```

### Artifacts

Release build:

```text
build/macos/Build/Products/Release/Desktop Pet.app
```

Packaged DMG (generated by `bash scripts/package_dmg.sh`):

```text
dist/Desktop Pet-0.1.0.dmg
```

### Publishing Notes

This release is not signed or notarized. Distribute only as an internal macOS alpha unless signing and notarization are completed.

Users opening the DMG for the first time must right-click the app and select Open to bypass Gatekeeper, since the app is unsigned.
