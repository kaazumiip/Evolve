import 'package:flutter/material.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/community_service.dart';
import 'post_card.dart';
import 'user_profile_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:share_plus/share_plus.dart';
import '../../widgets/comment_media_picker.dart';
import '../../services/auth_service.dart';


Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB);
Color kStreakColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8B5CF6) : const Color(0xFFF97316);

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> postData;

  const PostDetailScreen({super.key, required this.postData});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final CommunityService _communityService = CommunityService();
  final TextEditingController _commentController = TextEditingController();
  late Future<Map<String, dynamic>> _postDetailsFuture;
  bool _isSendingComment = false;
  int? _replyingToCommentId;
  String? _replyingToUserName;
  int? _currentUserId;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
    _refreshPostDetails();
  }

  Future<void> _fetchCurrentUserId() async {
    try {
      final user = await _authService.getUser();
      if (mounted) setState(() => _currentUserId = user['id']);
    } catch (_) {}
  }


  void _refreshPostDetails() {
    setState(() {
      _postDetailsFuture = _communityService.getPostDetails(widget.postData['id']);
    });
  }

  Future<void> _sendComment({String? type, String? mediaUrl, String? content}) async {
    final commentText = content ?? _commentController.text.trim();
    if (commentText.isEmpty && mediaUrl == null) return;

    setState(() {
      _isSendingComment = true;
    });

    try {
      await _communityService.addComment(
        widget.postData['id'], 
        commentText,
        parentId: _replyingToCommentId,
        type: type,
        mediaUrl: mediaUrl,
      );
      _commentController.clear();
      _cancelReply();
      _refreshPostDetails(); // Refresh to show new comment
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorAddingComment(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingComment = false;
        });
      }
    }
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CommentMediaPicker(
        onSelected: ({required type, content, mediaUrl}) {
          Navigator.pop(context);
          
          String dbType = type;
          if (type == 'gifs' || type == 'gif') dbType = 'gif';
          if (type == 'stickers' || type == 'sticker') dbType = 'sticker';
          
          _sendComment(type: dbType, content: content, mediaUrl: mediaUrl);
        },
      ),
    );
  }

  void _startReply(int commentId, String userName) {
    setState(() {
      _replyingToCommentId = commentId;
      _replyingToUserName = userName;
    });
    // Focus the text field
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUserName = null;
    });
  }

  Future<void> _toggleLike() async {
    // Optimistic toggle not strictly necessary for detail view but good for UX
    // Just call API and refresh
    try {
      await _communityService.toggleLike(widget.postData['id']);
      _refreshPostDetails(); // Refresh full details including like count/status
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToLikePost)),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,

      appBar: AppBar(
        leadingWidth: 70,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalizations.of(context)!.postHub, 
          style: GoogleFonts.outfit(color: titleColor, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: kPrimaryBlue(context),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryBlue(context).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
                onPressed: () {
                  final String postId = widget.postData['id']?.toString() ?? '';
                  final String postTitle = widget.postData['title'] ?? 'Evolve Post';
                  final String postUrl = 'https://evolve-app.com/posts/$postId';
                  Share.share('Check out this post on Evolve: $postTitle\n\n$postUrl');
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _postDetailsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryBlue(context))));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return Center(child: Text(AppLocalizations.of(context)!.postNotFound));
                  }

                  final post = snapshot.data!['post'];
                  final comments = List<Map<String, dynamic>>.from(snapshot.data!['comments']);

                  // Calculate time
                  String timeDisplay;
                  try {
                    final date = DateTime.parse(post['created_at']);
                    timeDisplay = timeago.format(date);
                  } catch (e) {
                    timeDisplay = 'Just now';
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        // Original Post
                        PostCard(
                          id: post['id'],
                          userId: post['user_id'] ?? 0,
                          userName: post['userName'] ?? 'Unknown',
                          userImage: post['userImage'],
                          userStreak: post['current_streak'] ?? 0,
                          timeAgo: timeDisplay, 
                          viewCount: '${post['view_count'] ?? 0}',
                          isVerified: post['isVerified'] == 1 || post['isVerified'] == true,
                          title: post['title'] ?? '',
                          body: post['body'] ?? '',
                          imageUrl: post['image_url'],
                          mediaUrls: post['media_urls'] != null ? List<String>.from(post['media_urls']) : [],
                          tags: post['tags'] != null ? List<String>.from(post['tags']) : [],
                          likeCount: post['likeCount'] ?? 0,
                          commentCount: post['commentCount'] ?? 0,
                          isLiked: post['isLiked'] == 1 || post['isLiked'] == true,
                          currentUserId: _currentUserId,
                          onLike: _toggleLike,
                          onTap: () {}, // Already detailed view, no action
                          onEdit: _refreshPostDetails, // Refresh after edit
                          onDelete: () => Navigator.pop(context), // Go back after delete
                        ),
                        
                        // Comments Section header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          child: Row(
                            children: [
                              Container(
                                width: 3,
                                height: 16,
                                decoration: BoxDecoration(color: kPrimaryBlue(context), borderRadius: BorderRadius.circular(2)),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.commentsWithCount(comments.length.toString()),
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: titleColor),
                              ),
                            ],
                          ),
                        ),

                        // Comments List
                        if (comments.isNotEmpty)
                          _buildCommentsList(comments),
                          
                        const SizedBox(height: 80),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Optional Reply Banner
            if (_replyingToCommentId != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: kPrimaryBlue(context).withOpacity(0.05),
                  border: Border(top: BorderSide(color: kPrimaryBlue(context).withOpacity(0.1))),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: kPrimaryBlue(context).withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.reply_rounded, size: 14, color: kPrimaryBlue(context)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.outfit(fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                          children: [
                            TextSpan(text: AppLocalizations.of(context)!.replyingTo),
                            TextSpan(text: '$_replyingToUserName', style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryBlue(context))),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            
            // Comment Input
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _showMediaPicker,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kPrimaryBlue(context).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.add_reaction_rounded, color: kPrimaryBlue(context), size: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        enabled: !_isSendingComment,
                        style: GoogleFonts.outfit(fontSize: 14, color: titleColor),
                        decoration: InputDecoration(
                          hintText: _replyingToCommentId != null ? AppLocalizations.of(context)!.addAReply : AppLocalizations.of(context)!.writeAComment,
                          hintStyle: GoogleFonts.outfit(color: const Color(0xFF94A3B8)),
                          fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFC),
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: kPrimaryBlue(context), width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _isSendingComment ? null : _sendComment,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _isSendingComment ? Colors.grey : kPrimaryBlue(context),
                          shape: BoxShape.circle,
                        ),
                        child: _isSendingComment 
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }




  Widget _buildCommentsList(List<Map<String, dynamic>> comments) {
    // Group comments
    final topLevel = comments.where((c) => c['parent_id'] == null).toList();
    final nested = comments.where((c) => c['parent_id'] != null).toList();

    return Column(
      children: topLevel.map((parent) {
        final children = nested.where((c) => c['parent_id'] == parent['id']).toList();
        return Column(
          children: [
            _buildCommentWidget(parent, isReply: false),
            if (children.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 40.0), // Indent replies
                child: Column(
                  children: children.map((child) => _buildCommentWidget(child, isReply: true)).toList(),
                ),
              ),
            const Divider(height: 1, thickness: 1, color: Colors.transparent),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCommentWidget(Map<String, dynamic> comment, {bool isReply = false}) {
    final userId = comment['user_id'] ?? 0;
    final user = comment['userName'] ?? 'Unknown';
    final userImage = comment['userImage'];
    final streak = comment['current_streak'] ?? 0;
    final content = comment['content'] ?? '';
    final type = comment['type'] ?? 'text';
    final mediaUrl = comment['media_url'];

    final time = comment['created_at'] != null 
      ? timeago.format(DateTime.parse(comment['created_at'])) 
      : 'Just now';
    
    final likeCount = comment['likeCount'] ?? 0;
    final isLiked = comment['isLiked'] == 1 || comment['isLiked'] == true;
    final commentId = comment['id'];

    return Container(
      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0F172A) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfileScreen(
                  userId: userId,
                  userName: user,
                  userImage: userImage ?? '',
                ),
              ),
            ),
            child: CircleAvatar(
              radius: isReply ? 12 : 16,
              backgroundColor: kPrimaryBlue(context).withOpacity(0.1),
              backgroundImage: (userImage != null && userImage.isNotEmpty) 
                ? NetworkImage(userImage) 
                : null,
              child: (userImage == null || userImage.isEmpty)
                ? Text(user.isNotEmpty ? user[0].toUpperCase() : '?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: isReply ? 12 : 14, color: kPrimaryBlue(context)))
                : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserProfileScreen(
                                userId: userId,
                                userName: user,
                                userImage: userImage ?? '',
                              ),
                            ),
                          ),
                          child: Text(user, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B))),
                        ),
                        if (streak > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: kStreakColor(context).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.local_fire_department, size: 12, color: kStreakColor(context)),
                                const SizedBox(width: 2),
                                Text(
                                  '$streak',
                                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: kStreakColor(context)),
                                ),

                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(time, style: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 4),
                if (type == 'text')
                  Text(content, style: GoogleFonts.outfit(fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(0xFF334155), height: 1.4))
                else if (type == 'emoticon')
                  Text(content, style: GoogleFonts.outfit(fontSize: 28))
                else if (mediaUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        mediaUrl,
                        height: 120,
                        width: 120,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        try {
                          await _communityService.toggleCommentLike(commentId);
                          _refreshPostDetails(); // Refresh to update like count & status
                        } catch (e) {
                          // Ignore failure silently for UI speed
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border, 
                            size: 16, 
                            color: isLiked ? Colors.red : Colors.grey.shade500
                          ),
                          if (likeCount > 0) ...[
                            const SizedBox(width: 4),
                            Text('$likeCount', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        // If it's already a reply inside a thread, root the reply to the main parent comment thread so it groups naturally
                        final targetParentId = comment['parent_id'] ?? commentId;
                        _startReply(targetParentId, user);
                      },
                      child: Text(AppLocalizations.of(context)!.reply, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(0xFF64748B))),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_currentUserId == userId)
            IconButton(
              icon: const Icon(Icons.more_horiz, size: 20, color: Color(0xFF94A3B8)),
              onPressed: () => _showCommentOptions(comment),
            ),
        ],
      ),
    );
  }

  void _showCommentOptions(Map<String, dynamic> comment) {
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
                if (comment['type'] == 'text')
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: kPrimaryBlue(context).withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.edit_rounded, color: kPrimaryBlue(context), size: 20),
                    ),
                    title: Text(AppLocalizations.of(context)!.editComment, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Text('Edit your thoughts', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                    onTap: () {
                      Navigator.pop(context);
                      _showEditCommentDialog(comment);
                    },
                  ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                  ),
                  title: Text(AppLocalizations.of(context)!.deleteComment, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)),
                  subtitle: Text('Remove this comment', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteCommentDialog(comment['id']);
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

  void _showEditCommentDialog(Map<String, dynamic> comment) {
    final controller = TextEditingController(text: comment['content']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context)!.editComment, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          maxLines: null,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.editYourComment,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel, style: GoogleFonts.outfit(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryBlue(context),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              try {
                await _communityService.updateComment(comment['id'], controller.text.trim());
                Navigator.pop(context);
                _refreshPostDetails();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: Text(AppLocalizations.of(context)!.save, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteCommentDialog(int commentId) {
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
                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 32),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.deleteComment,
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.areYouSureYouWantToDeleteThisComment,
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
                            await _communityService.deleteComment(commentId);
                            if (context.mounted) Navigator.pop(context);
                            _refreshPostDetails();
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.commentDeletedSuccessfully)));
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

}
