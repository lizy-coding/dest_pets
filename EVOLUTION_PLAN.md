# Evolution Plan

This file is the product and architecture guardrail for future work. Keep changes aligned with the current `v0.1.x` architecture. Do not revive removed pre-v0.1 concepts unless a migration milestone explicitly says so.

## Current Baseline

### v0.1.1 Internal macOS Alpha

What works:

- Transparent, borderless 200x200 macOS desktop pet window.
- Bundled `default_pet` atlas resource.
- Local resource discovery from `${CODEX_HOME:-$HOME/.codex}/pets/<pet-id>/`.
- Strict normalized `pet.json` manifest parsing.
- Atlas-driven `idle` animation.
- Drag-to-move window behavior with persisted position.
- Persisted pet id, scale, window position, and always-on-top preference.
- Auxiliary-window right-click menu.
- Menu actions for pet switching, scale controls, always-on-top, resource refresh, reset config, recovery, and quit.
- Context menu anchoring from the real cursor screen position.
- Context menu visible-area clamp in `AuxiliaryWindowBootstrap`.
- Automated tests for model parsing, repository discovery, settings persistence, controller state, menu actions, and cursor anchoring.
- DMG packaging with ad-hoc signing through `scripts/package_dmg.sh`.

Known limitations:

- Right-click menu visuals are basic.
- No full settings surface yet.
- Local resource validation failures are only ignored, not reported to the user.
- Only `idle` animation is used by runtime behavior.
- App has no production icon, Developer ID signing, or notarization.
- Windows support is scaffolded but not yet fully validated.

## Product Direction

The app should stay a lightweight desktop utility:

- Local-first: prefer local assets and deterministic behavior over network features.
- Small surface area: add focused controls before adding large settings pages.
- Manifest-driven: rendering and animation data come from manifests, not UI assumptions.
- State-machine first: runtime mode belongs in `PetRuntimeMode` and controller state, not nullable resource hacks or widget-local flags.
- Controller boundary: UI reads `PetController.state` and dispatches controller methods.
- Native boundary: desktop/window behavior stays in `lib/desktop/`.
- Resource boundary: parsing, validation, and discovery stay in `lib/resources/`.

## Explicit Non-Goals For v0.x

Do not spend v0.x effort on:

- Cloud sync, accounts, remote pet marketplaces, or telemetry.
- Cross-platform UX promises beyond macOS and Windows validation.
- A large preferences app before resource validation and menu polish are stable.
- Backward compatibility for pre-v0.1 manifests or old SharedPreferences keys.
- A new rendering framework while the current atlas renderer is sufficient.
- Hardcoded pet behavior tied directly to atlas row numbers in widgets.

## Milestones

### v0.1.x - Alpha Stabilization

Goal: make the existing alpha reliable without expanding the architecture.

Completed in `v0.1.1`:

- Move the right-click menu into an auxiliary desktop window.
- Fix context menu anchoring by using the cursor screen position.
- Add menu actions for refresh, reset, recovery, always-on-top, and quit.
- Add tests for auxiliary menu action flow and cursor anchoring.

Remaining tasks:

- Improve `PetContextMenu` visual polish while keeping it lightweight.
- Add manual smoke coverage notes for multi-display and screen-edge menu positioning.
- Add a small visible status/error affordance in the menu or pet surface.
- Decide whether the unimplemented settings panel placeholder should stay as a future hook or be removed until v0.2.

Exit criteria:

- `dart format lib test`, `flutter analyze`, `flutter test`, and `flutter build macos --release` pass.
- Manual smoke test covers launch, drag, right-click menu open/action/blur-close, edge positioning, and local resource switch.
- README and release notes match actual behavior.

### v0.2.0 - Focused Settings Surface

Goal: expose current config and recovery paths without creating a broad preferences app.

Allowed scope:

- Small settings panel or compact menu extension.
- Always-on-top control.
- Scale controls with current value display.
- Reset config.
- Refresh resources.
- Error display and recovery action.

Implementation rules:

- Config continues through `PetConfig` and `SettingsStore`.
- UI reads only `PetController.state`.
- UI dispatches only `PetController` or desktop controller methods.
- No direct `SharedPreferences` calls outside `SettingsStore`.
- No full settings page unless it remains small, focused, and backed by tests.

