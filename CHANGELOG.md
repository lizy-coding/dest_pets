# Changelog

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
