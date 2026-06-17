import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hr_app/models/live_location.dart';
import 'package:hr_app/models/pending_location.dart';
import 'package:hr_app/repositories/location_repository.dart';
import 'package:hr_app/services/location/location_permission_service.dart';
import 'package:hr_app/services/location/location_storage_service.dart';
import 'package:hr_app/services/location/location_sync_service.dart';
import 'package:hr_app/utils/location_rules.dart';
import 'package:hr_app/utils/logger.dart';

const _trackingStateKey = 'trackingActive';
const _trackingEmployeeKey = 'trackingEmployeeId';

/// Background service entry point used by flutter_background_service.
@pragma('vm:entry-point')
Future<void> _backgroundServiceOnStart(ServiceInstance service) async {
  final permissionService = LocationPermissionService();
  final storageService = LocationStorageService();
  final syncService = LocationSyncService(
    repository: LocationRepository(),
    storageService: storageService,
  );

  final worker = _BackgroundLocationWorker(
    service: service,
    permissionService: permissionService,
    storageService: storageService,
    syncService: syncService,
  );

  await worker.start();
}

class _BackgroundLocationWorker {
  _BackgroundLocationWorker({
    required this.service,
    required this.permissionService,
    required this.storageService,
    required this.syncService,
  });

  final ServiceInstance service;
  final LocationPermissionService permissionService;
  final LocationStorageService storageService;
  final LocationSyncService syncService;
  late final SharedPreferences storage;

  StreamSubscription<Position>? _positionSubscription;
  Timer? _staticTimer;
  bool _trackingActive = false;
  String? _employeeId;

  Future<void> start() async {
    storage = await SharedPreferences.getInstance();

    if (service is AndroidServiceInstance) {
      final androidService = service as AndroidServiceInstance;
      androidService.on('setAsForeground').listen((event) {
        androidService.setAsForegroundService();
        androidService.setForegroundNotificationInfo(
          title: 'Employee attendance tracking',
          content: 'Tracking active in background',
        );
      });
    }

    _trackingActive = storage.getBool(_trackingStateKey) == true;
    _employeeId = storage.getString(_trackingEmployeeKey);

    service.on('startTracking').listen((event) {
      _trackingActive = true;
      _employeeId = event?['employeeId'] as String?;
      storage.setBool(_trackingStateKey, true);
      if (_employeeId != null) {
        storage.setString(_trackingEmployeeKey, _employeeId!);
      }
      _startTrackingLoop();
    });

    service.on('stopTracking').listen((event) async {
      _trackingActive = false;
      await _positionSubscription?.cancel();
      _staticTimer?.cancel();
      service.stopSelf();
    });

    if (_trackingActive && _employeeId != null) {
      _startTrackingLoop();
    }
  }

  void _startTrackingLoop() {
    if (!_trackingActive || _employeeId == null) {
      return;
    }

    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 50,
      ),
    ).listen((position) async {
      await _processPosition(position);
    });

    _staticTimer?.cancel();
    _staticTimer = Timer.periodic(LocationRules.staticInterval, (_) async {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );
      await _processPosition(position);
    });
  }

  Future<void> _processPosition(Position position) async {
    if (!_trackingActive || _employeeId == null) {
      return;
    }

    if (!LocationRules.isValidAccuracy(position)) {
      AppLogger.warn('Ignored location due to low accuracy: ${position.accuracy}');
      return;
    }

    if (!await permissionService.hasLocationPermission()) {
      AppLogger.warn('Location permission no longer granted in background.');
      return;
    }

    final lastPending = await storageService.getLastPendingLocation(employeeId: _employeeId!);
    final now = DateTime.now();
    if (!LocationRules.shouldSaveLocation(
      lastLocation: lastPending,
      current: position,
      now: now,
    )) {
      return;
    }

    final activityType = LocationRules.activityTypeFromSpeed(position.speed);
    final batteryLevel = await _getBatteryLevel();

    final pendingLocation = PendingLocation(
      employeeId: _employeeId!,
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      speed: position.speed,
      timestamp: now,
      batteryLevel: batteryLevel,
      activityType: activityType,
    );

    await storageService.savePendingLocation(pendingLocation);
    await storageService.saveLiveLocation(LiveLocation(
      employeeId: _employeeId!,
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      speed: position.speed,
      timestamp: now,
      activityType: activityType,
    ));
    await syncService.forceSyncPending();

    AppLogger.info('Saved location for $_employeeId at $now ($activityType).');
  }

  Future<int> _getBatteryLevel() async {
    return 0;
  }
}

/// Controls the lifecycle of the background location tracking service.
class LocationTrackingService extends GetxService {
  LocationTrackingService({
    required this.permissionService,
    required this.storageService,
    required this.syncService,
  });

  final LocationPermissionService permissionService;
  final LocationStorageService storageService;
  final LocationSyncService syncService;
  final FlutterBackgroundService _service = FlutterBackgroundService();

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<bool> get isTracking async {
    final prefs = await _prefs;
    return prefs.getBool(_trackingStateKey) == true;
  }

  Future<String?> get trackedEmployeeId async {
    final prefs = await _prefs;
    return prefs.getString(_trackingEmployeeKey);
  }

  Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _backgroundServiceOnStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'attendance_tracking_channel',
        initialNotificationTitle: 'Attendance tracking ready',
        initialNotificationContent: 'Waiting for employee check-in.',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _backgroundServiceOnStart,
        onBackground: _onIosBackground,
      ),
    );

    final active = await isTracking;
    final employeeId = await trackedEmployeeId;
    if (active && employeeId != null) {
      await startTracking(employeeId);
    }
  }

  Future<void> startTracking(String employeeId) async {
    final permissionGranted = await permissionService.requestLocationPermission();
    if (!permissionGranted) {
      AppLogger.warn('Location permission denied. Tracking will not start.');
      return;
    }

    final prefs = await _prefs;
    await prefs.setBool(_trackingStateKey, true);
    await prefs.setString(_trackingEmployeeKey, employeeId);

    await _service.startService();
    _service.invoke('setAsForeground');
    _service.invoke('startTracking', {
      'employeeId': employeeId,
    });

    AppLogger.info('Tracking service started for employee $employeeId.');
  }

  Future<void> stopTracking() async {
    final prefs = await _prefs;
    await prefs.setBool(_trackingStateKey, false);
    await prefs.remove(_trackingEmployeeKey);

    await _service.startService();
    _service.invoke('stopTracking');
    AppLogger.info('Tracking service stopped.');
  }

  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    return true;
  }
}
