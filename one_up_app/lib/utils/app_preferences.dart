import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences{
  static SharedPreferences? _preferences;

  static const _keyIsLogin = 'keyIsLogin';
  static const _keyIsAdmin = 'keyIsAdmin';
  static const _keyToken = 'keyToken';
  static const _keyUserSession = 'keyUserSession';
  static const _keyFcmToken = '_keyFcmToken';

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();
  static Future clearPref() async =>
      _preferences?.clear();

  static Future setIsLogin(bool isLogin) async =>
      {await _preferences?.setBool(_keyIsLogin, isLogin)};

  static bool getIsLogin() => _preferences?.getBool(_keyIsLogin) ?? false;


  static Future setToken(String token) async =>
      {await _preferences?.setString(_keyToken, token)};

  static String? getToken() => _preferences?.getString(_keyToken) ?? null;

  static Future setFCMToken(String token) async =>
      {await _preferences?.setString(_keyFcmToken, token)};

  static String? getFCMToken() => _preferences?.getString(_keyFcmToken) ?? null;

  static Future setUserSession(String data) async =>
      {await _preferences?.setString(_keyUserSession, data)};

  static String getUserSession() => _preferences?.getString(_keyUserSession) ?? "";



  static Future setIsAdmin(bool isLogin) async =>
      {await _preferences?.setBool(_keyIsAdmin, isLogin)};

  static bool getIsAdmin() => _preferences?.getBool(_keyIsAdmin) ?? false;
}