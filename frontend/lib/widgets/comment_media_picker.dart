import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/sticker_service.dart';
import '../models/sticker_model.dart';
import '../services/emoticon_data_service.dart';
import '../models/emoticon_model.dart';
import '../services/api_service.dart';
import 'package:dio/dio.dart';
import '../screens/insight/stickers/create_sticker_page.dart';

class CommentMediaPicker extends StatefulWidget {
  final Function({required String type, String? content, String? mediaUrl}) onSelected;

  const CommentMediaPicker({super.key, required this.onSelected});

  @override
  State<CommentMediaPicker> createState() => _CommentMediaPickerState();
}

class _CommentMediaPickerState extends State<CommentMediaPicker> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StickerService _stickerService = StickerService();
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  final String _giphyApiKey = 'KaG7M2d2fNCrcNGI5ceGhqVt4WZpJNOR';

  List<StickerModel> _myStickers = [];
  List<StickerModel> _publicStickers = [];
  List<EmoticonModel> _filteredEmoticons = [];
  List<Map<String, dynamic>> _giphyResults = [];
  
  bool _isLoading = true;
  bool _isGiphyLoading = false;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _filteredEmoticons = EmoticonDataService.allEmoticons;
    _loadInitialData();
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      if (_tabController.index == 2 || _tabController.index == 3) {
        if (_giphyResults.isEmpty) {
          _fetchGiphyTrending(_tabController.index == 2 ? 'stickers' : 'gifs');
        }
      }
    });
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final my = await _stickerService.getMyStickers();
      final public = await _stickerService.getPublicStickers();
      setState(() {
        _myStickers = my;
        _publicStickers = public;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      
      final index = _tabController.index;
      if (index == 0) {
        // Emoticons
        setState(() {
          _filteredEmoticons = EmoticonDataService.search(query);
        });
      } else if (index == 1) {
        // Stickers - client side filter for now
        setState(() {
          // This would ideally call a search API but filter local list is fine for picker
        });
      } else if (index == 2 || index == 3) {
        // Giphy
        _fetchGiphySearch(query, index == 2 ? 'stickers' : 'gifs');
      }
    });
  }

  Future<void> _fetchGiphyTrending(String type) async {
    setState(() => _isGiphyLoading = true);
    try {
      final endpoint = type == 'stickers' ? 'stickers/trending' : 'gifs/trending';
      final response = await _apiService.dio.get(
        'https://api.giphy.com/v1/$endpoint',
        queryParameters: {'api_key': _giphyApiKey, 'limit': 20, 'rating': 'g'},
      );
      setState(() {
        _giphyResults = List<Map<String, dynamic>>.from(response.data['data']);
        _isGiphyLoading = false;
      });
    } catch (e) {
      setState(() => _isGiphyLoading = false);
    }
  }

  Future<void> _fetchGiphySearch(String query, String type) async {
    if (query.isEmpty) {
      _fetchGiphyTrending(type);
      return;
    }
    setState(() => _isGiphyLoading = true);
    try {
      final endpoint = type == 'stickers' ? 'stickers/search' : 'gifs/search';
      final response = await _apiService.dio.get(
        'https://api.giphy.com/v1/$endpoint',
        queryParameters: {'api_key': _giphyApiKey, 'q': query, 'limit': 20, 'rating': 'g'},
      );
      setState(() {
        _giphyResults = List<Map<String, dynamic>>.from(response.data['data']);
        _isGiphyLoading = false;
      });
    } catch (e) {
      setState(() => _isGiphyLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search vibes...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF3B82F6)),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF3B82F6),
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'Kaomoji'),
              Tab(text: 'Stickers'),
              Tab(text: 'Giphy'),
              Tab(text: 'GIFs'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEmoticonGrid(),
                _buildStickerGrid(),
                _buildGiphyGrid('stickers'),
                _buildGiphyGrid('gifs'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmoticonGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _filteredEmoticons.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => widget.onSelected(type: 'emoticon', content: _filteredEmoticons[index].face),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(_filteredEmoticons[index].face, style: const TextStyle(fontSize: 14)),
          ),
        );
      },
    );
  }

  Widget _buildStickerGrid() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    final allStickers = [..._myStickers, ..._publicStickers];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: allStickers.length + 1, // +1 for the Create Sticker button
      itemBuilder: (context, index) {
        if (index == 0) {
          // Create Sticker Button
          return InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateStickerPage()),
              );
              if (result == true) {
                _loadInitialData(); // Refresh after creating
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.5), width: 1.5, style: BorderStyle.solid),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.add_a_photo, color: Color(0xFF3B82F6), size: 28),
                   SizedBox(height: 8),
                   Text('Create', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          );
        }

        final stickerIdx = index - 1;
        return InkWell(
          onTap: () => widget.onSelected(type: 'sticker', mediaUrl: allStickers[stickerIdx].imageUrl),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(allStickers[stickerIdx].imageUrl, fit: BoxFit.contain),
          ),
        );
      },
    );
  }

  Widget _buildGiphyGrid(String type) {
    if (_isGiphyLoading) return const Center(child: CircularProgressIndicator());
    if (_giphyResults.isEmpty) return const Center(child: Text('No results found'));

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _giphyResults.length,
      itemBuilder: (context, index) {
        final url = _giphyResults[index]['images']['fixed_width_small']['url'];
        return InkWell(
          onTap: () => widget.onSelected(type: type, mediaUrl: url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(url, fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}
