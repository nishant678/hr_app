class UserModel {
  final String token;
  final String email;
  final String role;
  final int id;
  final int? companyId;
  final String error;

  const UserModel({
    this.token = '',
    this.email = '',
    this.role = '',
    this.id = 0,
    this.companyId,
    this.error = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: _readString(json['token']),
      email: _readString(json['email']),
      role: _readString(json['role']),
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      companyId: json['companyId'] is int
          ? json['companyId']
          : int.tryParse(json['companyId']?.toString() ?? ''),
      error: _readString(json['error'] ?? json['message']),
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'email': email,
        'role': role,
        'id': id,
        'companyId': companyId,
      };

  static String _readString(Object? value) {
    if (value == null) return '';
    return value.toString();
  }
}