Exit criteria:

- Controller tests cover every config mutation path.
- Widget tests cover settings/menu actions and dismissal behavior.
- Native window behavior is guarded or faked in tests.

### v0.3.0 - Resource Validation And Management

Goal: make local pet resources understandable and debuggable.

Tasks:

- Return structured validation results for ignored local resources.
- Surface invalid resource reasons in a compact UI.
- Add resource metadata preview where useful.
- Keep bundled resource failure strict.
- Consider zip/import only after validation reporting exists.

Implementation rules:

- Manifest parsing stays strict.
- No silent compatibility for old fields such as `displayName` or `spritesheetPath`.
- Unsafe paths stay invalid.
- Repository discovery returns only valid resources to runtime.
- Validation reporting must not allow invalid resources into `PetState.resource`.

Exit criteria:

- Invalid local resources never break startup.
- Users can see why a local resource was ignored.
- Repository tests cover valid, invalid, unsafe path, missing image, missing atlas, and missing `idle` cases.

### v0.4.0 - Animation Behavior Expansion

Goal: add pet behavior without weakening renderer boundaries.

Candidate behavior:

- `clicked`
- `sleep`
- `walk`
- `dragging`
- `error` or recovery animation

Implementation rules:

- Extend `PetAnimationState` with animation identifiers or transition metadata.
- `PetActor` receives `PetResource` and `PetAnimationState` only.
- `PetActor` must not know settings, repositories, controller methods, or menu actions.
- UI must not branch on atlas rows, frame indexes, or frame durations.
- Manifest validation must define which animations are optional and which are required.

Exit criteria:

- Controller tests cover state transitions.
- Animation tests cover manifest selection and timing behavior.
- Existing `idle`-only resources remain valid unless a versioned manifest migration is planned.

### v0.5.0 - Desktop Integration Polish

Goal: make the macOS utility feel intentional while staying lightweight.

Candidate tasks:

- App icon.
- Better bundle metadata.
- Optional menu-bar or dock behavior decision.
- Better window placement defaults.
- Improved multi-display behavior tests or documented manual test matrix.
- Crash-free behavior when screen/display APIs fail.

Implementation rules:

- Native calls stay inside `DesktopWindowController`, `DesktopAuxiliaryWindowController`, and `DesktopWindowBootstrap` subclasses (`MacosWindowBootstrap`, `WindowsWindowBootstrap`) or `AuxiliaryWindowBootstrap`.
- Any new native behavior needs a test seam or explicit manual smoke checklist.
- Do not scatter `window_manager`, `screen_retriever`, or `desktop_multi_window` calls into UI widgets.

Exit criteria:

- Manual macOS smoke test covers restart, Spaces, multiple displays, edge placement, and quit.
- Release docs describe expected dock/menu behavior.

### v0.6.0 - Windows Platform Validation

Goal: validate the Windows desktop integration scaffold and make Windows a supported target.

Tasks:

- Create `windows/` native project scaffold.
- Implement `WindowsWindowBootstrap` extending `DesktopWindowBootstrap`.
- Decouple `DesktopWindowController` from `MacosWindowBootstrap` through the `WindowBootstrap` abstraction.
- Move platform dispatch to `main.dart`.
- Fix local resource path resolution for Windows (`%USERPROFILE%` fallback).
- Create Windows packaging script (`scripts/package_windows.bat`).

Implementation rules:

- Shared window initialization logic lives in `DesktopWindowBootstrap`.
- Platform-specific hooks (`skipTaskbar`, `applyPlatformSpecificOptions`) are overridden in concrete bootstraps.
- No `setVisibleOnAllWorkspaces` call on Windows (API does not exist).
- `DesktopWindowController` accepts an optional `WindowBootstrap` via dependency injection.

Exit criteria:

- `flutter create --platforms=windows` succeeds and the scaffold is complete.
- `flutter analyze` and `flutter test` pass on macOS.
- Windows build configuration and packaging script are ready for validation.
- Architecture decoupling is verified: `DesktopWindowController` has no static `Platform` branch.

