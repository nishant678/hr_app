import 'package:flutter/foundation.dart';

import '../../model/user/user_model.dart';
import '../storage/local_storage.dart';

class SessionController {
  final LocalStorage storage = LocalStorage();

  static final SessionController _session = SessionController._internal();

  static bool? isLogin;
  static String? token;
  static String? email;
  static String? role;
  static int? userId;
  static int? companyId;

  SessionController._internal() {
    isLogin = false;
  }

  factory SessionController() {
    return _session;
  }

  Future<void> saveUserInPreference(UserModel user) async {
    token = user.token;
    email = user.email;
    role = user.role;
    userId = user.id;
    companyId = user.companyId;
    await storage.setValue('token', user.token);
    await storage.setValue('email', user.email);
    await storage.setValue('role', user.role);
    await storage.setValue('userId', user.id.toString());
    if (user.companyId != null) {
      await storage.setValue('companyId', user.companyId.toString());
    }
    await storage.setValue('isLogin', 'true');
    isLogin = true;
  }

  Future<void> getUserFromPreference() async {
    try {
      final t = await storage.readValue('token');
      final e = await storage.readValue('email');
      final r = await storage.readValue('role');
      final uid = await storage.readValue('userId');
      final cid = await storage.readValue('companyId');
      final login = await storage.readValue('isLogin');

      token = t?.toString() ?? '';
      email = e?.toString() ?? '';
      role = r?.toString() ?? '';
      userId = int.tryParse(uid?.toString() ?? '');
      companyId = int.tryParse(cid?.toString() ?? '');
      isLogin = login?.toString() == 'true' && token!.isNotEmpty;
    } catch (e, st) {
      isLogin = false;
      if (kDebugMode) {
        debugPrint('getUserFromPreference failed: $e');
        debugPrintStack(stackTrace: st);
      }
    }
  }

  Future<void> clearSession() async {
    await storage.clearValue('token');
    await storage.clearValue('email');
    await storage.clearValue('role');
    await storage.clearValue('userId');
    await storage.clearValue('companyId');
    await storage.clearValue('isLogin');
    token = null;
    email = null;
    role = null;
    userId = null;
    companyId = null;
    isLogin = false;
  }
}
