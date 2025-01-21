import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  final SharedPreferences _prefs;
  final Duration defaultDuration;

  CacheService(this._prefs, {this.defaultDuration = const Duration(hours: 1)});

  Future<void> setData(String key, dynamic data, {Duration? duration}) async {
    final expiryTime = DateTime.now().add(duration ?? defaultDuration);
    final cacheData = {
      'data': data,
      'expiry': expiryTime.toIso8601String(),
    };
    await _prefs.setString(key, jsonEncode(cacheData));
  }

  dynamic getData(String key) {
    final cachedData = _prefs.getString(key);
    if (cachedData == null) return null;

    final decodedData = jsonDecode(cachedData);
    final expiry = DateTime.parse(decodedData['expiry']);

    if (DateTime.now().isAfter(expiry)) {
      _prefs.remove(key); // Clear expired cache
      return null;
    }

    return decodedData['data'];
  }

  Future<void> clearCache() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  bool hasValidCache(String key) {
    final data = getData(key);
    return data != null;
  }
}