### v1.0.0 - Distributable Desktop App

Goal: ship a real end-user desktop build with verified macOS and Windows support.

Tasks:

- Add production app icon.
- Configure code signing for macOS (Developer ID, notarization) and Windows.
- Review bundle identifier and copyright.
- Decide final artifact formats.
- Add signed release checklist for both platforms.
- Verify install/open behavior on clean macOS and Windows accounts.

Exit criteria:

- Release artifacts are signed and notarized (macOS) / code-signed (Windows).
- Gatekeeper opens the app through normal double-click after install.
- Windows build passes SmartScreen without blocking.
- README includes user-facing install, troubleshooting, and uninstall notes for both platforms.

## Architecture Guardrails

### Required Boundaries

- `main.dart`: runtime entry selection and top-level bootstrap only.
- `lib/app/`: app composition, providers, and menu action binding.
- `lib/desktop/`: native window, auxiliary window, display, cursor, and desktop integration.
- `lib/pet/controller/`: runtime behavior and state transitions.
- `lib/pet/model/`: runtime and menu data models.
- `lib/pet/view/`: rendering and interaction widgets only.
- `lib/pet/animation/`: animation timing and atlas frame selection.
- `lib/resources/`: manifest parsing, resource validation, and discovery.
- `lib/settings/`: persistent settings access through `SettingsStore`.

### Dependency Flow

Main window:

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

Auxiliary context menu window:

```text
main.dart
  -> AuxiliaryWindowArguments
  -> AuxiliaryWindowBootstrap
  -> PetMenuWindowApp
       -> PetContextMenu
```

### Do

- Put persistable config in `PetConfig`.
- Put render/runtime state in `PetState`.
- Put runtime mode in `PetRuntimeMode`.
- Put resource parsing and validation in `lib/resources/`.
- Put SharedPreferences access only in `SettingsStore`.
- Put native window calls only in desktop boundary classes.
- Add tests at the same layer where behavior changes.
- Keep releases synchronized across `pubspec.yaml`, `CHANGELOG.md`, `RELEASE.md`, `README.md`, macOS metadata, and Windows metadata when needed.

### Do Not

- Recreate `PetPackage` or `PetPackageRepository`.
- Recreate `PetAppearanceController`, `PetAppearanceState`, `PetSettings`, or `PetSettingsStore`.
- Add direct `SharedPreferences` calls outside `SettingsStore`.
- Add UI-driven resource fallback logic.
- Use nullable resources or ad hoc booleans as runtime mode.
- Add compatibility for old manifest fields without a written versioned migration.
- Hardcode atlas frame data in UI.
- Let `PetActor` know about settings, repositories, menu actions, or controllers.
- Add broad settings pages or import flows ahead of the planned milestones.

## Testing Expectations

- Manifest parser changes need model tests.
- Repository discovery changes need valid and invalid local resource tests.
- Settings key changes need `SettingsStore` tests.
- Runtime mode changes need `PetController` tests.
- Menu, settings, and interaction changes need widget tests.
- Desktop/window changes need a fakeable abstraction or a documented manual smoke test.
- Controllers created in tests must be disposed.

## Release Checklist

Before every tagged release:

```sh
dart format lib test
flutter analyze
flutter test
flutter build macos --debug
flutter build macos --release
bash scripts/package_dmg.sh
```

Before Windows-tagged releases also run:

```bat
flutter build windows --release
scripts\package_windows.bat
```

Update release files:

- `pubspec.yaml`
- `CHANGELOG.md`
- `RELEASE.md`
- `README.md`
- `macos/Runner/Configs/AppInfo.xcconfig` if app identity changes
- `scripts/package_dmg.sh` if artifact behavior changes
- `scripts/package_windows.bat` if artifact behavior changes
- `windows/runner/main.cpp` if native window behavior changes

Publish:

```sh
git tag -a vX.Y.Z -m "vX.Y.Z"
git push origin main
git push origin vX.Y.Z
```

If using GitHub Releases, upload the generated DMG from:

```text
dist/Desktop Pet-<version>.dmg
```

And/or the Windows zip from:

```text
dist/Desktop Pet-<version>-windows-x64.zip
```
