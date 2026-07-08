import '../../resources/model/pet_resource.dart';
import 'pet_animation_state.dart';
import 'pet_config.dart';
import 'pet_runtime_mode.dart';

class PetState {
  PetState({
    this.config = const PetConfig(),
    this.resource,
    List<PetResource> availableResources = const [],
    this.runtimeMode = PetRuntimeMode.initializing,
    this.animationState = const PetAnimationState(),
    this.errorMessage,
  }) : availableResources = List.unmodifiable(availableResources);

  final PetConfig config;
  final PetResource? resource;
  final List<PetResource> availableResources;
  final PetRuntimeMode runtimeMode;
  final PetAnimationState animationState;
  final String? errorMessage;

  PetState copyWith({
    PetConfig? config,
    Object? resource = _unset,
    List<PetResource>? availableResources,
    PetRuntimeMode? runtimeMode,
    PetAnimationState? animationState,
    Object? errorMessage = _unset,
  }) {
    return PetState(
      config: config ?? this.config,
      resource: identical(resource, _unset)
          ? this.resource
          : resource as PetResource?,
      availableResources: availableResources ?? this.availableResources,
      runtimeMode: runtimeMode ?? this.runtimeMode,
      animationState: animationState ?? this.animationState,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _unset = Object();
