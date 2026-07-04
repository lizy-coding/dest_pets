# Desktop Pet

Flutter desktop pet PoC for macOS. The app renders a transparent, borderless, always-on-top pet window, plays a Codex atlas idle animation, supports drag-to-move, discovers local pet resources, and persists the selected pet, scale, always-on-top preference, and last window position.

## Status

Current release: `v0.1.0`

Release state: first macOS internal alpha. Core behavior has passed automated checks and manual smoke testing. The app is functional, but the context menu is still minimal and has a known dismissal UX issue.

## Features

- Transparent 200x200 macOS pet window with hidden title bar and window buttons.
- Always-on-top window visible across macOS Spaces.
- Bundled default Codex pet atlas at `assets/pets/default_pet/`.
- Local pet discovery from `${CODEX_HOME:-$HOME/.codex}/pets/<pet-id>/`.
- Strict normalized pet manifest parsing.
- Atlas-based `idle` animation with manifest-defined frame timing.
- Drag-to-move window behavior with persisted position.
- Right-click menu for pet switching and size controls.
- Config persistence through `SettingsStore`.
- Runtime behavior managed through `PetController` and `PetState`.

## Known Issues

- The right-click menu is visually rough.
- Clicking outside the right-click menu may not reliably dismiss it in the current transparent desktop window.
- No app icon, code signing, notarization, or installer packaging is included yet.
- macOS is the only validated platform for this release.

## Requirements

- Flutter SDK compatible with Dart `^3.11.5`
- macOS for the validated desktop target

## Run

```sh
flutter pub get
flutter run -d macos
```

## Build

Debug build:

```sh
flutter build macos --debug
open "build/macos/Build/Products/Debug/Desktop Pet.app"
```

Release build:

```sh
flutter build macos --release
open "build/macos/Build/Products/Release/Desktop Pet.app"
```

## Verify

```sh
dart format lib test
flutter analyze
flutter test
flutter build macos --debug
```

## Pet Resource Format

Bundled resource:

```text
assets/pets/default_pet/
├── pet.json
└── spritesheet.webp
```

Local resource:

```text
${CODEX_HOME:-$HOME/.codex}/pets/<pet-id>/
├── pet.json
└── spritesheet.webp
```

Manifest shape:

```json
{
  "id": "default_pet",
  "name": "Default Pet",
  "description": "Default desktop pet.",
  "defaultScale": 1.0,
  "atlas": {
    "image": "spritesheet.webp",
    "columns": 8,
    "rows": 9,
    "frameWidth": 192,
    "frameHeight": 208
  },
  "animations": {
    "idle": {
      "row": 0,
      "frames": [0, 1, 2, 3, 4, 5],
      "durationsMs": [280, 110, 110, 140, 140, 320],
      "loop": true
    }
  }
}
```

Invalid manifests, unsafe relative paths, missing spritesheets, and resources without an `idle` animation are ignored.

## Architecture

```text
lib/
├── app/app.dart
├── desktop/
│   ├── desktop_window_controller.dart
│   └── macos_window_bootstrap.dart
├── pet/
│   ├── animation/
│   ├── controller/pet_controller.dart
│   ├── model/
│   └── view/
├── resources/
│   ├── data/pet_resource_repository.dart
│   └── model/
└── settings/settings_store.dart
```

Runtime flow:

```text
main.dart
  ├── SettingsStore
  ├── DesktopWindowController
  └── App
        ├── PetResourceRepository
        ├── PetController
        └── PetView
              ├── PetHitArea
              └── PetActor
```

## Roadmap

- Improve context menu styling and outside-click dismissal.
- Add visible error/recovery UI.
- Expose always-on-top in the UI.
- Add app icon, signing, notarization, and packaged release artifacts.
- Add resource import and validation reporting.
- Expand beyond `idle` animation behavior.
