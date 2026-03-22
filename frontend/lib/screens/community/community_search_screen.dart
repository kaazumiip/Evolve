import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/community_service.dart';
import '../../services/api_service.dart';
import 'post_card.dart';
import 'post_detail_screen.dart';
import 'user_profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'dart:convert';
Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB);

class CommunitySearchScreen extends StatefulWidget {
  final String initialQuery;
  const CommunitySearchScreen({super.key, this.initialQuery = ''});

  @override
  State<CommunitySearchScreen> createState() => _CommunitySearchScreenState();
}

class _CommunitySearchScreenState extends State<CommunitySearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final CommunityService _communityService = CommunityService();
  Timer? _debounce;

  List<dynamic> _people = [];
  List<dynamic> _tags = [];
  List<dynamic> _posts = [];

  bool _isLoadingPeople = false;
  bool _isLoadingTags = false;
  bool _isLoadingPosts = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.text = widget.initialQuery;
    if (widget.initialQuery.isNotEmpty) {
      _performSearch(widget.initialQuery);
    } else {
      _loadRecommendations();
    }
  }

  Future<void> _loadRecommendations() async {
    setState(() => _isLoadingPeople = true);
    try {
      final results = await _communityService.getRecommendations();
      if (mounted) {
        setState(() => _people = results);
      }
    } catch (e) {
      print("Error loading recommendations: $e");
    } finally {
      if (mounted) setState(() => _isLoadingPeople = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      _loadRecommendations();
      setState(() {
        _tags = [];
        _posts = [];
      });
      return;
    }
    
    _searchPeople(query);
    _searchTags(query);
    _searchPosts(query);
  }

  Future<void> _searchPeople(String query) async {
    setState(() => _isLoadingPeople = true);
    try {
      final results = await _communityService.searchUsers(query);
      setState(() => _people = results);
    } catch (e) {
      print("Search people error: $e");
    } finally {
      setState(() => _isLoadingPeople = false);
    }
  }

  Future<void> _searchTags(String query) async {
    setState(() => _isLoadingTags = true);
    try {
      final results = await _communityService.searchByTag(query);
      setState(() => _tags = results);
    } catch (e) {
      print("Search tags error: $e");
    } finally {
      setState(() => _isLoadingTags = false);
    }
  }

  Future<void> _searchPosts(String query) async {
    setState(() => _isLoadingPosts = true);
    try {
      final results = await _communityService.searchPosts(query);
      setState(() => _posts = results);
    } catch (e) {
      print("Search posts error: $e");
    } finally {
      setState(() => _isLoadingPosts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: kPrimaryBlue(context).withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kPrimaryBlue(context).withOpacity(0.1)),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onSubmitted: _performSearch,
            style: GoogleFonts.outfit(fontSize: 14, color: titleColor),
            decoration: InputDecoration(
              hintText: 'Search people, tags, or posts...',
              hintStyle: GoogleFonts.outfit(fontSize: 14, color: isDark ? Colors.white38 : const Color(0xFF94A3B8)),
              prefixIcon: Icon(Icons.search_rounded, size: 20, color: kPrimaryBlue(context)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: kPrimaryBlue(context),
          unselectedLabelColor: isDark ? Colors.white38 : const Color(0xFF94A3B8),
          indicatorColor: kPrimaryBlue(context),
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'People'),
            Tab(text: 'Tags'),
            Tab(text: 'Related Posts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPeopleList(),
          _buildPostsList(_tags, _isLoadingTags, "No posts found for this tag"),
          _buildPostsList(_posts, _isLoadingPosts, "No related posts found"),
        ],
      ),
    );
  }

   Widget _buildPeopleList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isLoadingPeople) return Center(child: CircularProgressIndicator(color: kPrimaryBlue(context)));
    if (_people.isEmpty) return _buildEmptyState("No people found");

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: _people.length,
      itemBuilder: (context, index) {
        final user = _people[index];
        final String name = user['name'] ?? 'Unknown';
        final String? image = user['profile_picture'];

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: image != null && image.isNotEmpty ? NetworkImage(image) : null,
            backgroundColor: kPrimaryBlue(context).withOpacity(0.1),
            child: (image == null || image.isEmpty) ? Text(name[0].toUpperCase(), style: GoogleFonts.outfit(color: kPrimaryBlue(context), fontWeight: FontWeight.bold)) : null,
          ),
          title: Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF1E293B))),
          subtitle: Text(user['email'] ?? '', style: GoogleFonts.outfit(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF64748B))),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfileScreen(
                  userId: user['id'],
                  userName: name,
                  userImage: image ?? '',
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPostsList(List<dynamic> items, bool loading, String emptyMsg) {
    if (loading) return Center(child: CircularProgressIndicator(color: kPrimaryBlue(context)));
    if (items.isEmpty) return _buildEmptyState(emptyMsg);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final post = items[index];
        
        String timeDisplay = 'Just now';
        try {
          if (post['created_at'] != null) {
            timeDisplay = timeago.format(DateTime.parse(post['created_at']));
          }
        } catch (_) {}

        return PostCard(
          id: post['id'],
          userId: post['user_id'] ?? 0,
          userName: post['userName'] ?? 'Unknown',
          userImage: post['userImage'],
          userStreak: post['current_streak'] ?? 0,
          timeAgo: timeDisplay,
          viewCount: '${post['view_count'] ?? 0}',
          title: post['title'] ?? '',
          body: post['body'] ?? '',
          imageUrl: post['image_url'] != null && post['image_url'].toString().isNotEmpty
              ? (post['image_url'].toString().startsWith('http') 
                  ? post['image_url'] 
                  : '${ApiService.baseUrl.replaceFirst('/api', '')}/${post['image_url']}')
              : null,
          mediaUrls: _safeParseList(post['media_urls']),
          tags: _safeParseList(post['tags']),
          likeCount: post['likeCount'] ?? 0,
          commentCount: post['commentCount'] ?? 0,
          isLiked: post['isLiked'] == 1 || post['isLiked'] == true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailScreen(postData: post),
              ),
            ).then((_) => _performSearch(_searchController.text));
          },
          onLike: () async {
            await _communityService.toggleLike(post['id']);
            _performSearch(_searchController.text);
          },
          onDelete: () => _performSearch(_searchController.text),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kPrimaryBlue(context).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off_rounded, size: 48, color: kPrimaryBlue(context).withOpacity(0.3)),
          ),
          const SizedBox(height: 20),
          Text(message, style: GoogleFonts.outfit(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  List<String> _safeParseList(dynamic data) {
    if (data == null) return [];
    if (data is List) return List<String>.from(data);
    if (data is String) {
      if (data.trim().isEmpty) return [];
      try {
        final decoded = jsonDecode(data);
        if (decoded is List) return List<String>.from(decoded);
      } catch (_) {
        return [data];
      }
    }
    return [];
  }
}
