import 'package:hr_app/model/leave/leave_model.dart';

abstract class LeaveApiRepository {
  Future<List<LeaveModel>> getMyLeaves();
  Future<LeaveModel> applyLeave(Map<String, dynamic> data);
  Future<void> uploadAttachment(int leaveId, String filePath);
}
