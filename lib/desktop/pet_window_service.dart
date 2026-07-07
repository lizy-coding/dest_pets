import 'package:flutter/widgets.dart';

import 'platform_capabilities.dart';

abstract interface class PetWindowService {
  PlatformCapabilities get capabilities;

  Future<void> initialize();

  Future<void> setAlwaysOnTop(bool value);

  Future<void> setTransparent(bool value);

  Future<void> setFrameless(bool value);

  Future<void> setClickThrough(bool value);

  Future<void> setSize(Size size);

  Future<void> setPosition(Offset position);

  Future<Offset?> getPosition();

  Future<void> show();

  Future<void> hide();

  Future<void> startDragging();

  Future<void> close();

  void dispose();
}
