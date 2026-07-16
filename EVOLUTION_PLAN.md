# Evolution Plan

This file is the product and architecture guardrail for future work. Keep
changes aligned with the current v0.x architecture. Do not revive removed
pre-v0.1 concepts unless a migration milestone explicitly says so.

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
- Android and iOS project directories are generated scaffolds, not validated
  product targets.
- iOS work is deliberately deferred while Apple Developer Program enrollment
  is unavailable; Android is the next mobile target.

## Product Direction

The app should stay a lightweight local pet utility. Desktop and Android
surfaces may differ, but they share the same resource and runtime contracts.

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
- iOS development, signing, and distribution until Apple Developer Program
  enrollment is available.
- Android system-overlay, cross-app always-on-top, or click-through behavior;
  the first Android release is an in-app pet experience.
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

Status: source-prepared Windows internal-alpha candidate. Windows-host build,
artifact verification, and manual smoke evidence remain required before the
candidate can be published.

Remaining tasks:

- Validate Windows behavior on a Windows host before marking Windows supported.
- Run the Windows release build.
- Run the Windows packaging script.
- Record manual Windows smoke results for the checklist below.
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

Completed candidate preparation:

- Windows runner product identity, copyright, executable naming, and icon use
  the Desktop Pet release identity instead of generated Flutter defaults.
- Windows packaging removes stale release output, fails on build/archive errors,
  verifies required runtime files, and emits a SHA-256 checksum.
- Focused tests cover Windows platform capabilities, taskbar behavior, and the
  shared display-placement path.
- `WINDOWS_INTERNAL_ALPHA_CHECKLIST.md` records build, artifact, smoke, and
  release-approval evidence against one exact commit and checksum.

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

### v0.7.0 - Android In-App Pet Foundation

Goal: make the existing pet runtime usable as a normal Android application
without carrying desktop window assumptions into the mobile target.

Status: planned. iOS is explicitly deferred; this milestone must not add iOS
signing, distribution, or Store work.

Product contract:

- The pet renders inside the application, within the system safe area; it is
  not a system overlay and does not remain above other applications.
- Long press opens the compact pet menu. There is no secondary-click or
  auxiliary-window dependency on Android.
- A drag repositions the pet inside the mobile canvas only. It must not try to
  move the OS window.
- Desktop-only controls such as always-on-top, click-through, frameless
  windows, taskbar behavior, and desktop screen coordinates are hidden or
  represented as unsupported on Android.
- The initial Android release uses the bundled pet resource only. Android
  pet-pack import follows in v0.8.0.

Tasks:

- Split runtime startup into desktop and mobile entry paths. Android startup
  must not import or initialize `window_manager`, `screen_retriever`, or
  `desktop_multi_window`.
- Add a mobile surface/controller boundary that satisfies the UI's pet-surface
  needs without native desktop window calls. Keep `PetController` as the
  single UI-facing behavior controller.
- Create a mobile pet view that uses touch gestures, `SafeArea`, responsive
  layout, and a mobile menu surface such as a bottom sheet.
- Define a versioned `PetConfig` migration before storing Android canvas
  placement. Store normalized canvas coordinates; do not reuse desktop window
  x/y values for a different meaning.
- Add lifecycle handling so animation and transient work pause in the
  background and resume safely when the app returns to the foreground.
- Audit every dependency for Android support and isolate or remove
  desktop-only plugins from the Android dependency path.
- Set Android app identity, icon, launch screen, minimum SDK, target SDK, and
  release-signing strategy. The generated `com.example` metadata is not
  acceptable for a distributable artifact.

Implementation rules:

- Shared models, resource parsing, atlas rendering, and `SettingsStore` stay
  platform-neutral.
- Keep desktop-only native behavior under `lib/desktop/`; do not add Android
  conditionals to widgets or `PetController`.
- Do not create a `PetScene` or revive removed appearance/settings models.
- Do not request `SYSTEM_ALERT_WINDOW` or equivalent overlay permissions in
  this milestone.
- Mobile resource discovery must fail safely to bundled resources until the
  explicit import milestone supplies an app-sandbox resource location.

Exit criteria:

- `flutter analyze` and `flutter test` pass without native desktop plugin
  side effects in mobile-targeted tests.
- Android debug and release builds succeed on a supported Android toolchain.
- Manual smoke tests pass on an emulator and at least one physical Android
  device: launch, safe-area layout, touch drag, long-press menu, scale,
  resource refresh, background/foreground recovery, and rotation policy.
- No Android startup path initializes desktop window or auxiliary-window
  plugins.
- Mobile widget tests cover touch-menu opening/dismissal, unsupported desktop
  controls, responsive layout, and lifecycle recovery.

### v0.8.0 - Android Pet Pack Import

