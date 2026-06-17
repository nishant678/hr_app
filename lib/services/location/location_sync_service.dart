import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:hr_app/repositories/location_repository.dart';
import 'package:hr_app/services/location/location_storage_service.dart';
import 'package:hr_app/utils/logger.dart';

/// Sync engine that pushes pending location records when connectivity returns.
class LocationSyncService extends GetxService {
  LocationSyncService({
    required this.repository,
    required this.storageService,
  });

  final LocationRepository repository;
  final LocationStorageService storageService;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _syncInProgress = false;

  Future<void> init() async {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    await forceSyncPending();
  }

  Future<void> disposeService() async {
    await _connectivitySubscription?.cancel();
  }

  Future<void> _onConnectivityChanged(ConnectivityResult result) async {
    final isOnline = result != ConnectivityResult.none;
    if (isOnline) {
      await forceSyncPending();
    }
  }

  Future<void> forceSyncPending() async {
    if (_syncInProgress) {
      return;
    }

    _syncInProgress = true;
    try {
      final records = await storageService.getAllUnsyncedLocations();
      if (records.isEmpty) {
        return;
      }

      AppLogger.info('Syncing ${records.length} pending locations.');
      await repository.syncPendingLocations(records);
      await storageService.markLocationsSynced(records.map((r) => r.id).whereType<int>().toList());
      await storageService.cleanupSynced();
      AppLogger.info('Pending locations synced successfully.');
    } catch (e) {
      AppLogger.error('Sync failed', e);
    } finally {
      _syncInProgress = false;
    }
  }
}
