import 'package:isar/isar.dart';

part 'visit_marker.g.dart';

/// Optional marker model for visited places or stops.
@collection
class VisitMarker {
  VisitMarker({
    this.id = Isar.autoIncrement,
    required this.employeeId,
    required this.placeName,
    required this.latitude,
    required this.longitude,
    required this.arrivalTime,
    this.departureTime,
  });

  Id id = Isar.autoIncrement;
  String employeeId;
  String placeName;
  double latitude;
  double longitude;
  DateTime arrivalTime;
  DateTime? departureTime;
}
