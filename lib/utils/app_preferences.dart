import 'dart:async';
import 'dart:convert';

import 'package:flutter_template/modules/authentication/model/user_model.dart';
import 'package:flutter_template/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreference {
  static late SharedPreferences _prefs;
  static final AppPreference _instance = AppPreference._();

  AppPreference._();

  static Future initMySharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static AppPreference get instance => _instance;

  static void clearSharedPreferences() {
    _prefs.clear();
    return;
  }

  static void clearBaseOnKey(key) {
    _prefs.remove(key);
    return;
  }

  static  containsBaseOnKey(key) {
    _prefs.containsKey(key);
    return;
  }

  static Future setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static String getString(String key) {
    final String? value = _prefs.getString(key);
    return value ?? "";
  }

  static Future setBoolean(String key, {required bool value}) async {
    await _prefs.setBool(key, value);
  }

  static bool getBoolean(String key) {
    final bool? value = _prefs.getBool(key);
    return value ?? true;
  }

  static Future setLong(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  static double getLong(String key) {
    final double? value = _prefs.getDouble(key);
    return value ?? 0.0;
  }

  static Future setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  static int? getInt(String key) {
    final int? value = _prefs.getInt(key);
    return value;
  }

  static Future setUserToken(String token) async {
    await _prefs.setString(Constants.keyToken, token);
  }

  static String? getUserToken() {
    return _prefs.get(Constants.keyToken) as String?;
  }

  static Future setUser(UserModel? user) async {
    await _prefs.setString(Constants.keyUser, jsonEncode(user));
  }

  static UserModel? getUser() {
    return UserModel.fromJson(jsonDecode(_prefs.get(Constants.keyUser) as String? ?? ""));
  }

  static bool isUserLogin() {
    final String? getToken = getUserToken();
    return getToken != null && getToken.isNotEmpty;
  }
}
