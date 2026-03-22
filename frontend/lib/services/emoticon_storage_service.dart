import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emoticon_model.dart';

class EmoticonStorageService {
  static const _recentsKey = 'emoticon_recents';
  static const _customKey = 'emoticon_custom';
  static const _maxRecents = 20;

  // ─── Recents ────────────────────────────────────────────────────────────────

  static Future<List<RecentEmoticon>> getRecents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_recentsKey) ?? [];
    return raw
        .map((e) => RecentEmoticon.fromJson(jsonDecode(e)))
        .toList()
      ..sort((a, b) => b.copiedAt.compareTo(a.copiedAt));
  }

  static Future<void> addToRecents(EmoticonModel emoticon) async {
    final prefs = await SharedPreferences.getInstance();
    final recents = await getRecents();

    // Remove duplicate if exists
    recents.removeWhere((r) => r.emoticon.face == emoticon.face);

    // Add new at front
    recents.insert(
      0,
      RecentEmoticon(emoticon: emoticon, copiedAt: DateTime.now()),
    );

    // Trim to max
    final trimmed = recents.take(_maxRecents).toList();

    await prefs.setStringList(
      _recentsKey,
      trimmed.map((r) => jsonEncode(r.toJson())).toList(),
    );
  }

  static Future<void> clearRecents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentsKey);
  }

  // ─── Custom Emoticons ────────────────────────────────────────────────────────

  static Future<List<EmoticonModel>> getCustomEmoticons() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_customKey) ?? [];
    return raw.map((e) => EmoticonModel.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> saveCustomEmoticon(EmoticonModel emoticon) async {
    final prefs = await SharedPreferences.getInstance();
    final custom = await getCustomEmoticons();
    custom.add(emoticon);
    await prefs.setStringList(
      _customKey,
      custom.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  static Future<void> deleteCustomEmoticon(String face) async {
    final prefs = await SharedPreferences.getInstance();
    final custom = await getCustomEmoticons();
    custom.removeWhere((e) => e.face == face);
    await prefs.setStringList(
      _customKey,
      custom.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}
