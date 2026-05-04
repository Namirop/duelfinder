import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: 'access_token');
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: 'refresh_token');
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    return accessToken != null;
  }

  // Notifications preference
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _storage.write(
        key: 'notifications_enabled', value: enabled.toString());
  }

  Future<bool> getNotificationsEnabled() async {
    final value = await _storage.read(key: 'notifications_enabled');
    return value != 'false'; // default true
  }
}
