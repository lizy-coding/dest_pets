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
}

class PetResourceDiscoveryResult {
  const PetResourceDiscoveryResult({
    required this.validResources,
    required this.ignoredResources,
  });

  final List<PetResource> validResources;
  final List<PetResourceValidationReport> ignoredResources;
}
