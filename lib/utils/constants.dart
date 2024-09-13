import 'package:shared_preferences/shared_preferences.dart';

class Constants {
  static SharedPreferences? _prefs;
  Future<SharedPreferences> get prefs async =>
      _prefs ??= await SharedPreferences.getInstance();
}
