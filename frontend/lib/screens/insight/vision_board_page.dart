import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../generated/l10n/app_localizations.dart';

import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../../models/vision_model.dart';

Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB);

class VisionBoardPage extends StatefulWidget {
  const VisionBoardPage({Key? key}) : super(key: key);

  @override
  State<VisionBoardPage> createState() => _VisionBoardPageState();
}

class _VisionBoardPageState extends State<VisionBoardPage> {
  static const Color kBlue = Color(0xFF3B82F6);

  final List<VisionItem> _items = [];
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  List<dynamic> _pexelsResults = [];
  bool _isSearchingPexels = false;
  Timer? _searchDebounce;
  bool _isDragging = false;
  bool _isOverDelete = false;
  final String _pexelsApiKey = 'wvgxIIaKzBDTkY9fDvEcMJ5EDGEOG4cK20sQLtppxLgpxhWxMA32QAJWUK';

  // ─────────────────────────────────────────────
  //  STEP 5 — Load when page starts
  // ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadItems(); // ⭐ Load saved data on startup
  }

  // ── pick image ──
  Future<void> _pickImage() async {
    final source = await _showImageSourceSheet();
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    // STEP 6 — Save after adding image
    setState(() {
      _items.add(VisionItem(
        id: UniqueKey().toString(),
        imagePath: picked.path,
        x: 20 + (_items.length % 3) * 180.0,
        y: 20 + (_items.length ~/ 3) * 200.0,
      ));
    });

    await _saveItems(); // ⭐ SAVE HERE
  }

  // ── source chooser sheet ──
  Future<ImageSource?> _showImageSourceSheet() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.addAPicture,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.chooseHowToAddImage,
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Gallery
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: kBlue.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: kBlue.withValues(alpha: 0.25), width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: kBlue,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.photo_library_rounded,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 12),
                          Text(AppLocalizations.of(context)!.gallery,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text(AppLocalizations.of(context)!.pickFromPhotos,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade500),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Camera
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.green.withValues(alpha: 0.25), width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.green.shade500,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 12),
                          Text(AppLocalizations.of(context)!.camera,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green)),
                          const SizedBox(height: 4),
                          Text(AppLocalizations.of(context)!.takeNewPhoto,
                              style: TextStyle(
                                  fontSize: 11, color: isDark ? Colors.white38 : Colors.grey.shade500),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context, null),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(AppLocalizations.of(context)!.cancel,
                    style:
                    TextStyle(color: Colors.grey.shade500, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── STEP 4 — SAVE FUNCTION ──
  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _items.map((item) => item.toJson()).toList();
    await prefs.setString("vision_items", jsonEncode(data));
  }

  // ── STEP 4 — LOAD FUNCTION ──
  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString("vision_items");
    if (savedData == null) return;

    final List decoded = jsonDecode(savedData);
    setState(() {
      _items.clear();
      _items.addAll(decoded.map((e) => VisionItem.fromJson(e)).toList());
    });
  }

  // ── long-press edit ──
  void _openEditSheet(VisionItem item) {
    final captionCtrl = TextEditingController(text: item.caption ?? '');
    double tempW = item.width;
    double tempH = item.height;
    double tempRot = item.rotation;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.editCard,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey.shade800)),
              const SizedBox(height: 20),

              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(item.imagePath),
                      width: 120, height: 120, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),

              _sliderRow(
                  label: AppLocalizations.of(context)!.width,
                  value: tempW,
                  min: 80,
                  max: 320,
                  onChanged: (v) => setSheetState(() => tempW = v)),
              _sliderRow(
                  label: AppLocalizations.of(context)!.height,
                  value: tempH,
                  min: 80,
                  max: 320,
                  onChanged: (v) => setSheetState(() => tempH = v)),
              _sliderRow(
                  label: AppLocalizations.of(context)!.rotation,
                  value: tempRot,
                  min: -180,
                  max: 180,
                  onChanged: (v) => setSheetState(() => tempRot = v)),
              const SizedBox(height: 12),

              TextField(
                controller: captionCtrl,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.captionOptional,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kBlue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  // STEP 6 — Delete + Save
                  Expanded(
                    child: OutlinedButton.icon(
                      // ⭐ FIXED: async + save after delete
                      onPressed: () async {
                        setState(() => _items.remove(item));
                        await _saveItems(); // ⭐ SAVE
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: Text(AppLocalizations.of(context)!.delete,
                          style: const TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      // ⭐ FIXED: async + save after edit
                      onPressed: () async {
                        setState(() {
                          item.width = tempW;
                          item.height = tempH;
                          item.rotation = tempRot;
                          item.caption = captionCtrl.text.trim().isEmpty
                              ? null
                              : captionCtrl.text.trim();
                        });
                        await _saveItems(); // ⭐ SAVE
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(AppLocalizations.of(context)!.save,
                          style:
                          const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
            width: 70,
            child: Text(label,
                style:
                TextStyle(fontSize: 13, color: Colors.grey.shade600))),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            activeColor: kBlue,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(value.toStringAsFixed(0),
              style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Timer? _longPressTimer;

  void _startLongPress(VisionItem item) {
    _longPressTimer = Timer(const Duration(seconds: 5), () {
      _openEditSheet(item);
    });
  }

  void _cancelLongPress() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  Future<void> _searchPexels(String query) async {
    if (query.isEmpty) {
      setState(() {
        _pexelsResults = [];
        _isSearchingPexels = false;
      });
      return;
    }

    setState(() => _isSearchingPexels = true);

    try {
      final response = await http.get(
        Uri.parse('https://api.pexels.com/v1/search?query=$query&per_page=10'),
        headers: {'Authorization': _pexelsApiKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _pexelsResults = data['photos'];
          _isSearchingPexels = false;
        });
      }
    } catch (e) {
      print('Pexels search error: $e');
      setState(() => _isSearchingPexels = false);
    }
  }

  void _onSearchChanged(String v) {
    setState(() => _searchQuery = v);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _searchPexels(v);
    });
  }

  void _addRemoteImage(Map<String, dynamic> photo) async {
    setState(() {
      _items.add(VisionItem(
        id: UniqueKey().toString(),
        imagePath: '', // Local path empty for remote
        isRemote: true,
        url: photo['src']['large'],
        caption: photo['alt'],
        x: 20 + (_items.length % 3) * 180.0,
        y: 20 + (_items.length ~/ 3) * 200.0,
      ));
      _searchCtrl.clear();
      _searchQuery = '';
      _pexelsResults = [];
    });
    await _saveItems();
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = kPrimaryBlue(context);
    final bgColor = isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFF2F2F7);

    final filtered = _searchQuery.isEmpty
        ? _items
        : _items
        .where((i) =>
    i.caption
        ?.toLowerCase()
        .contains(_searchQuery.toLowerCase()) ??
        false)
        .toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(

                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Icon(Icons.chevron_left,
                        size: 28, color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.hub_outlined,
                      color: isDark ? Colors.white70 : Colors.black87, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.visionBoard,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add,
                          color: Colors.white, size: 26),
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFD1D5DB)),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchForInspiration,
                    hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    prefixIcon: Icon(Icons.search,
                        color: Colors.grey.shade400, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear,
                          color: Colors.grey.shade400, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                        : null,
                  ),
                ),
              ),
            ),

            if (_pexelsResults.isNotEmpty || _isSearchingPexels)
              Container(
                height: 120,
                margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: _isSearchingPexels 
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      itemCount: _pexelsResults.length,
                      itemBuilder: (ctx, i) {
                        final photo = _pexelsResults[i];
                        return GestureDetector(
                          onTap: () => _addRemoteImage(photo),
                          child: Container(
                            width: 96,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(photo['src']['tiny']),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: const Icon(Icons.add_circle, color: Colors.white70),
                          ),
                        );
                      },
                    ),
              ),

            const SizedBox(height: 16),

            // Grid
            Expanded(
              child: filtered.isEmpty
                  ? _emptyState()
                  : Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ReorderableGridView.builder(
                            padding: const EdgeInsets.only(bottom: 100),
                            gridDelegate: SliverQuiltedGridDelegate(
                              crossAxisCount: 4,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              repeatPattern: QuiltedGridRepeatPattern.mirrored,
                              pattern: [
                                const QuiltedGridTile(2, 2),
                                const QuiltedGridTile(1, 1),
                                const QuiltedGridTile(1, 1),
                                const QuiltedGridTile(1, 2),
                              ],
                            ),
                            itemCount: filtered.length,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                final item = filtered.removeAt(oldIndex);
                                filtered.insert(newIndex, item);
                                _saveItems();
                              });
                            },
                            onDragStart: (index) {
                              setState(() {
                                _isDragging = true;
                              });
                            },
                            itemBuilder: (ctx, i) {
                              final item = filtered[i];
                              return Listener(
                                key: ValueKey(item.id),
                                onPointerUp: (_) {
                                  if (_isDragging) {
                                    setState(() {
                                      _isDragging = false;
                                      _isOverDelete = false;
                                    });
                                  }
                                },
                                child: _buildCard(item),
                              );
                            },
                          ),
                        ),
                        if (_isDragging)
                          Positioned(
                            bottom: 30,
                            left: 0,
                            right: 0,
                            child: DragTarget<Object>(
                              onWillAccept: (data) {
                                setState(() => _isOverDelete = true);
                                return true;
                              },
                              onLeave: (data) {
                                setState(() => _isOverDelete = false);
                              },
                              onAccept: (data) {
                                // Find the item by id from the data
                                // In this version, data is the ReorderableItemView but we cast carefully
                                final String? draggedId = (data is ReorderableItemView) ? (data.key as ValueKey).value : null;
                                if (draggedId != null) {
                                setState(() {
                                  _items.removeWhere((item) => item.id == draggedId);
                                  _isDragging = false;
                                  _isOverDelete = false;
                                  _saveItems();
                                  });
                                  HapticFeedback.heavyImpact();
                                }
                              },
                              builder: (context, candidateData, rejectedData) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(horizontal: 100),
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  decoration: BoxDecoration(
                                    color: _isOverDelete ? Colors.red : Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(color: Colors.red, width: 2),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isOverDelete ? Icons.delete_forever : Icons.delete_outline,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Drop here to delete",
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(VisionItem item) {
    return GestureDetector(
      onLongPress: () => _openEditSheet(item),
      child: Transform.rotate(
        angle: item.rotation * 3.14159 / 180,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                item.isRemote 
                    ? Image.network(item.url!, fit: BoxFit.cover, 
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null));
                        })
                    : Image.file(File(item.imagePath), fit: BoxFit.cover),
                if (item.caption != null && item.caption!.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.6),
                            Colors.transparent
                          ],
                        ),
                      ),
                      child: Text(
                        item.caption!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.touch_app,
                        color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_library_outlined,
              size: 64, color: isDark ? Colors.white10 : Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? AppLocalizations.of(context)!.noResultsFor(_searchQuery)
                : AppLocalizations.of(context)!.visionBoardEmpty,
            style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade500, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)!.tapToAddFirstImage,
               style: TextStyle(color: isDark ? Colors.white24 : Colors.grey.shade400, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _longPressTimer?.cancel();
    super.dispose();
  }
}
