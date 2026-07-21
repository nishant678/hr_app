class LeaveModel {
  final int id;
  final String leaveType;
  final String fromDate;
  final String toDate;
  final String? fromTime;
  final String? toTime;
  final String? reason;
  final String? attachmentUrl;
  final String status;
  final String? rejectionReason;
  final int userId;
  final String userEmail;
  final String userName;

  const LeaveModel({
    required this.id,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    this.fromTime,
    this.toTime,
    this.reason,
    this.attachmentUrl,
    required this.status,
    this.rejectionReason,
    required this.userId,
    required this.userEmail,
    required this.userName,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      leaveType: json['leaveType']?.toString() ?? '',
      fromDate: json['fromDate']?.toString() ?? '',
      toDate: json['toDate']?.toString() ?? '',
      fromTime: json['fromTime']?.toString(),
      toTime: json['toTime']?.toString(),
      reason: json['reason']?.toString(),
      attachmentUrl: json['attachmentUrl']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      rejectionReason: json['rejectionReason']?.toString(),
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId'].toString()) ?? 0,
      userEmail: json['userEmail']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
    );
  }
}
