import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OfflineCacheService {
  static late Box<dynamic> _box;

  static Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>('koral_cache');
  }

  static Future<void> putString(String key, String value) async {
    await _box.put(key, value);
  }

  static String? getString(String key) => _box.get(key) as String?;

  static Future<void> putJson(String key, Map<String, dynamic> value) async {
    await _box.put(key, value);
  }

  static Map<String, dynamic>? getJson(String key) {
    final value = _box.get(key);
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }
}
