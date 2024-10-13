import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin FlutterSecureStorageMixin on FlutterSecureStorage {
  static const refreshTokenKey = 'REFRESH_TOKEN';

  Future<String?> getRefreshToken() async {
    return await read(key: refreshTokenKey);
  }

  Future<void> setRefreshToken(String refreshToken) async {
    await write(key: refreshTokenKey, value: refreshToken);
  }

  Future<void> clearRefreshToken() async {
    await delete(key: refreshTokenKey);
  }
}

class SecureStorage extends FlutterSecureStorage
    with FlutterSecureStorageMixin {}

class LocalStorage {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<String?> getValue(String key) async {
    final prefs = await _instance;
    return prefs.getString(key);
  }

  Future<void> setValue(String key, String value) async {
    final prefs = await _instance;
    await prefs.setString(key, value);
  }

  Future<void> clearValue(String key) async {
    final prefs = await _instance;
    await prefs.remove(key);
  }
}
