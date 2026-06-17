import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

part 'location_events.dart';
part 'location_states.dart';

class LocationBloc extends Bloc<LocationEvents, LocationStates> {
  LocationBloc() : super(const LocationStates()) {
    on<CheckLocationPermission>(_onCheckLocationPermission);
    on<RequestLocationPermission>(_onRequestLocationPermission);
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<OpenAppSettings>(_onOpenAppSettings);

    // Check permissions on init
    add(const CheckLocationPermission());
  }

  Future<void> _onCheckLocationPermission(
    CheckLocationPermission event,
    Emitter<LocationStates> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();
      final permissionGranted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      emit(state.copyWith(
        isLocationServiceEnabled: serviceEnabled,
        isLocationPermissionGranted: permissionGranted,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onRequestLocationPermission(
    RequestLocationPermission event,
    Emitter<LocationStates> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        emit(state.copyWith(
          isLocationServiceEnabled: false,
          isLoading: false,
        ));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        emit(state.copyWith(
          isLocationPermissionGranted: false,
          isLoading: false,
        ));
        return;
      }

      final permissionGranted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      emit(state.copyWith(
        isLocationPermissionGranted: permissionGranted,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocation event,
    Emitter<LocationStates> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final permission = await Geolocator.checkPermission();
      final permissionGranted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (!permissionGranted) {
        add(const RequestLocationPermission());
        emit(state.copyWith(isLoading: false));
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      emit(state.copyWith(
        currentPosition: position,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onOpenAppSettings(
    OpenAppSettings event,
    Emitter<LocationStates> emit,
  ) async {
    try {
      await Geolocator.openAppSettings();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}