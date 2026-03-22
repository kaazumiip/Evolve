import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_model.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static SharedPreferences? _prefs;

  DBHelper._init();

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  static const String _storageKey = 'journal_entries';

  Future<List<JournalEntry>> getEntries({bool includeArchived = false}) async {
    final p = await prefs;
    final List<String> raw = p.getStringList(_storageKey) ?? [];
    
    final entries = raw.map((item) => JournalEntry.fromMap(jsonDecode(item))).toList();
    
    if (!includeArchived) {
      return entries.where((e) => !e.isArchived).toList();
    }
    return entries;
  }

  Future<int> insertEntry(JournalEntry entry) async {
    final p = await prefs;
    final entries = await getEntries(includeArchived: true);
    
    // Generate an ID if needed
    final newId = entries.isEmpty ? 1 : entries.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    final newEntry = entry.copyWith(id: newId);
    
    final List<String> raw = p.getStringList(_storageKey) ?? [];
    raw.add(jsonEncode(newEntry.toMap()));
    await p.setStringList(_storageKey, raw);
    
    return newId;
  }

  Future<int> updateEntry(JournalEntry entry) async {
    if (entry.id == null) return 0;
    
    final p = await prefs;
    final List<String> raw = p.getStringList(_storageKey) ?? [];
    
    final index = raw.indexWhere((item) {
      final decoded = jsonDecode(item);
      return decoded['id'] == entry.id;
    });

    if (index != -1) {
      raw[index] = jsonEncode(entry.toMap());
      await p.setStringList(_storageKey, raw);
      return 1;
    }
    return 0;
  }

  Future<int> deleteEntry(int id) async {
    final p = await prefs;
    final List<String> raw = p.getStringList(_storageKey) ?? [];
    
    final newRaw = raw.where((item) {
      final decoded = jsonDecode(item);
      return decoded['id'] != id;
    }).toList();

    if (newRaw.length < raw.length) {
      await p.setStringList(_storageKey, newRaw);
      return 1;
    }
    return 0;
  }

  Future<int> archiveEntry(int id, bool isArchived) async {
    final p = await prefs;
    final List<String> raw = p.getStringList(_storageKey) ?? [];
    
    final index = raw.indexWhere((item) {
      final decoded = jsonDecode(item);
      return decoded['id'] == id;
    });

    if (index != -1) {
      final decoded = jsonDecode(raw[index]) as Map<String, dynamic>;
      decoded['isArchived'] = isArchived ? 1 : 0;
      raw[index] = jsonEncode(decoded);
      await p.setStringList(_storageKey, raw);
      return 1;
    }
    return 0;
  }
}
