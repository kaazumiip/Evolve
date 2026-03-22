import 'package:flutter/material.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'dart:io';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import '../../services/community_service.dart';
import 'package:google_fonts/google_fonts.dart';

Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB);

class CreatePostScreen extends StatefulWidget {
  final int? editPostId;
  final String? initialTitle;
  final String? initialBody;
  final List<String>? initialTags;
  final List<String>? initialMediaUrls;

  const CreatePostScreen({
    super.key, 
    this.editPostId, 
    this.initialTitle, 
    this.initialBody, 
    this.initialTags,
    this.initialMediaUrls,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class MediaItem {
  final File? file;
  final String? url;
  final bool isVideo;
  MediaItem({this.file, this.url, required this.isVideo});
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  final _tagController = TextEditingController();
  late List<String> _tags;
  bool _isLoading = false;
  final CommunityService _communityService = CommunityService();
  List<MediaItem> _selectedMediaItems = [];
  final List<String> _recommendedTags = ['Technology', 'Scholarship', 'Career', 'Study', 'Questions', 'Events', 'Tips', 'Help'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _bodyController = TextEditingController(text: widget.initialBody);
    _tags = widget.initialTags != null ? List.from(widget.initialTags!) : [];
    
    if (widget.initialMediaUrls != null) {
      for (var url in widget.initialMediaUrls!) {
        bool isVid = url.toLowerCase().endsWith('.mp4') || url.toLowerCase().endsWith('.mov') || url.contains('video/upload');
        _selectedMediaItems.add(MediaItem(url: url, isVideo: isVid));
      }
    }
  }

  Future<void> _pickMedia(bool video) async {
    final picker = ImagePicker();
    if (video) {
       final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
       if (pickedFile != null) {
         setState(() {
           _selectedMediaItems.add(MediaItem(file: File(pickedFile.path), isVideo: true));
         });
       }
    } else {
       final List<XFile> pickedFiles = await picker.pickMultipleMedia();
       if (pickedFiles.isNotEmpty) {
         setState(() {
           for (var f in pickedFiles) {
              bool isVid = f.path.toLowerCase().endsWith('.mp4') || f.path.toLowerCase().endsWith('.mov') || f.path.contains('video/upload');
              _selectedMediaItems.add(MediaItem(file: File(f.path), isVideo: isVid));
           }
         });
       }
    }
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _submitPost() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFillInTitleAndContent)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> mediaUrls = [];
      String? firstImageUrl;

      // Handle both new File uploads and existing URLs
      for (var media in _selectedMediaItems) {
        if (media.file != null) {
          final result = await _communityService.uploadMedia(media.file);
          mediaUrls.add(result['url']);
          if (firstImageUrl == null && !media.isVideo) firstImageUrl = result['url'];
        } else if (media.url != null) {
          mediaUrls.add(media.url!);
          if (firstImageUrl == null && !media.isVideo) firstImageUrl = media.url!;
        }
      }

      if (widget.editPostId != null) {
        // Edit Mode
        await _communityService.updatePost(
          widget.editPostId!,
          _titleController.text,
          _bodyController.text,
          _tags,
          imageUrl: firstImageUrl,
          mediaUrls: mediaUrls,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.postUpdatedSuccessfully)));
          Navigator.pop(context, true);
        }
      } else {
        // Create Mode
        await _communityService.createPost(
          _titleController.text,
          _bodyController.text,
          _tags,
          imageUrl: firstImageUrl,
          mediaUrls: mediaUrls,
        );
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.postCreatedSuccessfully)));
           Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.editPostId != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      appBar: AppBar(
        title: Text(
          isEdit ? AppLocalizations.of(context)!.editPost : AppLocalizations.of(context)!.createPost,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : const Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue(context),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(isEdit ? AppLocalizations.of(context)!.save : AppLocalizations.of(context)!.postAction, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B)),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.postTitle,
                hintStyle: GoogleFonts.outfit(color: const Color(0xFF94A3B8)),
                border: InputBorder.none,
              ),
            ),
            const Divider(),
            
            // Expanded body ensures it takes up most of the space!
            Expanded(
              child: TextField(
                controller: _bodyController,
                maxLines: null,
                expands: true, // Takes available space
                textAlignVertical: TextAlignVertical.top,
                style: GoogleFonts.outfit(fontSize: 16, color: isDark ? Colors.white70 : const Color(0xFF334155), height: 1.6),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.whatsOnYourMind,
                  hintStyle: GoogleFonts.outfit(color: const Color(0xFF94A3B8)),
                  border: InputBorder.none,
                ),
              ),
            ),
            
            // Always show Media Pickers
            // Media Preview
            if (_selectedMediaItems.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedMediaItems.length,
                  itemBuilder: (context, index) {
                    final item = _selectedMediaItems[index];
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: item.isVideo ? null : DecorationImage(
                              image: item.file != null 
                                  ? FileImage(item.file!) as ImageProvider 
                                  : NetworkImage(item.url!), 
                              fit: BoxFit.cover
                            ),
                            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                          ),
                          child: item.isVideo ? Center(child: Icon(Icons.play_circle_fill, color: isDark ? Colors.white70 : Colors.white, size: 40)) : null,
                        ),
                        Positioned(
                          top: 4, right: 16,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedMediaItems.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
              
            const SizedBox(height: 50),
            
            // Post Actions Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _pickMedia(false),
                    icon: const Icon(Icons.image_rounded, color: Color(0xFF10B981)),
                    tooltip: 'Add Photos',
                  ),
                  IconButton(
                    onPressed: () => _pickMedia(true),
                    icon: const Icon(Icons.video_collection_rounded, color: Color(0xFF6366F1)),
                    tooltip: 'Add Video',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            
            // Tags Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _tagController,
                  onSubmitted: (_) => _addTag(),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.addDescriptiveTags,
                    hintStyle: GoogleFonts.outfit(color: const Color(0xFF94A3B8)),
                    suffixIcon: IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _addTag),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: kPrimaryBlue(context))),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Recommended Tags
                if (_tags.isEmpty) ...[
                  Text(AppLocalizations.of(context)!.recommendedTags, style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF94A3B8))),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _recommendedTags.map((tag) => InkWell(
                        onTap: () {
                          setState(() {
                            if (!_tags.contains(tag)) _tags.add(tag);
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            '#${tag.toLowerCase()}',
                            style: GoogleFonts.outfit(
                              color: kPrimaryBlue(context),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ],

                if (_tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _tags.map((tag) => Chip(
                      label: Text(tag),
                      onDeleted: () => _removeTag(tag),
                      backgroundColor: kPrimaryBlue(context).withOpacity(0.1),
                      labelStyle: TextStyle(color: kPrimaryBlue(context)),
                      deleteIconColor: kPrimaryBlue(context),
                      side: BorderSide.none,
                    )).toList(),
                  ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
