
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper{
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setString(String key,value) async{
   await _prefs?.setString(key, value);
  }

  Future<String?> getString(String key) async{
   return _prefs?.getString(key);
  }

  //Login
  Future<void> setLoggedIn(bool value) async {
    await _prefs?.setBool('isLoggedIn', value);
  }

  Future<bool> getLoggedIn() async {
    return _prefs?.getBool('isLoggedIn') ?? false;
  }

  Future<void> clear() async {
    await _prefs?.clear();
  }
}