import 'package:flutter/material.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_profile_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/auth_service.dart';
import '../../services/community_service.dart';
import '../../services/api_service.dart';
import 'media_full_screen_page.dart';
import 'create_post_screen.dart';


Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB);
Color kStreakOrange(BuildContext context) => Theme.of(context).brightness == Brightness.dark 
    ? const Color(0xFF8B5CF6) // Purple in dark mode
    : const Color(0xFFF97316); // Orange in light mode

class PostCard extends StatefulWidget {
  final int id;
  final int userId;
  final String userName;
  final String? userImage;
  final int userStreak;
  final String timeAgo;
  final String viewCount;
  final bool isVerified;
  final bool isHot;
  final String title;
  final String body;
  final String? imageUrl;
  final List<String>? mediaUrls;
  final List<String> tags;
  final int likeCount;
  final int commentCount;
  final VoidCallback onTap;
  final bool isLiked;
  final VoidCallback onLike;

  final int? currentUserId;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.id,
    required this.userId,
    required this.userName,
    this.userImage,
    this.userStreak = 0,
    required this.timeAgo,
    required this.viewCount,
    this.isVerified = false,
    this.isHot = false,
    required this.title,
    required this.body,
    this.imageUrl,
    this.mediaUrls,
    required this.tags,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
    required this.onTap,
    required this.onLike,
    this.currentUserId,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideo = false;
  int? _currentUserId;
  final AuthService _authService = AuthService();
  final CommunityService _communityService = CommunityService();
  final ApiService _apiService = ApiService();
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _checkVideo();
    _fetchCurrentUserId();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final status = await _apiService.checkFavorite('post', widget.id);
    if (mounted) {
      setState(() {
        _isFavorited = status;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isFavorited = !_isFavorited); // Optimistic updating
    final result = await _apiService.toggleFavorite('post', widget.id);
    if (mounted) {
      setState(() {
        _isFavorited = result['isFavorited'] ?? false;
      });
    }
  }

  Future<void> _fetchCurrentUserId() async {
    try {
      final user = await _authService.getUser();
      if (mounted) setState(() => _currentUserId = user['id']);
    } catch (_) {}
  }

  void _checkVideo() {
    if (widget.imageUrl != null && (
        widget.imageUrl!.toLowerCase().endsWith('.mp4') || 
        widget.imageUrl!.toLowerCase().endsWith('.mov') ||
        widget.imageUrl!.toLowerCase().contains('video/upload') // Cloudinary convention
    )) {
      _isVideo = true;
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.imageUrl!));
    await _videoController!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: false,
      looping: false,
      aspectRatio: _videoController!.value.aspectRatio,
      placeholder: const Center(child: CircularProgressIndicator()),
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(
                    userId: widget.userId,
                    userName: widget.userName,
                    userImage: widget.userImage ?? '',
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getAvatarColor(widget.userName).withOpacity(0.1),
                    radius: 18,
                    backgroundImage: (widget.userImage != null && widget.userImage!.isNotEmpty) 
                      ? NetworkImage(widget.userImage!) 
                      : null,
                    child: (widget.userImage == null || widget.userImage!.isEmpty)
                      ? Text(
                          widget.userName.isNotEmpty ? widget.userName.substring(0, 1).toUpperCase() : '?',
                          style: GoogleFonts.outfit(
                            color: _getAvatarColor(widget.userName),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.userName,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            if (widget.userStreak > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: kStreakOrange(context).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.local_fire_department, size: 14, color: kStreakOrange(context)),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${widget.userStreak}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: kStreakOrange(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (widget.isVerified) ...[
                              const SizedBox(width: 4),
                              Icon(Icons.verified, size: 14, color: kPrimaryBlue(context)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.timeAgo} • ${AppLocalizations.of(context)!.viewsWithCount(widget.viewCount)}',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isHot)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.orange.withOpacity(0.1) : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department, size: 12, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(AppLocalizations.of(context)!.hot,
                            style: GoogleFonts.outfit(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.orange : const Color(0xFFC2410C),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 8),
                  if ((widget.currentUserId ?? _currentUserId) == widget.userId)
                    GestureDetector(
                      onTap: _showOptionsMenu,
                      child: const Icon(Icons.more_horiz_rounded, color: Color(0xFF94A3B8), size: 20),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Content
            Text(
              widget.title,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                height: 1.3,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(0xFF475569),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            
            if ((widget.mediaUrls != null && widget.mediaUrls!.isNotEmpty) || (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  final List<String> urls = (widget.mediaUrls != null && widget.mediaUrls!.isNotEmpty)
                      ? widget.mediaUrls!
                      : [widget.imageUrl!];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MediaFullScreenPage(mediaUrls: urls, initialIndex: _currentPage),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.black26 : Colors.grey.shade100,
                  ),
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (idx) => setState(() => _currentPage = idx),
                        itemCount: (widget.mediaUrls != null && widget.mediaUrls!.isNotEmpty) 
                            ? widget.mediaUrls!.length 
                            : 1,
                        itemBuilder: (context, index) {
                          final String url = (widget.mediaUrls != null && widget.mediaUrls!.isNotEmpty)
                              ? widget.mediaUrls![index]
                              : widget.imageUrl!;
                          
                          final bool isThisVideo = url.toLowerCase().endsWith('.mp4') || 
                                              url.toLowerCase().endsWith('.mov') ||
                                              url.toLowerCase().contains('video/upload');
                          
                          if (isThisVideo) {
                             // Simplified video logic for the feed - only init if needed or use a thumbnail
                             return Container(
                               color: Colors.black,
                               child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white60, size: 50)),
                             );
                          }

                          return Image.network(
                            url,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFFF1F5F9),
                              child: const Icon(Icons.image_not_supported_rounded, color: Color(0xFF94A3B8)),
                            ),
                          );
                        },
                      ),
                      if (widget.mediaUrls != null && widget.mediaUrls!.length > 1)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(widget.mediaUrls!.length, (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index ? kPrimaryBlue(context) : Colors.white.withOpacity(0.5),
                              ),
                            )),
                          ),
                        ),
                      // Multi-media count badge
                      if (widget.mediaUrls != null && widget.mediaUrls!.length > 1)
                         Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_currentPage + 1}/${widget.mediaUrls!.length}',
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Tags
            Wrap(
              spacing: 0,
              children: widget.tags.map((tag) => Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 8),
                child: Text(
                  '#$tag',
                  style: GoogleFonts.outfit(
                    color: kPrimaryBlue(context),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )).toList(),
            ),
            
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            
            // Actions
            Row(
              children: [
                _buildAction(
                  widget.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded, 
                  widget.isLiked ? const Color(0xFFEF4444) : const Color(0xFF94A3B8), 
                  '${widget.likeCount}',
                  onTap: widget.onLike,
                  onLongPress: () => _showLikesList(context),
                  onTextTap: () => _showLikesList(context),
                ),
                const SizedBox(width: 20),
                _buildAction(Icons.chat_bubble_outline_rounded, const Color(0xFF94A3B8), '${widget.commentCount}'),
                const Spacer(),
                InkWell(
                  onTap: () {
                    // Sharing a direct link to the post instead of the full text
                    final String postUrl = 'https://evolve-app.com/posts/${widget.id}';
                    Share.share('Check out this post on Evolve: ${widget.title}\n\n$postUrl');
                  },
                  child: const Icon(Icons.share_outlined, size: 20, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(width: 15),
                InkWell(
                  onTap: _toggleFavorite,
                  child: Icon(
                    _isFavorited ? Icons.star_rounded : Icons.star_border_rounded, 
                    size: 22, 
                    color: _isFavorited ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: kPrimaryBlue(context).withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.edit_rounded, color: kPrimaryBlue(context), size: 20),
                  ),
                  title: Text(AppLocalizations.of(context)!.editPost, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                  subtitle: Text('Modify your post content', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePostScreen(
                          editPostId: widget.id,
                          initialTitle: widget.title,
                          initialBody: widget.body,
                          initialTags: widget.tags,
                          initialMediaUrls: widget.mediaUrls ?? (widget.imageUrl != null ? [widget.imageUrl!] : null),
                        ),
                      ),
                    );
                    if (result == true && widget.onEdit != null) {
                      widget.onEdit!();
                    }
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                  ),
                  title: Text(AppLocalizations.of(context)!.deletePost, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)),
                  subtitle: Text('Permanently remove this post', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteDialog();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: Center(child: Text(AppLocalizations.of(context)!.cancel, style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.w600))),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 32),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.deletePost,
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.areYouSureYouWantToDeleteThisPostThisActionCannotBeUndone,
                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(AppLocalizations.of(context)!.cancel, style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                           try {
                            await _communityService.deletePost(widget.id);
                            if (widget.onDelete != null) {
                              widget.onDelete!();
                            }
                            if (context.mounted) Navigator.pop(context);
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.postDeletedSuccessfully)));
                          } catch (e) {
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          }
                        }, 
                        child: Text(AppLocalizations.of(context)!.delete, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLikesList(BuildContext context) async {
    try {
      final response = await _apiService.dio.get('/community/posts/${widget.id}/likes');
      final List<dynamic> users = response.data;
      if (context.mounted) {
        _showUserListSheet(context, AppLocalizations.of(context)!.likes, users);
      }
    } catch (e) {
      print('Error fetching likes: $e');
    }
  }

  void _showUserListSheet(BuildContext context, String title, List<dynamic> users) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(5)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            Expanded(
              child: users.isEmpty 
                ? Center(child: Text(AppLocalizations.of(context)!.noUsersFound, style: GoogleFonts.outfit()))
                : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return _buildUserListItem(context, user);
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserListItem(BuildContext context, dynamic user) {
    final status = user['friendshipStatus'] ?? 'none';
    final isMe = (widget.currentUserId ?? _currentUserId) == user['id'];

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: (user['profile_picture'] != null && user['profile_picture'].isNotEmpty) 
            ? NetworkImage(user['profile_picture']) 
            : null,
        child: (user['profile_picture'] == null || user['profile_picture'].isEmpty)
            ? Text(user['name']?[0].toUpperCase() ?? '?')
            : null,
      ),
      title: Text(user['name'] ?? 'Unknown', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      trailing: isMe ? null : ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: status == 'none' ? kPrimaryBlue(context) : Colors.grey.shade100,
          foregroundColor: status == 'none' ? Colors.white : Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () async {
          if (status == 'none') {
            await _communityService.sendFriendRequest(user['id']);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.friendRequestSent)));
          }
        },
        child: Text(status == 'none' ? AppLocalizations.of(context)!.addFriend : (status == 'pending' ? AppLocalizations.of(context)!.pending : AppLocalizations.of(context)!.friends), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(
              userId: user['id'],
              userName: user['name'] ?? '',
              userImage: user['profile_picture'] ?? '',
            ),
          ),
        );
      },
    );
  }

  Widget _buildAction(IconData icon, Color color, String count, {VoidCallback? onTap, VoidCallback? onLongPress, VoidCallback? onTextTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onTextTap,
          child: Text(
            count,
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Color _getAvatarColor(String name) {
    if (name.isEmpty) return kPrimaryBlue(context);
    final colors = [
      kPrimaryBlue(context), Colors.red, Colors.green, Colors.orange, 
      Colors.purple, Colors.teal, Colors.pink
    ];
    return colors[name.length % colors.length];
  }
}
