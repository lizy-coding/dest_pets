# Changelog

## 0.6.0 - Unreleased

Windows internal alpha candidate. Publication remains blocked on a successful
Windows-host release build, packaged-zip verification, and the recorded manual
smoke matrix.

### Added

- Focused automated coverage for Windows platform capabilities, taskbar
  behavior, and shared display placement.
- A Windows internal-alpha release checklist with build, artifact, smoke, and
  approval evidence fields.
- SHA-256 checksum generation for the packaged Windows zip.

### Changed

- Replaced generated Windows product metadata and the Flutter template icon
  with the Desktop Pet identity and project icon.
- Renamed the Windows executable to `DesktopPet.exe` while keeping the product
  name and window title as `Desktop Pet`.
- Hardened Windows packaging to remove stale output, stop on build or archive
  failures, verify required runtime files, and reject missing or empty output.
- Prepared the project version as `0.6.0+6` without claiming Windows support
  before host validation passes.

## 0.5.0 - 2026-07-08

### Changed

- Polished the auxiliary right-click menu with a compact pet/status header, current scale display, and clearer status/error messaging.
- Removed the unimplemented Settings menu entry until a focused v0.2 settings surface exists.
- Centralized desktop platform capability checks in the desktop layer.
- Hardened main and auxiliary window placement against screen API failures.
- Documented the Windows validation checklist without changing the supported release target.
- Routed runtime animation behavior through animation ids for dragging and error states, with idle fallback for resources that do not define optional animations.
- Added macOS utility-category bundle metadata.
- Replaced the macOS app icon asset set with app-specific pet icons.

### Added

- Structured local pet resource discovery reports for ignored invalid resources.
- Testable local pets directory resolution for `CODEX_HOME`, macOS/Linux `HOME`, and Windows `USERPROFILE`.
- Compact right-click menu feedback for ignored local resource reasons.
- Widget and controller coverage for ignored resource feedback and behavior animation state changes.

## 0.1.1 - 2026-07-05

Patch macOS internal alpha release.

### Added

- Auxiliary desktop window for the right-click pet context menu.
- Context menu actions for always-on-top, refresh resources, reset config, recover from error, and quit.
- Tests for auxiliary menu actions, menu model serialization, and cursor-based menu anchoring.

### Changed

- Right-click now opens the context menu near the mouse screen position instead of using Flutter window-local coordinates.
- Dragging the pet closes any open auxiliary context menu.

### Fixed

- Context menu placement no longer drifts toward the top-left when the pet window is away from the origin.
- Context menu closes on auxiliary window blur.

## 0.1.0 - 2026-07-04

First macOS internal alpha release.

### Added

- Transparent, borderless, always-on-top macOS desktop pet window.
- Bundled `default_pet` Codex atlas resource.
- Normalized `pet.json` manifest format with atlas and animation metadata.
- Local pet discovery from `${CODEX_HOME:-$HOME/.codex}/pets/<pet-id>/`.
- `PetController` state machine for initialization, idle, dragging, resource switching, and error mode.
- `PetConfig`, `PetState`, `PetAnimationState`, and `PetRuntimeMode` models.
- `SettingsStore` persistence for selected pet, scale, window position, and always-on-top config.
- Right-click menu for resource switching and size controls.
- Model, repository, settings, controller, and widget test coverage.

### Changed

- Removed old `PetPackage`, `PetAppearance*`, legacy manifest fields, and legacy SharedPreferences key compatibility.
- Moved rendering and animation code into the normalized `pet/view` and `pet/animation` structure.
- Moved pet resource parsing and discovery into `resources/`.

### Known Issues

- Right-click menu styling is basic.
- Clicking outside the right-click menu may not reliably close it in the transparent desktop window.
- Release signing, notarization, app icon, and installer packaging are not yet configured.
