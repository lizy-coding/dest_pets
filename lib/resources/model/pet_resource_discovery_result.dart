import 'pet_resource.dart';

enum PetResourceValidationSeverity { warning, error }

enum PetResourceValidationReason {
  missingManifest,
  invalidManifest,
  missingSpritesheet,
  unreadableResource,
  unreadableDirectory,
}

class PetResourceValidationReport {
  const PetResourceValidationReport({
    required this.directoryPath,
    this.resourceId,
    required this.severity,
    required this.reason,
    required this.message,
  });

  final String directoryPath;
  final String? resourceId;
  final PetResourceValidationSeverity severity;
  final PetResourceValidationReason reason;
  final String message;

  factory PetResourceValidationReport.fromJson(Map<String, dynamic> json) {
    return PetResourceValidationReport(
      directoryPath: json['directoryPath'] as String,
      resourceId: json['resourceId'] as String?,
      severity: _severityFromJson(json['severity']),
      reason: _reasonFromJson(json['reason']),
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'directoryPath': directoryPath,
      if (resourceId != null) 'resourceId': resourceId,
      'severity': severity.name,
      'reason': reason.name,
      'message': message,
    };
  }
}

class PetResourceDiscoveryResult {
  const PetResourceDiscoveryResult({
    required this.validResources,
    required this.ignoredResources,
  });

  final List<PetResource> validResources;
  final List<PetResourceValidationReport> ignoredResources;
}

PetResourceValidationSeverity _severityFromJson(Object? value) {
  if (value is! String) {
    throw const FormatException(
      'Pet resource validation severity must be a string.',
    );
  }

  for (final severity in PetResourceValidationSeverity.values) {
    if (severity.name == value) {
      return severity;
    }
  }

  throw FormatException('Unknown pet resource validation severity "$value".');
}

PetResourceValidationReason _reasonFromJson(Object? value) {
  if (value is! String) {
    throw const FormatException(
      'Pet resource validation reason must be a string.',
    );
  }

  for (final reason in PetResourceValidationReason.values) {
    if (reason.name == value) {
      return reason;
    }
  }

  throw FormatException('Unknown pet resource validation reason "$value".');
}
