import 'package:hr_app/data/network/base_api_services.dart';
import 'package:hr_app/data/network/network_api_services.dart';
import 'package:hr_app/model/leave/leave_model.dart';
import 'package:hr_app/utils/app_url.dart';
import 'leave_api_repository.dart';

class LeaveHttpApiRepository implements LeaveApiRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  @override
  Future<List<LeaveModel>> getMyLeaves() async {
    final response = await _apiServices.getApi(AppUrl.myLeavesEndPoint);
    if (response is Map && response['data'] is List) {
      return (response['data'] as List).map((e) => LeaveModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<LeaveModel> applyLeave(Map<String, dynamic> data) async {
    final response = await _apiServices.postApi(AppUrl.leavesEndPoint, data);
    if (response is Map && response['data'] is Map) {
      return LeaveModel.fromJson(response['data']);
    }
    throw Exception('Failed to apply leave');
  }

  @override
  Future<void> uploadAttachment(int leaveId, String filePath) async {
    await _apiServices.multipartPostApi(
      '${AppUrl.leavesEndPoint}/$leaveId/attachment',
      filePath: filePath,
      fileField: 'file',
    );
  }
}
