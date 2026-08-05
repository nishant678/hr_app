import 'package:intl/intl.dart';
import 'package:hr_app/data/network/base_api_services.dart';
import 'package:hr_app/data/network/network_api_services.dart';
import 'package:hr_app/model/attendance/attendance_model.dart';
import 'package:hr_app/utils/app_url.dart';
import 'attendance_api_repository.dart';

class AttendanceHttpApiRepository implements AttendanceApiRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  @override
  Future<AttendanceModel> checkIn({
    String? faceImagePath,
    double? latitude,
    double? longitude,
    String? locationAddress,
    Map<String, String>? deviceInfo,
  }) async {
    final now = DateTime.now();
    final checkInTime = DateFormat('HH:mm:ss').format(now);
    final date = DateFormat('yyyy-MM-dd').format(now);
    if (faceImagePath != null) {
      final fields = <String, String>{
        'checkInTime': checkInTime,
        'date': date,
      };
      if (latitude != null) fields['latitude'] = latitude.toString();
      if (longitude != null) fields['longitude'] = longitude.toString();
      if (locationAddress != null) fields['locationAddress'] = locationAddress;
      if (deviceInfo != null) {
        deviceInfo.forEach((k, v) => fields['device.$k'] = v);
      }

      final response = await _apiServices.multipartPostApi(
        AppUrl.attendanceCheckInEndPoint,
        filePath: faceImagePath,
        fileField: 'faceImage',
        fields: fields,
      );
      if (response is Map && response['data'] is Map) {
        return AttendanceModel.fromJson(response['data']);
      }
      throw Exception('Failed to check in');
    } else {
      final url = AppUrl.attendanceCheckInEndPoint
          + _buildQueryParams(latitude, longitude, locationAddress, checkInTime, date);
      final response = await _apiServices.postApi(url, {});
      if (response is Map && response['data'] is Map) {
        return AttendanceModel.fromJson(response['data']);
      }
      throw Exception('Failed to check in');
    }
  }

  @override
  Future<AttendanceModel> checkOut({String? faceImagePath}) async {
    final now = DateTime.now();
    final checkOutTime = DateFormat('HH:mm:ss').format(now);
    final date = DateFormat('yyyy-MM-dd').format(now);
    if (faceImagePath != null) {
      final response = await _apiServices.multipartPostApi(
        AppUrl.attendanceCheckOutEndPoint,
        filePath: faceImagePath,
        fileField: 'faceImage',
        fields: {
          'checkOutTime': checkOutTime,
          'date': date,
        },
      );
      if (response is Map && response['data'] is Map) {
        return AttendanceModel.fromJson(response['data']);
      }
      throw Exception('Failed to check out');
    }
    final url = '${AppUrl.attendanceCheckOutEndPoint}?checkOutTime=$checkOutTime&date=$date';
    final response = await _apiServices.postApi(url, {});
    if (response is Map && response['data'] is Map) {
      return AttendanceModel.fromJson(response['data']);
    }
    throw Exception('Failed to check out');
  }

  String _buildQueryParams(double? lat, double? lng, String? addr, String checkInTime, String date) {
    final params = <String>['checkInTime=$checkInTime', 'date=$date'];
    if (lat != null) params.add('latitude=$lat');
    if (lng != null) params.add('longitude=$lng');
    if (addr != null) params.add('locationAddress=${Uri.encodeComponent(addr)}');
    return '?${params.join('&')}';
  }

  @override
  Future<List<AttendanceModel>> getMyAttendance() async {
    final response = await _apiServices.getApi(AppUrl.myAttendanceEndPoint);
    if (response is Map && response['data'] is List) {
      return (response['data'] as List).map((e) => AttendanceModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<List<AttendanceModel>> getTodayAttendance() async {
    final response = await _apiServices.getApi(AppUrl.todayAttendanceEndPoint);
    if (response is Map && response['data'] is List) {
      return (response['data'] as List).map((e) => AttendanceModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<List<AttendanceModel>> getCompanyAttendance() async {
    final response = await _apiServices.getApi(AppUrl.attendanceEndPoint);
    if (response is Map && response['data'] is List) {
      return (response['data'] as List).map((e) => AttendanceModel.fromJson(e)).toList();
    }
    return [];
  }
}
