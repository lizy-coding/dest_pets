# Evolution Plan

This file is the product and architecture guardrail for future work. Keep changes aligned with the current `v0.1.x` architecture. Do not revive removed pre-v0.1 concepts unless a migration milestone explicitly says so.

## Current Baseline

### v0.5-stage Internal macOS Alpha Candidate

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
- Compact menu settings surface for current scale, always-on-top, reset config, refresh resources, recovery, and quit.
- Ignored local resource reasons are surfaced in the compact menu.
- Runtime animation state uses animation identifiers for idle, dragging, and error states; resources without optional animations fall back to `idle`.
- Context menu anchoring from the real cursor screen position.
- Context menu visible-area clamp in `AuxiliaryWindowBootstrap`.
- Main pet window placement has display lookup fallback and clamps persisted positions to the primary visible display.
- Auxiliary context menu placement has display lookup fallback and stays inside visible display bounds when display APIs work.
- Desktop platform capability checks are centralized through `PlatformCapabilities`.
- Local pet directory resolution is testable: `CODEX_HOME/pets` first, then platform home fallback (`HOME` on macOS/Linux, `USERPROFILE` on Windows).
- Repository discovery exposes structured ignored-resource reports while runtime loading still returns only valid resources.
- macOS bundle metadata includes utility app category and high-resolution capability.
- macOS app icon assets are project-specific and generated from the bundled pet atlas.
- Automated tests for model parsing, repository discovery, settings persistence, controller state, menu actions, and cursor anchoring.
- DMG packaging with ad-hoc signing through `scripts/package_dmg.sh`.

Known limitations:

- Right-click menu visuals are basic.
- No broad settings surface by design; settings remain in the compact right-click menu for v0.x.
- Only `idle` is required by resources; optional behavior animations are selected by id when present.
- App has no Developer ID signing or notarization.
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
- Keep the removed settings entry out of the v0.1.x menu until a focused v0.2 surface is implemented.
- Add documented manual smoke coverage notes for multi-display and screen-edge menu positioning.
- Add test seams and automated fallback coverage for display lookup failure in main and auxiliary window placement.
- Centralize desktop platform capability checks in `lib/desktop/platform_capabilities.dart`.
- Remove the unimplemented `settingsPanel` auxiliary window protocol branch.

Remaining tasks:

- Run and record manual smoke coverage for multi-display and screen-edge menu positioning.

Exit criteria:

- `dart format lib test`, `flutter analyze`, `flutter test`, and `flutter build macos --release` pass.
- Manual smoke test covers launch, drag, right-click menu open/action/blur-close, edge positioning, and local resource switch.
- README and release notes match actual behavior.

### v0.2.0 - Focused Settings Surface

Goal: expose current config and recovery paths without creating a broad preferences app.

Status: complete as a compact menu surface.

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

Status: complete for compact menu reporting. Zip/import and richer previews remain future work.

Tasks:

- Use the existing structured validation results for ignored local resources.
- Surface invalid resource reasons in a compact UI.
- Add resource metadata preview where useful.
- Keep bundled resource failure strict.
- Consider zip/import only after validation reporting exists.

Already available before v0.3 UI work:

- `PetResourceDiscoveryResult` separates valid runtime resources from ignored resource reports.
- `PetResourceValidationReport` records ignored directory path, optional resource id, severity, reason code, and message.
- `PetResourceRepository.loadAvailableResources()` still returns only valid resources.
- `PetResourceRepository.loadAvailableResourcesWithReports()` and `discoverLocalResourcesWithReports()` provide the report-bearing API for future UI.
- Invalid local resources do not enter runtime resources.
- Tests cover valid local resources, missing manifest, missing spritesheet, unsafe path, legacy fields, missing atlas, and missing `idle`.
- `PetSettingsSnapshot` carries ignored resource reports to the auxiliary menu window.
- `PetContextMenu` summarizes ignored resource reasons without allowing invalid resources into runtime state.

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

Status: complete for minimal behavior-state routing.

Candidate behavior:

