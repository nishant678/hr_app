import 'package:hr_app/model/attendance/attendance_model.dart';

abstract class AttendanceApiRepository {
  Future<AttendanceModel> checkIn({
    String? faceImagePath,
    double? latitude,
    double? longitude,
    String? locationAddress,
    Map<String, String>? deviceInfo,
  });
  Future<AttendanceModel> checkOut();
  Future<List<AttendanceModel>> getMyAttendance();
  Future<List<AttendanceModel>> getTodayAttendance();
  Future<List<AttendanceModel>> getCompanyAttendance();
}
