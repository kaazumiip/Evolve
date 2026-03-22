import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/sticker_model.dart';
import '../../../services/sticker_service.dart';
import 'create_sticker_page.dart';
import '../../../generated/l10n/app_localizations.dart';

class StickerPage extends StatefulWidget {
  const StickerPage({super.key});

  @override
  State<StickerPage> createState() => _StickerPageState();
}

class _StickerPageState extends State<StickerPage> with SingleTickerProviderStateMixin {
  final StickerService _stickerService = StickerService();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  
  List<StickerModel> _publicStickers = [];
  List<StickerModel> _myStickers = [];
  List<StickerModel> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;

  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color bgColor = Color(0xFFF8FAFF);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStickers();
  }

  Future<void> _loadStickers() async {
    setState(() => _isLoading = true);
    try {
      final public = await _stickerService.getPublicStickers();
      final my = await _stickerService.getMyStickers();
      setState(() {
        _publicStickers = public;
        _myStickers = my;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToLoadStickers)),
        );
      }
    }
  }

  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results = await _stickerService.searchStickers(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchBar(),
            const SizedBox(height: 10),
            _buildTabBar(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: primaryBlue))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStickerGrid(_isSearching ? _searchResults : _publicStickers, isPublic: true),
                      _buildStickerGrid(_myStickers, isPublic: false),
                    ],
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateStickerPage()),
          );
          if (result == true) {
            _loadStickers();
          }
        },
        backgroundColor: primaryBlue,
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        label: Text(AppLocalizations.of(context)!.createSticker, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            AppLocalizations.of(context)!.stickerStudio,
            style: GoogleFonts.raleway(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _handleSearch,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.searchPublicStickers,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: const Icon(Icons.search, color: primaryBlue),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: primaryBlue,
      labelColor: primaryBlue,
      unselectedLabelColor: Colors.grey,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      tabs: [
        Tab(text: AppLocalizations.of(context)!.publicStore),
        Tab(text: AppLocalizations.of(context)!.myStickers),
      ],
    );
  }

  Widget _buildStickerGrid(List<StickerModel> stickers, {required bool isPublic}) {
    if (stickers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.style_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              isPublic ? AppLocalizations.of(context)!.noPublicStickersFound : AppLocalizations.of(context)!.haventCreatedStickersYet,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: stickers.length,
      itemBuilder: (context, index) {
        final sticker = stickers[index];
        return GestureDetector(
          onTap: () {
             // Show sticker details or use it
             _showStickerOverlay(sticker);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                sticker.imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showStickerOverlay(StickerModel sticker) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(image: NetworkImage(sticker.imageUrl), fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 20),
            Text(sticker.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(AppLocalizations.of(context)!.createdBy(sticker.creatorName ?? "You"), style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Logic to "use" sticker (e.g., share or copy URL)
                      Clipboard.setData(ClipboardData(text: sticker.imageUrl));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.stickerLinkCopied)));
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.copy, color: Colors.white),
                    label: Text(AppLocalizations.of(context)!.copyLink, style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