- `dragging`
- `error` or recovery animation
- Future optional behaviors: `clicked`, `sleep`, `walk`

Already available:

- `PetAnimationState` carries an animation id.
- `PetController` switches to `dragging` and `error` animation ids for matching runtime states.
- `PetActor` receives only `PetResource` and `PetAnimationState`.
- `PetActor` falls back to `idle` if a resource does not define the optional animation id.

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

Status: code-complete macOS internal-alpha candidate. Automated release
verification completed on 2026-07-10; manual smoke evidence and end-user
distribution hardening remain pending.

Candidate tasks:

- Optional menu-bar or dock behavior decision.
- Better window placement defaults beyond the current lower-right primary-display default.
- Run and record the documented multi-display manual test matrix.
- Continue hardening crash-free behavior when new screen/display API usage is introduced.

Already available:

- Main window default placement falls back to a safe position if primary display lookup fails.
- Persisted main window positions are clamped to the primary visible display when display data is available.
- Auxiliary menu display lookup falls back instead of failing startup/menu creation.
- macOS bundle metadata includes utility category and high-resolution capability.
- macOS app icon assets are project-specific.
- Automated tests cover these fallback seams.
- `dart format lib test`, `flutter analyze`, and `flutter test` pass.
- macOS debug and release builds pass, and `scripts/package_dmg.sh` produces
  `dist/Desktop Pet-0.5.0.dmg` with ad-hoc signing.

Remaining before publishing the internal-alpha candidate:

- Run and record the manual macOS smoke matrix, including the multi-display
  and screen-edge cases.
- Commit the release source and create the matching version tag so the
  artifact has a traceable source revision.

Implementation rules:

- Native calls stay inside `DesktopWindowController`, `DesktopAuxiliaryWindowController`, and `DesktopWindowBootstrap` subclasses (`MacosWindowBootstrap`, `WindowsWindowBootstrap`) or `AuxiliaryWindowBootstrap`.
- Any new native behavior needs a test seam or explicit manual smoke checklist.
- Do not scatter `window_manager`, `screen_retriever`, or `desktop_multi_window` calls into UI widgets.

Exit criteria:

- Manual macOS smoke test covers restart, Spaces, multiple displays, edge placement, and quit.
- Release docs describe expected dock/menu behavior.

### v0.6.0 - Windows Platform Validation

Goal: validate the Windows desktop integration scaffold and make Windows a supported target.

Remaining tasks:

- Validate Windows behavior on a Windows host before marking Windows supported.
- Run the Windows release build.
- Run the Windows packaging script.
- Record manual Windows smoke results for the checklist below.
- Replace the generated `windows/runner/Runner.rc` product metadata and icon
  before distributing a Windows artifact.
- Add focused Windows bootstrap/capability tests; current automated coverage
  exercises shared fakes and `USERPROFILE` resolution, not Windows plugin
  behavior.
- Fix only issues observed during Windows validation; do not add unverified Windows-only behavior speculatively.

Current validation status:

- No Windows-host release build, packaged zip, runtime smoke result, or
  Windows build artifact has been recorded.
- macOS analysis and unit/widget test results are useful shared-code signals,
  but do not validate Windows window-manager, screen, or auxiliary-window
  plugin behavior.

Already scaffolded before validation:

- Windows native project files exist.
- `WindowsWindowBootstrap` extends `DesktopWindowBootstrap`.
- `DesktopWindowController` depends on the injected `WindowBootstrap` abstraction and has no static `Platform` branch.
- Top-level bootstrap selection lives in `main.dart`.
- Local pet directory resolution supports `USERPROFILE` fallback on Windows.
- `scripts/package_windows.bat` exists.

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
- On a Windows host, `flutter build windows --release` passes.
- On a Windows host, `scripts\package_windows.bat` produces the expected zip.
- `windows/runner/Runner.rc` contains the final product identity, copyright,
  executable naming, and application icon.
- Manual Windows smoke test covers launch, transparent/frameless rendering, always-on-top, drag, right-click menu, blur-close, local resource paths, multi-display, and screen-edge positioning.

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
