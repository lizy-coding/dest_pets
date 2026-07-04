import 'pet_resource.dart';

class PetAppearanceState {
  PetAppearanceState({
    this.currentResourceId,
    this.selectedResource,
    List<PetResource> availableResources = const [],
    this.scale = defaultScale,
    this.isLoading = false,
    this.errorMessage,
  }) : availableResources = List.unmodifiable(availableResources);

  static const double defaultScale = 1.0;

  final String? currentResourceId;
  final PetResource? selectedResource;
  final List<PetResource> availableResources;
  final double scale;
  final bool isLoading;
  final String? errorMessage;

  PetAppearanceState copyWith({
    Object? currentResourceId = _unset,
    Object? selectedResource = _unset,
    List<PetResource>? availableResources,
    double? scale,
    bool? isLoading,
    Object? errorMessage = _unset,
  }) {
    return PetAppearanceState(
      currentResourceId: identical(currentResourceId, _unset)
          ? this.currentResourceId
          : currentResourceId as String?,
      selectedResource: identical(selectedResource, _unset)
          ? this.selectedResource
          : selectedResource as PetResource?,
      availableResources: availableResources ?? this.availableResources,
      scale: scale ?? this.scale,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _unset = Object();
