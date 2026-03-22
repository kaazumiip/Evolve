import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalityStorageService {
  static const String _storageKey = 'personality_result';
  static const String _progressKey = 'personality_progress';

  static Future<void> saveProgress({
    required int questionIndex,
    required Map<int, String> answers,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'questionIndex': questionIndex,
      'answers': answers.map((key, value) => MapEntry(key.toString(), value)),
      'timestamp': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_progressKey, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> getProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
  }

  static Future<void> saveResult({
    required String type,
    required Map<String, int> scores,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'type': type,
      'scores': scores,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_storageKey, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> getResult() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> clearResult() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
