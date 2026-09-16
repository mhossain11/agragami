/*

import 'package:shared_preferences/shared_preferences.dart';


class CacheHelper {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<void> setLoggedIn(bool value) async {
    await _prefs?.setBool('isLoggedIn', value);
  }
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  bool getLoggedIn() {
    return _prefs?.getBool('isLoggedIn') ?? false;
  }

  Future<void> clear() async {
    await _prefs?.clear();
  }
}*/

import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // =========================
  // String
  // =========================

  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  // =========================
  // Login
  // =========================

  Future<void> setLoggedIn(bool value) async {
    await _prefs?.setBool('isLoggedIn', value);
  }

  bool getBool(
      String key, {
        bool defaultValue = false,
      }) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  bool getLoggedIn() {
    return _prefs?.getBool('isLoggedIn') ?? false;
  }

  // =========================
  // Remove Single Key
  // =========================

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  // =========================
  // Clear Login Session
  // =========================
  // userId থাকবে
  // শুধু login session related data remove হবে

  Future<void> clearSession() async {
    await _prefs?.remove('isLoggedIn');
    await _prefs?.remove('isRole');

    // এগুলো intentionally remove করছি না:
    // userId
    // userDocId
  }

  // =========================
  // Clear Everything
  // =========================

  Future<void> clear() async {
    await _prefs?.clear();
  }
}
