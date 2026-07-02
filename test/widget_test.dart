import 'package:desktop_pet/app/pet_app.dart';
import 'package:desktop_pet/desktop/desktop_window_controller.dart';
import 'package:desktop_pet/pet/pet_actor.dart';
import 'package:desktop_pet/settings/pet_settings.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the desktop pet scene', (tester) async {
    final windowController = DesktopWindowController(settings: PetSettings());

    await tester.pumpWidget(PetApp(windowController: windowController));
    await tester.pump();

    expect(find.byType(PetActor), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    windowController.dispose();
  });
}
