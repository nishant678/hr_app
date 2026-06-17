import 'package:get/get.dart';
import 'package:hr_app/services/location/location_permission_service.dart';
import 'package:hr_app/services/location/location_storage_service.dart';
import 'package:hr_app/services/location/location_sync_service.dart';
import 'package:hr_app/services/location/location_tracking_service.dart';
import 'package:hr_app/utils/logger.dart';

class LocationController extends GetxController {
  final LocationPermissionService permissionService;
  final LocationStorageService storageService;
  final LocationSyncService syncService;
  final LocationTrackingService trackingService;

  LocationController({
    required this.permissionService,
    required this.storageService,
    required this.syncService,
    required this.trackingService,
  });

  final RxBool isTracking = false.obs;
  final RxString statusMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    await syncService.init();
    await trackingService.initialize();
    isTracking.value = await trackingService.isTracking;
    final active = await trackingService.isTracking;
    statusMessage.value = active ? 'Tracking active' : 'Tracking is stopped';
  }

  Future<void> checkIn(String employeeId) async {
    final permissionGranted = await permissionService.requestLocationPermission();
    if (!permissionGranted) {
      statusMessage.value = 'Location permission is required for check-in.';
      return;
    }

    await trackingService.startTracking(employeeId);
    isTracking.value = true;
    statusMessage.value = 'Checked in and tracking started.';
    AppLogger.info('Employee $employeeId checked in.');
  }

  Future<void> checkOut() async {
    await trackingService.stopTracking();
    isTracking.value = false;
    statusMessage.value = 'Checked out and tracking stopped.';
    AppLogger.info('Employee checked out.');
  }
}
