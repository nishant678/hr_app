part of 'location_bloc.dart';

class LocationStates extends Equatable {
  const LocationStates({
    this.isLocationPermissionGranted = false,
    this.isLocationServiceEnabled = false,
    this.currentPosition,
    this.isLoading = false,
    this.error = '',
  });

  final bool isLocationPermissionGranted;
  final bool isLocationServiceEnabled;
  final Position? currentPosition;
  final bool isLoading;
  final String error;

  LocationStates copyWith({
    bool? isLocationPermissionGranted,
    bool? isLocationServiceEnabled,
    Position? currentPosition,
    bool? isLoading,
    String? error,
  }) {
    return LocationStates(
      isLocationPermissionGranted: isLocationPermissionGranted ?? this.isLocationPermissionGranted,
      isLocationServiceEnabled: isLocationServiceEnabled ?? this.isLocationServiceEnabled,
      currentPosition: currentPosition ?? this.currentPosition,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        isLocationPermissionGranted,
        isLocationServiceEnabled,
        currentPosition,
        isLoading,
        error,
      ];
}