import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hr_app/models/live_location.dart';
import 'package:hr_app/models/pending_location.dart';
import 'package:hr_app/models/visit_marker.dart';

/// Central Isar database initializer and accessor.
class IsarDb {
  IsarDb._();

  static Isar? _instance;

  static Future<Isar> get instance async {
    _instance ??= await initialize();
    return _instance!;
  }

  static Future<Isar> initialize() async {
    if (_instance != null) {
      return _instance!;
    }

    final appDir = await getApplicationSupportDirectory();
    final path = appDir.path;

    _instance = await Isar.open(
      [PendingLocationSchema, LiveLocationSchema, VisitMarkerSchema],
      directory: path,
      inspector: true,
    );
    return _instance!;
  }
}
