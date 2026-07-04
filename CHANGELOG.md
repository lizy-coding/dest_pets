# Changelog

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
