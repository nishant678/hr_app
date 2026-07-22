class AttendanceModel {
  final int id;
  final String date;
  final String? checkInTime;
  final String? checkOutTime;
  final String status;
  final String? faceImageUrl;
  final double? hoursWorked;
  final double? latitude;
  final double? longitude;
  final String? locationAddress;
  final String? notes;
  final int userId;
  final String userEmail;
  final String userName;

  const AttendanceModel({
    required this.id,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.faceImageUrl,
    this.hoursWorked,
    this.latitude,
    this.longitude,
    this.locationAddress,
    this.notes,
    required this.userId,
    required this.userEmail,
    required this.userName,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      date: json['date']?.toString() ?? '',
      checkInTime: json['checkInTime']?.toString(),
      checkOutTime: json['checkOutTime']?.toString(),
      status: json['status']?.toString() ?? 'PRESENT',
      faceImageUrl: json['faceImageUrl']?.toString(),
      hoursWorked: json['hoursWorked'] is double
          ? json['hoursWorked']
          : (json['hoursWorked'] != null ? double.tryParse(json['hoursWorked'].toString()) : null),
      latitude: json['latitude'] is double
          ? json['latitude']
          : (json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null),
      longitude: json['longitude'] is double
          ? json['longitude']
          : (json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null),
      locationAddress: json['locationAddress']?.toString(),
      notes: json['notes']?.toString(),
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId'].toString()) ?? 0,
      userEmail: json['userEmail']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
    );
  }
}
