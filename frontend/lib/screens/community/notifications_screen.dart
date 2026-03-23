import 'package:flutter/material.dart';
import '../../services/community_service.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'post_detail_screen.dart';
import '../../services/api_service.dart';
import 'user_profile_screen.dart';

Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB);

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final CommunityService _communityService = CommunityService();
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _refreshNotifications();
  }

  void _refreshNotifications() {
    setState(() {
      _notificationsFuture = _communityService.getNotifications();
    });
  }

  Future<void> _markAllAsRead() async {
    await _communityService.markAllNotificationsRead();
    _refreshNotifications();
  }

  Future<void> _handleNotificationTap(Map<String, dynamic> notification) async {
    // Mark as read specifically 
    if (notification['is_read'] == 0 || notification['is_read'] == false) {
      await _communityService.markNotificationRead(notification['id']);
      _refreshNotifications();
    }

    // Navigate based on type
    if (mounted) {
      final String type = notification['type'] ?? '';
      
      if ((type == 'friend_request' || type == 'friend_accepted' || type == 'friend_mutual') && notification['sender_id'] != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(
              userId: notification['sender_id'],
              userName: notification['senderName'] ?? 'User',
              userImage: notification['senderImage'] ?? '',
            ),
          ),
        );
      } else if (notification['post_id'] != null) {
        final postDetails = await _communityService.getPostDetails(notification['post_id']);
        if (!mounted) return;
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(
              postData: postDetails['post'],
            ),
          ),
        );
      }
    }
  }

  String _getNotificationMessage(Map<String, dynamic> notification) {
    String senderName = notification['senderName'] ?? 'Someone';
    switch (notification['type']) {
      case 'like_post':
        return AppLocalizations.of(context)!.likedYourPost(senderName);
      case 'comment':
        return AppLocalizations.of(context)!.commentedOnYourPost(senderName);
      case 'like_comment':
        return AppLocalizations.of(context)!.likedYourComment(senderName);
      case 'reply':
        return AppLocalizations.of(context)!.repliedToYourComment(senderName);
      case 'friend_request':
        return AppLocalizations.of(context)!.sentYouAFriendRequestTapToRespond(senderName);
      case 'friend_accepted':
        return AppLocalizations.of(context)!.acceptedYourFriendRequestYouAreNowFriends(senderName);
      case 'friend_mutual':
        return AppLocalizations.of(context)!.youAndNameAreNowFriends(senderName);
      case 'interact':
        return AppLocalizations.of(context)!.interactedWithYourProfile(senderName);
      default:
        return AppLocalizations.of(context)!.sentYouANotification(senderName);
    }
  }

  IconData _getNotificationIcon(Map<String, dynamic> notification) {
    switch (notification['type']) {
      case 'like_post':
      case 'like_comment':
        return Icons.favorite;
      case 'comment':
      case 'reply':
        return Icons.comment;
      case 'friend_request':
        return Icons.person_add_rounded;
      case 'friend_accepted':
      case 'friend_mutual':
        return Icons.person_add_alt_1_rounded;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(Map<String, dynamic> notification) {
    switch (notification['type']) {
      case 'like_post':
      case 'like_comment':
        return Colors.redAccent;
      case 'comment':
      case 'reply':
        return kPrimaryBlue(context);
      case 'friend_accepted':
      case 'friend_mutual':
        return Colors.green;
      default:
        return Colors.grey;
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
        leadingWidth: 50,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.notifications,
          style: GoogleFonts.outfit(
            color: titleColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check_rounded, color: titleColor, size: 24),
            tooltip: AppLocalizations.of(context)!.markAllAsRead,
            onPressed: _markAllAsRead,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryBlue(context))));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!;
          final requests = notifications.where((n) => n['type'] == 'friend_request').toList();
          final others = notifications.where((n) => n['type'] != 'friend_request').toList();

          final List<dynamic> listItems = [];
          if (requests.isNotEmpty) {
            listItems.add({'isHeader': true, 'title': 'Friend Requests'});
            listItems.addAll(requests);
          }
          if (others.isNotEmpty) {
            listItems.add({'isHeader': true, 'title': requests.isNotEmpty ? 'Other Notifications' : 'Notifications'});
            listItems.addAll(others);
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refreshNotifications();
            },
            child: ListView.separated(
              itemCount: listItems.length,
              separatorBuilder: (context, index) => const SizedBox.shrink(),
              itemBuilder: (context, index) {
                final item = listItems[index];
                if (item is Map<String, dynamic> && item['isHeader'] == true) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text(item['title'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: titleColor)),
                    );
                }

                final notification = listItems[index] as Map<String, dynamic>;
                final isRead = notification['is_read'] == 1 || notification['is_read'] == true;
                final senderImage = notification['senderImage'];
                final createdDate = DateTime.parse(notification['created_at']).toLocal();

                return InkWell(
                  onTap: () => _handleNotificationTap(notification),
                  child: Container(
                    color: isDark 
                        ? (isRead ? Colors.transparent : Colors.white.withOpacity(0.05))
                        : (isRead ? (isDark ? Colors.white.withOpacity(0.05) : Colors.white) : kPrimaryBlue(context).withOpacity(0.04)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar + Type Icon Overlay
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: senderImage != null && senderImage.isNotEmpty ? NetworkImage(senderImage) : null,
                              backgroundColor: Colors.grey.shade200,
                              child: (senderImage == null || senderImage.isEmpty)
                                  ? const Icon(Icons.person, color: Colors.grey)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: _getNotificationColor(notification),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: isDark ? const Color(0xFF0F172A) : Colors.white, width: 2),
                                ),
                                child: Icon(
                                  _getNotificationIcon(notification),
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        
                        // Main text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(
                                  _getNotificationMessage(notification),
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                    color: titleColor,
                                  ),
                                ),
                              const SizedBox(height: 6),
                              Text(
                                timeago.format(createdDate),
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: isRead ? Colors.grey.shade500 : kPrimaryBlue(context),
                                  fontWeight: isRead ? FontWeight.normal : FontWeight.w500,
                                ),
                              ),
                              if (notification['type'] == 'friend_request') ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        final success = await ApiService().acceptFriendRequest(notification['sender_id']);
                                        if (success && mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Friend request accepted!')),
                                          );
                                          await _communityService.markNotificationRead(notification['id']);
                                          _refreshNotifications();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryBlue(context),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                        minimumSize: const Size(80, 32),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        elevation: 0,
                                      ),
                                      child: Text('Accept', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      onPressed: () async {
                                        try {
                                          await _communityService.removeFriend(notification['sender_id']);
                                          await _communityService.markNotificationRead(notification['id']); // optionally mark read
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Friend request rejected')));
                                            _refreshNotifications();
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                          }
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                        minimumSize: const Size(80, 32),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                                      ),
                                      child: Text('Reject', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700)),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        // Unread dot indicator
                        if (!isRead)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: kPrimaryBlue(context),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
