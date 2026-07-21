class AppUrl {
  static var baseUrl = 'https://hr-spring-backend.onrender.com';
  // static var baseUrl = 'http://10.152.0.62:8080';
  static var loginEndPoint = '$baseUrl/api/auth/login';
  static var leavesEndPoint = '$baseUrl/api/leaves';
  static String myLeavesEndPoint = '$baseUrl/api/leaves/my';
}
