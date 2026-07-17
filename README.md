# Desktop Pet

[English](README.md) | [中文](README.zh-CN.md)

`desktop_pet` is a Flutter desktop pet proof of concept. It renders a Codex atlas pet animation in a transparent, borderless, always-on-top desktop window, supports dragging, a right-click menu, local pet resource discovery, and persists the selected pet, scale, always-on-top preference, and window position.

## Example

![Desktop Pet example](view/mq.gif)

## Status

Current validated internal release: `v0.5.0` for macOS.

Next candidate: `v0.6.0` Windows internal alpha. Its source, metadata, icon,
packaging checks, and automated test seams are prepared, but publication remains
blocked on the Windows-host build and recorded smoke checklist.

## Features

- Transparent 200x200 macOS pet window with hidden title bar and window buttons.
- Always-on-top window visible across macOS Spaces.
- Bundled default Codex pet atlas at `assets/pets/default_pet/`.
- Local pet discovery from `${CODEX_HOME:-$HOME/.codex}/pets/<pet-id>/`.
- Strict normalized `pet.json` manifest parsing.
- Ignored local resource reports are surfaced in the compact right-click menu.
- Atlas-based `idle` animation with manifest-defined frame timing.
- Runtime animation state can switch by animation id for behavior states, with idle fallback for resources that do not define optional animations.
- Drag-to-move window behavior with persisted position.
- Auxiliary-window right-click menu for status, pet switching, size controls, always-on-top, resource refresh, config reset, recovery, and quit.
- Main and auxiliary window placement guard against display API failure.
- App-specific macOS icon assets.
- Matching project-specific Windows application icon and product metadata.
- Config persistence through `SettingsStore`.
- Runtime behavior managed through `PetController` and `PetState`.

## Known Limitations

- Right-click menu visuals are still compact and utility-focused rather than final production styling.
- The app is ad-hoc signed, not Developer ID signed or notarized. First launch requires right-click Open.
- The Windows internal-alpha candidate is unsigned and may trigger Microsoft
  Defender SmartScreen.
- macOS remains the only validated platform until the Windows release checklist
  passes.

## Requirements

- Flutter SDK compatible with Dart `^3.11.5`
- macOS for the validated desktop target
- Windows with a supported Flutter desktop toolchain for candidate validation

## Run

```sh
flutter pub get
flutter run -d macos
```

Windows:

```bat
flutter pub get
flutter run -d windows
```

## Build And Package

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

Build a DMG:

```sh
bash scripts/package_dmg.sh
```

Output: `dist/Desktop Pet-<version>.dmg`

Windows release zip and SHA-256:

```bat
scripts\package_windows.bat
```

Outputs:

```text
dist/Desktop Pet-<version>-windows-x64.zip
dist/Desktop Pet-<version>-windows-x64.zip.sha256
```

## Install The Windows Internal Alpha

1. Download the zip and its `.sha256` file into the same directory.
2. Verify the zip in PowerShell:

   ```powershell
   Get-FileHash "Desktop Pet-0.6.0-windows-x64.zip" -Algorithm SHA256
   ```

   Confirm that the reported hash matches the first value in the `.sha256`
   file.
3. Extract the entire zip to a normal directory. Do not run the executable from
   inside the archive.
4. Launch `DesktopPet.exe`. Because the internal alpha is unsigned, Microsoft
   Defender SmartScreen may require **More info** followed by **Run anyway**.
5. To uninstall, quit Desktop Pet, delete the extracted directory, and remove
   `%USERPROFILE%\.codex\pets` only if its locally installed pets are no longer
   needed. User preferences can be removed from Windows app settings data when
   a completely clean reset is required.

Only use the SmartScreen exception for an artifact whose SHA-256 matches the
value supplied by the internal release owner.

## Install From DMG

1. Double-click the DMG to mount it.
2. Drag `Desktop Pet` into `Applications`.
3. For the first launch, right-click the app in Applications and select **Open**.
4. When the Gatekeeper dialog appears, click **Open**.
5. Later launches work with a normal double-click.

## macOS Desktop Behavior

- The main pet window is transparent, borderless, fixed-size, and draggable.
- The app remains a normal Dock app in the macOS alpha.
- The pet window is configured always-on-top by default and visible across Spaces.
- The right-click menu opens in a temporary auxiliary window, is skipped from the task switcher, and closes when it loses focus.
- If display lookup fails, the app falls back to a safe on-screen position instead of failing startup.

## Verify

```sh
dart format lib test
flutter analyze
flutter test
flutter build macos --debug
flutter build macos --release
bash scripts/package_dmg.sh
```

Manual smoke checklist for the macOS alpha:

- Launch, drag the pet, quit, and relaunch to confirm position persistence.
- Open the right-click menu near each screen edge and confirm it stays visible.
- Click away from the menu and confirm the auxiliary window closes.
- Switch between bundled and local resources, then refresh resources.
- Repeat the menu open and edge-position checks on each connected display.

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

Invalid manifests, unsafe relative paths, missing spritesheets, missing atlas data, and resources without an `idle` animation are ignored by runtime resource loading. Ignored local resources are summarized in the right-click menu. Invalid bundled resources should fail initialization.

## Architecture

```text
lib/
├── app/
│   ├── app.dart
│   └── pet_menu_window_app.dart
├── desktop/
│   ├── auxiliary_window_arguments.dart
│   ├── auxiliary_window_bootstrap.dart
│   ├── auxiliary_window_controller.dart
│   ├── desktop_auxiliary_window_controller.dart
│   ├── desktop_window_controller.dart
│   ├── macos_window_bootstrap.dart
│   ├── platform_capabilities.dart
│   ├── window_bootstrap.dart
│   └── windows_window_bootstrap.dart
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

Main window runtime flow:

```text
main.dart
  -> SettingsStore
  -> WindowBootstrap (MacosWindowBootstrap | WindowsWindowBootstrap)
  -> DesktopWindowController
  -> DesktopAuxiliaryWindowController
  -> App
       -> PetResourceRepository
       -> PetController
       -> PetView
            -> PetHitArea
            -> PetActor
```

Auxiliary menu window runtime flow:

```text
main.dart
  -> AuxiliaryWindowArguments
  -> AuxiliaryWindowBootstrap
  -> PetMenuWindowApp
       -> PetContextMenu
```

## Windows Validation Checklist

Windows is prepared as an internal-alpha candidate but is not a supported
release target yet. Use [WINDOWS_INTERNAL_ALPHA_CHECKLIST.md](WINDOWS_INTERNAL_ALPHA_CHECKLIST.md)
to record the final Windows-host gate. At minimum:

- `scripts/package_windows.bat`
- Verify the generated SHA-256 and launch from the extracted packaged zip.
- Transparent borderless window rendering.
- Always-on-top behavior.
- Drag-to-move and persisted position.
- Right-click menu open, actions, and blur-close.
- Local resource discovery from `%USERPROFILE%/.codex/pets` and `CODEX_HOME/pets`.
- Multi-display placement.
- Screen-edge pet/menu positioning.

## Roadmap Summary

See `EVOLUTION_PLAN.md` for the full plan. Near-term priorities:

1. Run and record the macOS v0.5 manual smoke matrix.
2. Add Developer ID signing and notarization before end-user distribution.
3. Validate the Windows scaffold on a Windows host before marking Windows supported.
