import 'package:desktop_pet/desktop/window_bootstrap.dart';
import 'package:desktop_pet/settings/settings_store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_retriever/screen_retriever.dart';

class TestWindowBootstrap extends DesktopWindowBootstrap {
  TestWindowBootstrap({required PrimaryDisplayProvider primaryDisplayProvider})
    : super(
        settingsStore: SettingsStore(),
        primaryDisplayProvider: primaryDisplayProvider,
      );

  @override
  bool get skipTaskbar => false;
}

void main() {
  test('defaultPosition uses visible display bounds', () async {
    final bootstrap = TestWindowBootstrap(
      primaryDisplayProvider: () async => const Display(
        id: 'display',
        size: Size(1920, 1080),
        visiblePosition: Offset(100, 50),
        visibleSize: Size(1200, 800),
      ),
    );

    expect(await bootstrap.defaultPosition(), const Offset(1068, 618));
  });

  test('safeWindowPosition clamps requested position to display', () async {
    final bootstrap = TestWindowBootstrap(
      primaryDisplayProvider: () async => const Display(
        id: 'display',
        size: Size(800, 600),
        visiblePosition: Offset(10, 20),
        visibleSize: Size(500, 400),
      ),
    );

    expect(
      await bootstrap.safeWindowPosition(const Offset(9999, -10)),
      const Offset(310, 20),
    );
  });

  test('safeWindowPosition falls back when display lookup fails', () async {
    final bootstrap = TestWindowBootstrap(
      primaryDisplayProvider: () async => throw StateError('screen failed'),
    );

    expect(
      await bootstrap.safeWindowPosition(null),
      DesktopWindowBootstrap.fallbackPosition,
    );
    expect(
      await bootstrap.safeWindowPosition(const Offset(44, 55)),
      const Offset(44, 55),
    );
  });
}
