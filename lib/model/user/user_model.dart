/// Authentication payload returned from the login API.
class UserModel {
  const UserModel({
    this.token = '',
    this.error = '',
  });

  final String token;
  final String error;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: _readString(json['token']),
      error: _readString(json['error'] ?? json['message']),
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'error': error,
      };

  static String _readString(Object? value) {
    if (value == null) return '';
    return value.toString();
  }
}
