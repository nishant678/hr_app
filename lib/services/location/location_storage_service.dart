import 'package:isar/isar.dart';
import 'package:hr_app/database/isar_db.dart';
import 'package:hr_app/models/live_location.dart';
import 'package:hr_app/models/pending_location.dart';

/// Local storage helper for all offline tracking records.
class LocationStorageService {
  late final Future<Isar> _db;

  LocationStorageService() {
    _db = IsarDb.instance;
  }

  Future<void> savePendingLocation(PendingLocation location) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.pendingLocations.put(location);
    });
  }

  Future<void> saveLiveLocation(LiveLocation liveLocation) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.liveLocations.put(liveLocation);
    });
  }

  Future<List<PendingLocation>> getUnsyncedLocations({required String employeeId}) async {
    final isar = await _db;
    return await isar.pendingLocations
        .filter()
        .employeeIdEqualTo(employeeId)
        .syncedEqualTo(false)
        .findAll();
  }

  Future<List<PendingLocation>> getAllUnsyncedLocations() async {
    final isar = await _db;
    return await isar.pendingLocations.filter().syncedEqualTo(false).findAll();
  }

  Future<PendingLocation?> getLastPendingLocation({required String employeeId}) async {
    final isar = await _db;
    return await isar.pendingLocations
        .filter()
        .employeeIdEqualTo(employeeId)
        .sortByTimestampDesc()
        .findFirst();
  }

  Future<void> markLocationsSynced(List<int> ids) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      final records = await isar.pendingLocations.getAll(ids);
      for (final item in records) {
        if (item != null) {
          item.synced = true;
        }
      }
      await isar.pendingLocations.putAll(records.whereType<PendingLocation>().toList());
    });
  }

  Future<void> cleanupSynced({Duration olderThan = const Duration(days: 7)}) async {
    final isar = await _db;
    final cutoff = DateTime.now().subtract(olderThan);
    final syncedIds = await isar.pendingLocations
        .filter()
        .syncedEqualTo(true)
        .timestampLessThan(cutoff)
        .idProperty()
        .findAll();
    if (syncedIds.isNotEmpty) {
      await isar.writeTxn(() async {
        await isar.pendingLocations.deleteAll(syncedIds);
      });
    }
  }
}
