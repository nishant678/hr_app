import 'dart:convert';
import 'package:hr_app/data/network/base_api_services.dart';
import 'package:hr_app/data/network/network_api_services.dart';
import 'package:hr_app/model/attendance/attendance_model.dart';
import 'package:hr_app/services/session_manager/session_controller.dart';
import 'package:hr_app/utils/app_url.dart';
import 'package:http/http.dart' as http;
import 'attendance_api_repository.dart';

class AttendanceHttpApiRepository implements AttendanceApiRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  @override
  Future<AttendanceModel> checkIn({
    String? faceImagePath,
    double? latitude,
    double? longitude,
    String? locationAddress,
  }) async {
    if (faceImagePath != null) {
      final token = SessionController.token;
      final uri = Uri.parse(AppUrl.attendanceCheckInEndPoint + _buildLocationParams(latitude, longitude, locationAddress));
      final request = http.MultipartRequest('POST', uri);
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(await http.MultipartFile.fromPath('faceImage', faceImagePath));
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['data'] is Map) {
          return AttendanceModel.fromJson(decoded['data']);
        }
      }
      throw Exception('Check-in failed: ${response.statusCode}');
    } else {
      final url = AppUrl.attendanceCheckInEndPoint + _buildLocationParams(latitude, longitude, locationAddress);
      final response = await _apiServices.postApi(url, {});
      if (response is Map && response['data'] is Map) {
        return AttendanceModel.fromJson(response['data']);
      }
      throw Exception('Failed to check in');
    }
  }

  String _buildLocationParams(double? lat, double? lng, String? addr) {
    final params = <String>[];
    if (lat != null) params.add('latitude=$lat');
    if (lng != null) params.add('longitude=$lng');
    if (addr != null) params.add('locationAddress=${Uri.encodeComponent(addr)}');
    return params.isEmpty ? '' : '?${params.join('&')}';
  }

  @override
  Future<AttendanceModel> checkOut() async {
    final response = await _apiServices.postApi(AppUrl.attendanceCheckOutEndPoint, {});
    if (response is Map && response['data'] is Map) {
      return AttendanceModel.fromJson(response['data']);
    }
    throw Exception('Failed to check out');
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
