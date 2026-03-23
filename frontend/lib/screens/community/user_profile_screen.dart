import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'post_card.dart';
import 'post_detail_screen.dart';
import 'chat_detail_screen.dart';
import 'bio_edit_screen.dart';
import 'create_post_screen.dart';
import '../tabs/profile_tab.dart';
import '../../services/community_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:google_fonts/google_fonts.dart';
import '../../../generated/l10n/app_localizations.dart';

Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB);
Color kStreakColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8B5CF6) : const Color(0xFFF97316);

class UserProfileScreen extends StatefulWidget {
  final int userId;
  final String userName;
  final String userImage;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userImage,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final CommunityService _communityService = CommunityService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = true;
  Map<String, dynamic>? _userProfile;
  int? _currentUserId;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final curIdStr = await _storage.read(key: 'user_id');
    _currentUserId = int.tryParse(curIdStr ?? '');
    await _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    final profile = await _apiService.getUserProfile(widget.userId);
    if (mounted) {
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleFriendAction() async {
    if (_userProfile == null || _isActionLoading) return;
    
    setState(() => _isActionLoading = true);
    
    final status = _userProfile!['friendshipStatus'] ?? 'none';
    bool success = false;

    if (status == 'none') {
      success = await _apiService.sendFriendRequest(widget.userId);
    } else if (status == 'pending') {
      if (_userProfile!['isRequester'] == true) {
        success = await _apiService.removeFriend(widget.userId);
      } else {
        success = await _apiService.acceptFriendRequest(widget.userId);
      }
    } else if (status == 'accepted') {
      success = await _apiService.removeFriend(widget.userId);
    }

    if (success) {
      await _fetchProfile();
    }
    
    if (mounted) {
      setState(() => _isActionLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (_currentUserId != widget.userId) return; // Only owner can change

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isLoading = true);
      await _authService.uploadProfilePicture(image.path);
      await _fetchProfile();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profilePictureUpdated)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorUploadingImage(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToBioEdit(BuildContext context, String currentBio, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BioEditScreen(
          initialBio: currentBio,
          name: name,
          onSave: _fetchProfile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isLoading && _userProfile != null && _currentUserId != widget.userId)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: titleColor),
              onSelected: (value) {
                if (value == 'block') _showBlockDialog();
                if (value == 'report') _showReportDialog();
                if (value == 'unblock') _handleUnblock();
              },
              itemBuilder: (context) {
                final isBlocked = _userProfile?['isBlocked'] == true;
                final isMeBlocker = _userProfile?['blockerId'] == _currentUserId;

                if (isBlocked && isMeBlocker) {
                  return [
                    const PopupMenuItem(value: 'unblock', child: Text('Unblock User')),
                  ];
                }

                return [
                  const PopupMenuItem(value: 'report', child: Text('Report User')),
                  const PopupMenuItem(value: 'block', child: Text('Block User', style: TextStyle(color: Colors.red))),
                ];
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
              ? Center(child: Text(AppLocalizations.of(context)!.userNotFound))
              : (_userProfile?['isBlocked'] == true && _userProfile?['blockerId'] != _currentUserId)
                  ? _buildBlockedByView()
                  : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final String name = _userProfile!['name'] ?? widget.userName;
    final String? profilePic = (_userProfile!['profile_picture'] != null && _userProfile!['profile_picture'].toString().isNotEmpty) 
        ? _userProfile!['profile_picture'] 
        : null;
    final String bio = (_userProfile!['bio'] != null && _userProfile!['bio'].toString().isNotEmpty) 
        ? _userProfile!['bio'] 
        : '';
    final int friends = _userProfile!['friendsCount'] ?? 0;
    final int streak = _userProfile!['current_streak'] ?? 0;
    final List<dynamic> interests = _userProfile!['interests'] ?? [];
    final List<dynamic> posts = _userProfile!['posts'] ?? [];
    final bool isMe = _currentUserId == widget.userId;
    final String status = _userProfile!['friendshipStatus'] ?? 'none';
    final bool isRequester = _userProfile!['isRequester'] ?? false;
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header Row: Avatar | Name+Stats
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Stack
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade200, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.grey.shade100,
                            backgroundImage: (profilePic != null)
                                ? NetworkImage(profilePic)
                                : null,
                            child: (profilePic == null)
                                ? Text(name[0].toUpperCase(), style: GoogleFonts.outfit(fontSize: 35, color: kPrimaryBlue(context), fontWeight: FontWeight.bold))
                                : null,
                          ),
                        ),
                        if (isMe)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickAndUploadImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: kPrimaryBlue(context),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 30),
                    // Name, Streak, and Stats Column
                    Expanded(
                      child: Transform.translate(
                        offset: const Offset(0, -10), // Push name slightly upper
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name & Streak Row
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: isMe ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfileTab(
                                          userData: _userProfile!,
                                          onRefresh: _fetchProfile,
                                        ),
                                      ),
                                    );
                                  } : null,
                                  child: Text(
                                    name,
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: titleColor),
                                  ),
                                ),
                                if (streak > 0) ...[
                                  const SizedBox(width: 8),
                                  Icon(Icons.local_fire_department, color: kStreakColor(context), size: 20),
                                  const SizedBox(width: 2),
                                  Text(
                                    '$streak',
                                    style: TextStyle(fontSize: 16, color: kStreakColor(context), fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 22),
                            // Stats: Posts and Friends
                            Row(
                              children: [
                                _buildStatColumn(posts.length.toString(), AppLocalizations.of(context)!.posts),
                                const SizedBox(width: 60), // Increased from 30
                                _buildStatColumn(
                                  friends.toString(), 
                                  AppLocalizations.of(context)!.friends, 
                                  onTap: () => _showFriendsList(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Bio / Add Bio Section (Push to side)
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      bio,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.outfit(
                        fontSize: 15, 
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  if (isMe) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          padding: EdgeInsets.zero, // Remove padding to bring it closer
                          minimumSize: const Size(0, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => _navigateToBioEdit(context, bio, name),
                        icon: Icon(Icons.edit_outlined, size: 16, color: kPrimaryBlue(context)),
                        label: Text(AppLocalizations.of(context)!.editBio, style: GoogleFonts.outfit(fontSize: 14, color: kPrimaryBlue(context), fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ] else if (isMe) ...[
                  const SizedBox(height: 16), // Reduced from 24
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => _navigateToBioEdit(context, bio, name),
                      icon: Icon(Icons.add_rounded, size: 18, color: kPrimaryBlue(context)),
                      label: Text(AppLocalizations.of(context)!.addBio, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: kPrimaryBlue(context))),
                    ),
                  ),
                ],

                // Interests
                if (interests.isNotEmpty) ...[
                  const SizedBox(height: 10), 
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.start,
                      children: interests.map((interest) {
                        final color = Color(int.tryParse(interest['color_hex']?.replaceFirst('#', 'FF') ?? 'FF2563EB', radix: 16) ?? 0xFF2563EB);
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '#${interest['title']}',
                              style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(width: 12),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
                if (!isMe) ...[
                  const SizedBox(height: 20),
                  // Left-Aligned Action Buttons (Below Interests)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Friend Action
                      ElevatedButton.icon(
                        onPressed: _handleFriendAction,
                        icon: Icon(_getFriendIcon(status, isRequester), size: 18),
                        label: Text(
                          _getFriendButtonText(status, isRequester, isMe),
                          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (status == 'none' || (status == 'pending' && !isRequester)) 
                              ? kPrimaryBlue(context) 
                              : const Color(0xFFF1F5F9),
                          foregroundColor: (status == 'none' || (status == 'pending' && !isRequester))
                              ? Colors.white
                              : const Color(0xFF1E293B),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                          shadowColor: kPrimaryBlue(context).withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Message Action
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final conversationId = await _communityService.startConversation(widget.userId);
                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatDetailScreen(
                                    conversationId: conversationId,
                                    otherUserId: widget.userId,
                                    otherUserName: name,
                                    otherUserImage: profilePic ?? '',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error starting chat: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                        label: Text(
                          AppLocalizations.of(context)!.message,
                          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                          foregroundColor: kPrimaryBlue(context),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0), width: 1.5),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
                if (isMe) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryBlue(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreatePostScreen()),
                        ).then((result) {
                          if (result == true) _fetchProfile();
                        });
                      },
                      icon: const Icon(Icons.add_box_outlined, size: 22),
                      label: Text(AppLocalizations.of(context)!.addPost, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
          // Posts List
          if (posts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(child: Text(AppLocalizations.of(context)!.noPostsYet, style: const TextStyle(color: Colors.grey))),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostCard(
                  id: post['id'],
                  userId: widget.userId,
                  userName: name,
                  userImage: profilePic,
                  userStreak: streak,
                  timeAgo: post['created_at'] != null 
                    ? timeago.format(DateTime.parse(post['created_at'])) 
                    : 'just now',
                  viewCount: '0 views', // Not currently tracked
                  title: post['title'] ?? 'No Title',
                  body: post['body'] ?? '',
                  imageUrl: post['image_url'] != null && post['image_url'].toString().isNotEmpty
                    ? (post['image_url'].toString().startsWith('http') 
                        ? post['image_url'] 
                        : '${ApiService.baseUrl.replaceFirst('/api', '')}/${post['image_url']}')
                    : null,
                  mediaUrls: post['media_urls'] != null ? List<String>.from(post['media_urls']) : [],
                  tags: [], // Not currently returned in this endpoint
                  likeCount: post['likesCount'] ?? 0,
                  commentCount: post['commentsCount'] ?? 0,
                  isLiked: false, // Would need checkLikes check
                  currentUserId: _currentUserId,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailScreen(postData: post),
                      ),
                    );
                  },
                  onLike: () async {
                    try {
                      await _communityService.toggleLike(post['id']);
                      _fetchProfile(); // Refresh to update like count
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                );
              },
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, {VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value, 
            style: GoogleFonts.outfit(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: isDark ? Colors.white : const Color(0xFF1E293B)
            )
          ),
          Text(
            label, 
            style: GoogleFonts.outfit(
              fontSize: 13, 
              color: isDark ? Colors.white70 : const Color(0xFF64748B)
            )
          ),
        ],
      ),
    );
  }

  void _showFriendsList(BuildContext context) async {
    try {
      // Assuming /users/friends/:userId exists or we use a filtered friend list
      final response = await _apiService.dio.get('/users/friends/${widget.userId}');
      final List<dynamic> friendsList = response.data;
      if (context.mounted) {
        _showUserListSheet(context, "Friends", friendsList);
      }
    } catch (e) {
      print('Error fetching friends: $e');
    }
  }

  void _showUserListSheet(BuildContext context, String title, List<dynamic> users) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 5,
              decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.grey.shade300, borderRadius: BorderRadius.circular(5)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            ),
            Divider(color: isDark ? Colors.white10 : Colors.grey.shade200),
            Expanded(
              child: users.isEmpty 
                ? Center(child: Text(AppLocalizations.of(context)!.noUsersFound, style: GoogleFonts.outfit(color: isDark ? Colors.white70 : Colors.black54)))
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
    return StatefulBuilder(
      builder: (context, setTileState) {
        final status = user['friendshipStatus'] ?? 'none';
        final isRequester = user['requesterId'] == _currentUserId;
        final isMe = _currentUserId == user['id'];

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: (user['profile_picture'] != null && user['profile_picture'].isNotEmpty) 
                ? NetworkImage(user['profile_picture']) 
                : null,
            child: (user['profile_picture'] == null || user['profile_picture'].isEmpty)
                ? Text(user['name']?[0].toUpperCase() ?? '?')
                : null,
          ),
          title: Text(user['name'] ?? 'Unknown', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)),
          trailing: isMe ? null : ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'none' ? kPrimaryBlue(context) : (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade100),
              foregroundColor: status == 'none' ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              if (status == 'none') {
                try {
                  await _communityService.sendFriendRequest(user['id']);
                  setTileState(() {
                    user['friendshipStatus'] = 'pending';
                    user['requesterId'] = _currentUserId;
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.friendRequestSentExclamation)));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.failedToSendRequestWithError(e.toString()))));
                  }
                }
              }
            },
            child: Text(
              status == 'none' ? AppLocalizations.of(context)!.addFriend : (status == 'pending' ? (isRequester ? AppLocalizations.of(context)!.pending : AppLocalizations.of(context)!.accept) : AppLocalizations.of(context)!.friends), 
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)
            ),
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
    );
  }

  String _getFriendButtonText(String status, bool isRequester, bool isMe) {
    if (isMe) return AppLocalizations.of(context)!.friends;
    if (status == 'pending') return isRequester ? AppLocalizations.of(context)!.requested : AppLocalizations.of(context)!.acceptRequest;
    if (status == 'accepted') return AppLocalizations.of(context)!.unfriend;
    return AppLocalizations.of(context)!.addFriend;
  }

  IconData _getFriendIcon(String status, bool isRequester) {
    if (status == 'pending') return isRequester ? Icons.hourglass_top_rounded : Icons.person_add_alt_1_rounded;
    if (status == 'accepted') return Icons.person_remove_rounded;
    return Icons.person_add_rounded;
  }

  Widget _buildActionIcon({required IconData icon, required VoidCallback onTap, bool isPrimary = false, String? tooltip}) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isPrimary ? Colors.blue.shade600 : Colors.grey.shade100,
            shape: BoxShape.circle,
            boxShadow: [
              if (isPrimary)
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Icon(
            icon,
            color: isPrimary ? Colors.white : Colors.black87,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _handleUnblock() async {
    final success = await _apiService.unblockUser(widget.userId);
    if (success) _fetchProfile();
  }

  void _showReportDialog() {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report User'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: 'Reason for reporting...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _apiService.reportUser(widget.userId, reasonController.text);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User reported successfully')));
              }
            }, 
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User?'),
        content: const Text('Blocking will remove friendship and they will no longer see your content.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _apiService.blockUser(widget.userId);
              if (success) _fetchProfile();
            }, 
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedByView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block_flipped, size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 20),
          Text(
            "This user has blocked you",
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 10),
          Text(
            "You cannot see their posts or interact with them.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
