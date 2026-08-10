class UserModel {
  final String token;
  final String refreshToken;
  final int expiresAt;
  final String email;
  final String role;
  final int id;
  final int? companyId;
  final bool faceRegistered;
  final String error;

  const UserModel({
    this.token = '',
    this.refreshToken = '',
    this.expiresAt = 0,
    this.email = '',
    this.role = '',
    this.id = 0,
    this.companyId,
    this.faceRegistered = false,
    this.error = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: _readString(json['token']),
      refreshToken: _readString(json['refreshToken']),
      expiresAt: json['expiresAt'] is int ? json['expiresAt'] : 0,
      email: _readString(json['email']),
      role: _readString(json['role']),
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      companyId: json['companyId'] is int
          ? json['companyId']
          : int.tryParse(json['companyId']?.toString() ?? ''),
      faceRegistered: json['faceRegistered'] == true,
      error: _readString(json['error'] ?? json['message']),
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt,
        'email': email,
        'role': role,
        'id': id,
        'companyId': companyId,
        'faceRegistered': faceRegistered,
      };

  static String _readString(Object? value) {
    if (value == null) return '';
    return value.toString();
  }
}
