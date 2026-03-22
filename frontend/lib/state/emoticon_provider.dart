import 'package:flutter/material.dart';
import '../models/emoticon_model.dart';
import '../services/emoticon_data_service.dart';
import '../services/emoticon_storage_service.dart';

class EmoticonProvider extends ChangeNotifier {
  // ─── State ───────────────────────────────────────────────────────────────────
  String _selectedCategory = 'All';
  String _searchQuery = '';
  List<RecentEmoticon> _recents = [];
  List<EmoticonModel> _customEmoticons = [];
  bool _isLoading = false;

  // ─── Getters ─────────────────────────────────────────────────────────────────
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<RecentEmoticon> get recents => _recents;
  List<EmoticonModel> get customEmoticons => _customEmoticons;
  bool get isLoading => _isLoading;

  static const List<String> filterCategories = [
    'All', 'Happy', 'Sleepy', 'Excited', 'Angry', 'Hugging', 'Love', 'Sad',
  ];

  List<EmoticonModel> get filteredEmoticons {
    List<EmoticonModel> base;
    List<EmoticonModel> filteredCustom;

    if (_searchQuery.isNotEmpty) {
      // Search mode: filter both built-in AND custom by query text or category name
      base = EmoticonDataService.search(_searchQuery);
      filteredCustom = _customEmoticons.where((e) =>
      e.face.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.category.toLowerCase().contains(_searchQuery.toLowerCase()),
      ).toList();
    } else {
      // Category mode: filter both by selected category
      base = EmoticonDataService.filterByCategory(_selectedCategory);
      filteredCustom = _selectedCategory == 'All'
          ? _customEmoticons
          : _customEmoticons.where((e) => e.category == _selectedCategory).toList();
    }

    return [...filteredCustom, ...base];
  }

  List<EmoticonModel> get trendingEmoticons => EmoticonDataService.getTrending();

  // ─── Actions ─────────────────────────────────────────────────────────────────
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    await _loadData();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadData() async {
    _recents = await EmoticonStorageService.getRecents();
    _customEmoticons = await EmoticonStorageService.getCustomEmoticons();
  }

  bool _showAll = false;
  bool get showAll => _showAll;

  void toggleShowAll() {
    _showAll = true;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    _searchQuery = '';
    _showAll = false;
    notifyListeners();
  }

  void updateSearch(String query) {
    _searchQuery = query;
    _showAll = false;
    notifyListeners();
  }

  Future<void> copyEmoticon(EmoticonModel emoticon) async {
    await EmoticonStorageService.addToRecents(emoticon);
    _recents = await EmoticonStorageService.getRecents();
    notifyListeners();
  }

  Future<void> saveCustomEmoticon(EmoticonModel emoticon) async {
    await EmoticonStorageService.saveCustomEmoticon(emoticon);
    _customEmoticons = await EmoticonStorageService.getCustomEmoticons();
    notifyListeners();
  }

  Future<void> deleteCustomEmoticon(String face) async {
    await EmoticonStorageService.deleteCustomEmoticon(face);
    _customEmoticons = await EmoticonStorageService.getCustomEmoticons();
    notifyListeners();
  }

  Future<void> clearRecents() async {
    await EmoticonStorageService.clearRecents();
    _recents = [];
    notifyListeners();
  }
}
