import 'package:desktop_pet/pet/model/pet_config.dart';
import 'package:desktop_pet/settings/settings_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('returns null when no config has been saved', () async {
    SharedPreferences.setMockInitialValues({});

    final store = SettingsStore();

    expect(await store.loadConfig(), isNull);
  });

  test('saves and loads the full pet config', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SettingsStore();
    const config = PetConfig(
      petId: 'local_pet',
      scale: 1.4,
      windowPosition: Offset(12, 34),
      alwaysOnTop: false,
    );

    await store.saveConfig(config);

    expect(await store.loadConfig(), config);
  });

  test('resetConfig clears saved config', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SettingsStore();

    await store.saveConfig(const PetConfig(petId: 'local_pet'));
    await store.resetConfig();

    expect(await store.loadConfig(), isNull);
  });
}
