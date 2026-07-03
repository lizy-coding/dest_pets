import 'package:desktop_pet/app/pet_app.dart';
import 'package:desktop_pet/desktop/desktop_window_controller.dart';
import 'package:desktop_pet/pet/pet_actor.dart';
import 'package:desktop_pet/pet/pet_package.dart';
import 'package:desktop_pet/pet/pet_package_repository.dart';
import 'package:desktop_pet/settings/pet_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakePetPackageRepository extends PetPackageRepository {
  FakePetPackageRepository(this.pets) : super(localPetsDirectory: '');

  final List<PetPackage> pets;

  @override
  Future<List<PetPackage>> loadAvailablePets() async {
    return pets;
  }
}

void main() {
  testWidgets('renders the desktop pet scene', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final windowController = DesktopWindowController(settings: PetSettings());
    final pet = PetPackage(
      source: PetPackageSource.bundled,
      basePath: PetPackageRepository.defaultBundledBasePath,
      id: 'mq',
      displayName: 'MQ',
      description: 'A calm gray amber-eyed companion cat.',
      spritesheetPath: 'spritesheet.webp',
    );

    await tester.pumpWidget(
      PetApp(
        windowController: windowController,
        settings: PetSettings(),
        petPackageRepository: FakePetPackageRepository([pet]),
      ),
    );
    await tester.pump();

    expect(find.byType(PetActor), findsOneWidget);

    windowController.dispose();
  });
}