Goal: let non-technical Android users install a verified pet without seeing
atlas files, manifests, or resource directories.

Scope:

- Accept a complete `.pet.zip` through the Android system document picker.
- Extract into a temporary app-sandbox directory, validate with the existing
  resource parser and repository rules, then install atomically into the
  Android app's private resource directory.
- Show a simple preview, name, success state, and actionable invalid-package
  reason. Never ask the user to edit `pet.json` or a spritesheet.
- Support delete and replacement confirmation for imported pets.

Implementation rules:

- A pet pack contains the project's current strict `pet.json` and
  `spritesheet.webp`; do not accept legacy manifest fields.
- Keep document-picker and filesystem calls outside UI widgets and outside
  `PetController`.
- Failed, cancelled, oversized, or invalid imports must not modify active
  resources or leave partial directories behind.
- Do not add cloud accounts, a marketplace, or image generation to the import
  milestone.

Exit criteria:

- Tests cover valid, malformed, unsafe-path, missing-image, duplicate-id,
  cancellation, and interrupted-import cases.
- A user can import, preview, switch, restart, and delete a pet on a physical
  Android device without accessing the filesystem manually.
- The same invalid-resource reasons remain visible in the compact menu after
  refresh.

### v1.0.0 - Distributable macOS, Windows, and Android App

Goal: ship a real end-user build with verified macOS, Windows, and Android
support. iOS remains deferred until its account and distribution prerequisites
are available.

Tasks:

- Add production app icon.
- Configure code signing for macOS (Developer ID, notarization), Windows, and
  Android.
- Review bundle/package identifiers, copyright, icons, and privacy notices.
- Decide final artifact formats, including Android APK and/or App Bundle.
- Add signed release checklists for all supported platforms.
- Verify install/open behavior on clean macOS, Windows, and Android devices.

Exit criteria:

- Release artifacts are signed and notarized (macOS) / code-signed (Windows
  and Android).
- Gatekeeper opens the app through normal double-click after install.
- Windows build passes SmartScreen without blocking.
- Android artifact installs, launches, upgrades, and uninstalls successfully
  on supported devices.
- README includes user-facing install, troubleshooting, and uninstall notes
  for all supported platforms.

## Architecture Guardrails

### Required Boundaries

- `main.dart`: runtime entry selection and top-level bootstrap only.
- `lib/app/`: app composition, providers, and menu action binding.
- `lib/desktop/`: native window, auxiliary window, display, cursor, and desktop integration.
- `lib/mobile/`: Android app-surface, touch interaction, lifecycle, and
  mobile-only platform integration after v0.7.0.
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

Android app surface after v0.7.0:

```text
main.dart
  -> SettingsStore
  -> MobilePetSurfaceController
  -> App
       -> PetResourceRepository
       -> PetController
       -> MobilePetView
            -> PetHitArea
            -> PetActor
```

### Do

- Put persistable config in `PetConfig`.
- Put render/runtime state in `PetState`.
- Put runtime mode in `PetRuntimeMode`.
- Put resource parsing and validation in `lib/resources/`.
- Put SharedPreferences access only in `SettingsStore`.
- Put native window calls only in desktop boundary classes.
- Keep Android document-picker, lifecycle, and app-sandbox filesystem calls in
  mobile/resource boundaries, never in widgets or `PetController`.
- Add tests at the same layer where behavior changes.
- Keep releases synchronized across `pubspec.yaml`, `CHANGELOG.md`,
  `RELEASE.md`, `README.md`, and all affected platform metadata.

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
- Android surface changes need touch, safe-area/responsive-layout, lifecycle,
  and no-desktop-plugin-side-effect coverage.
- Android import changes need temporary-directory cleanup and atomic-install
  tests in addition to resource validation tests.
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

Then complete `WINDOWS_INTERNAL_ALPHA_CHECKLIST.md` against the generated zip.
Do not create or push the Windows version tag while any required row is not
passed.

Before Android-tagged releases also run:

```sh
flutter build apk --debug
flutter build apk --release
```

Then run the recorded Android physical-device smoke matrix. A release APK is
not a Play-distribution artifact until the selected Android signing and
distribution requirements have been completed.

Update release files:

- `pubspec.yaml`
- `CHANGELOG.md`
- `RELEASE.md`
- `README.md`
- `macos/Runner/Configs/AppInfo.xcconfig` if app identity changes
- `scripts/package_dmg.sh` if artifact behavior changes
- `scripts/package_windows.bat` if artifact behavior changes
- `windows/runner/main.cpp` if native window behavior changes
- `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`,
  Android app icons, and Android signing configuration when Android release
  behavior or identity changes

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

Upload the matching checksum file alongside it:

```text
dist/Desktop Pet-<version>-windows-x64.zip.sha256
```
