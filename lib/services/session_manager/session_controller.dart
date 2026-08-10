import 'package:flutter/foundation.dart';

import '../../model/user/user_model.dart';
import '../storage/local_storage.dart';

class SessionController {
  final LocalStorage storage = LocalStorage();
  static final SessionController _session = SessionController._internal();

  static bool? isLogin;
  static String? token;
  static String? refreshToken;
  static int? expiresAt;
  static String? email;
  static String? role;
  static int? userId;
  static int? companyId;
  static bool faceRegistered = false;

  SessionController._internal() { isLogin = false; }
  factory SessionController() => _session;

  Future<void> saveUserInPreference(UserModel user) async {
    token = user.token;
    refreshToken = user.refreshToken;
    expiresAt = user.expiresAt;
    email = user.email;
    role = user.role;
    userId = user.id;
    companyId = user.companyId;
    faceRegistered = user.faceRegistered;
    await storage.setValue('token', user.token);
    await storage.setValue('refreshToken', user.refreshToken);
    await storage.setValue('expiresAt', user.expiresAt.toString());
    await storage.setValue('email', user.email);
    await storage.setValue('role', user.role);
    await storage.setValue('userId', user.id.toString());
    await storage.setValue('faceRegistered', user.faceRegistered.toString());
    if (user.companyId != null) {
      await storage.setValue('companyId', user.companyId.toString());
    }
    await storage.setValue('isLogin', 'true');
    isLogin = true;
  }

  Future<void> getUserFromPreference() async {
    try {
      final t = await storage.readValue('token');
      final rt = await storage.readValue('refreshToken');
      final ex = await storage.readValue('expiresAt');
      final e = await storage.readValue('email');
      final r = await storage.readValue('role');
      final uid = await storage.readValue('userId');
      final cid = await storage.readValue('companyId');
      final fr = await storage.readValue('faceRegistered');
      final login = await storage.readValue('isLogin');

      token = t?.toString() ?? '';
      refreshToken = rt?.toString() ?? '';
      expiresAt = int.tryParse(ex?.toString() ?? '') ?? 0;
      email = e?.toString() ?? '';
      role = r?.toString() ?? '';
      userId = int.tryParse(uid?.toString() ?? '');
      companyId = int.tryParse(cid?.toString() ?? '');
      faceRegistered = fr?.toString() == 'true';
      isLogin = login?.toString() == 'true' && token!.isNotEmpty;
    } catch (e, st) {
      isLogin = false;
      if (kDebugMode) { debugPrint('getUserFromPreference failed: $e'); debugPrintStack(stackTrace: st); }
    }
  }

  static bool get isAccessTokenExpired {
    if (expiresAt == null || expiresAt == 0) return false;
    return DateTime.now().millisecondsSinceEpoch > expiresAt! - 60000;
  }

  Future<void> updateTokens(String newAccess, String newRefresh, int newExpires) async {
    token = newAccess;
    refreshToken = newRefresh;
    expiresAt = newExpires;
    await storage.setValue('token', newAccess);
    await storage.setValue('refreshToken', newRefresh);
    await storage.setValue('expiresAt', newExpires.toString());
  }

  Future<void> clearSession() async {
    await storage.clearValue('token');
    await storage.clearValue('refreshToken');
    await storage.clearValue('expiresAt');
    await storage.clearValue('email');
    await storage.clearValue('role');
    await storage.clearValue('userId');
    await storage.clearValue('companyId');
    await storage.clearValue('isLogin');
    token = null; refreshToken = null; expiresAt = null;
    email = null; role = null; userId = null; companyId = null;
    isLogin = false; faceRegistered = false;
  }
}
