import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:hr_app/repositories/location_repository.dart';
import 'package:hr_app/services/location/location_storage_service.dart';
import 'package:hr_app/services/location/location_sync_service.dart';
import 'package:hr_app/utils/logger.dart';

const _locationSyncTask = 'locationSyncTask';

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == _locationSyncTask) {
      AppLogger.info('Running periodic location sync task.');
      await SharedPreferences.getInstance();
      final storageService = LocationStorageService();
      final repository = LocationRepository();
      final syncService = LocationSyncService(
        repository: repository,
        storageService: storageService,
      );
      await syncService.forceSyncPending();
      return Future.value(true);
    }
    return Future.value(false);
  });
}

class WorkmanagerService {
  static Future<void> initialize() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );
    }
  }

  static Future<void> registerPeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      _locationSyncTask,
      _locationSyncTask,
      frequency: const Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}
