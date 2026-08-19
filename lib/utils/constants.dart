import 'package:shared_preferences/shared_preferences.dart';

class Constants {
  static const Duration verificationEmailResendCooldown = Duration(seconds: 60);

  static String verificationEmailNextResendAtKey(String uid) =>
      'verificationEmailNextResendAt_$uid';

  static SharedPreferences? _prefs;
  Future<SharedPreferences> get prefs async =>
      _prefs ??= await SharedPreferences.getInstance();
}
