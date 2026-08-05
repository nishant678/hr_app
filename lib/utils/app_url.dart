class AppUrl {
  static var baseUrl = 'http://10.104.70.61:8080';
  // static var baseUrl = 'https://hr-spring-backend.onrender.com';
  static var loginEndPoint = '$baseUrl/api/auth/login';
  static var leavesEndPoint = '$baseUrl/api/leaves';
  static String myLeavesEndPoint = '$baseUrl/api/leaves/my';
  static var expensesEndPoint = '$baseUrl/api/expenses';
  static String myExpensesEndPoint = '$baseUrl/api/expenses/my';
  static var attendanceEndPoint = '$baseUrl/api/attendance';
  static String myAttendanceEndPoint = '$baseUrl/api/attendance/my';
  static String todayAttendanceEndPoint = '$baseUrl/api/attendance/today';
  static String attendanceCheckInEndPoint = '$baseUrl/api/attendance/check-in';
  static String attendanceCheckOutEndPoint =
      '$baseUrl/api/attendance/check-out';
  static String payslipEndPoint = '$baseUrl/api/payslip';
  static String myAssetsEndPoint = '$baseUrl/api/assets/my';
  static String profileEndPoint = '$baseUrl/api/employee/profile';
  static String profilePhotoUpdateEndPoint =
      '$baseUrl/api/employee/profile/photo';
  static String faceStatusEndPoint = '$baseUrl/api/face/status';
  static String faceRegisterEndPoint = '$baseUrl/api/face/register';

  static String resolve(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$baseUrl$path';
  }
}
