part of 'location_bloc.dart';

sealed class LocationEvents extends Equatable {
  const LocationEvents();

  @override
  List<Object> get props => [];
}

class CheckLocationPermission extends LocationEvents {
  const CheckLocationPermission();
}

class RequestLocationPermission extends LocationEvents {
  const RequestLocationPermission();
}

class GetCurrentLocation extends LocationEvents {
  const GetCurrentLocation();
}

class OpenAppSettings extends LocationEvents {
  const OpenAppSettings();
}