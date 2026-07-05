import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../pet/model/pet_settings_snapshot.dart';

enum AuxiliaryWindowType { contextMenu, settingsPanel }

class AuxiliaryWindowArguments {
  const AuxiliaryWindowArguments.contextMenu({
    required this.anchorGlobalPosition,
    required this.snapshot,
  }) : type = AuxiliaryWindowType.contextMenu;

  const AuxiliaryWindowArguments.settingsPanel()
    : type = AuxiliaryWindowType.settingsPanel,
      anchorGlobalPosition = Offset.zero,
      snapshot = null;

  final AuxiliaryWindowType type;
  final Offset anchorGlobalPosition;
  final PetSettingsSnapshot? snapshot;

  factory AuxiliaryWindowArguments.fromJson(Map<String, dynamic> json) {
    final type = _auxiliaryWindowTypeFromJson(json['type']);
    return switch (type) {
      AuxiliaryWindowType.contextMenu => AuxiliaryWindowArguments.contextMenu(
        anchorGlobalPosition: _offsetFromJson(
          json['anchorGlobalPosition'] as Map<String, dynamic>,
        ),
        snapshot: PetSettingsSnapshot.fromJson(
          json['snapshot'] as Map<String, dynamic>,
        ),
      ),
      AuxiliaryWindowType.settingsPanel =>
        const AuxiliaryWindowArguments.settingsPanel(),
    };
  }

  factory AuxiliaryWindowArguments.fromJsonString(String value) {
    if (value.isEmpty) {
      throw const FormatException('Auxiliary window arguments are empty.');
    }

    return AuxiliaryWindowArguments.fromJson(
      jsonDecode(value) as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      if (type == AuxiliaryWindowType.contextMenu) ...{
        'anchorGlobalPosition': _offsetToJson(anchorGlobalPosition),
        'snapshot': snapshot?.toJson(),
      },
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

AuxiliaryWindowType _auxiliaryWindowTypeFromJson(Object? value) {
  if (value is! String) {
    throw const FormatException('Auxiliary window type must be a string.');
  }

  for (final type in AuxiliaryWindowType.values) {
    if (type.name == value) {
      return type;
    }
  }

  throw FormatException('Unknown auxiliary window type "$value".');
}

Offset _offsetFromJson(Map<String, dynamic> json) {
  return Offset((json['dx'] as num).toDouble(), (json['dy'] as num).toDouble());
}

Map<String, dynamic> _offsetToJson(Offset offset) {
  return {'dx': offset.dx, 'dy': offset.dy};
}
