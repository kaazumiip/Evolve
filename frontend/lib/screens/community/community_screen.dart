import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'community_search_screen.dart';
import 'posts_tab.dart';
import 'notifications_screen.dart';
import 'chat_rooms_screen.dart';
import 'create_post_screen.dart';
import '../../services/socket_service.dart';
import '../../services/community_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import '../../generated/l10n/app_localizations.dart';

Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB);

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final GlobalKey<PostsTabState> _postsTabKey = GlobalKey<PostsTabState>();

  final CommunityService _communityService = CommunityService();
  int _unreadNotifications = 0;
  StreamSubscription? _fcmSub;

  @override
  void initState() {
    super.initState();
    _fetchBadges();
  }

  Future<void> _fetchBadges() async {
    try {
      final conversations = await _communityService.getConversations();
      final notifications = await _communityService.getNotifications();
      
      int unreadMsgs = 0;
      for (var conv in conversations) {
        if (conv['unreadCount'] != null) {
          int? parsedInt = int.tryParse(conv['unreadCount'].toString());
          if (parsedInt != null) {
             unreadMsgs += parsedInt;
          }
        }
      }
      
      int unreadNotifs = 0;
      for (var notif in notifications) {
        if (notif['is_read'] != null && (notif['is_read'] == 0 || notif['is_read'] == false)) {
          unreadNotifs++;
        }
      }

      if (mounted) {
        setState(() {
          _unreadNotifications = unreadNotifs;
        });
        // We set directly so ValueNotifier updates its listener
        SocketService().unreadCount.value = unreadMsgs;
      }

      // Realtime listener for system notifications (FCM)
      _fcmSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (mounted) {
          if (message.data['type'] != 'chat') {
             setState(() {
               _unreadNotifications++;
             });
          }
        }
      });
    } catch (e) {
      print('Error fetching badges: $e');
    }
  }

  @override
  void dispose() {
    _fcmSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: _buildGlowingFAB(),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header with Search
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.studentHub,
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildNotificationIconWithBadge(),
                          const SizedBox(width: 8),
                          _buildChatIconWithBadge(),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CommunitySearchScreen()),
                      );
                    },
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: kPrimaryBlue(context).withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kPrimaryBlue(context).withValues(alpha: 0.1), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryBlue(context).withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, color: kPrimaryBlue(context), size: 22),
                          SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)!.searchHub,
                            style: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: PostsTab(key: _postsTabKey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon({required IconData icon, required VoidCallback onPressed}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimaryBlue(context).withValues(alpha: 0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: kPrimaryBlue(context).withValues(alpha: isDark ? 0.02 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 22, color: kPrimaryBlue(context)),
        onPressed: onPressed,
        constraints: BoxConstraints(),
        padding: EdgeInsets.all(10),
      ),
    );
  }

  Widget _buildNotificationIconWithBadge() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildHeaderIcon(
          icon: Icons.notifications_none_rounded,
          onPressed: () {
            setState(() {
               _unreadNotifications = 0; // Clear locally on open
            });
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
          },
        ),
        if (_unreadNotifications > 0)
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                _unreadNotifications > 9 ? '9+' : '$_unreadNotifications',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChatIconWithBadge() {
    return ValueListenableBuilder<int>(
      valueListenable: SocketService().unreadCount,
      builder: (context, count, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            _buildHeaderIcon(
              icon: Icons.forum_outlined,
              onPressed: () {
                SocketService().resetUnreadCount();
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatRoomsScreen()));
              },
            ),
            if (count > 0)
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  double _fabScale = 1.0;

  Widget _buildGlowingFAB() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80, right: 10), 
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(seconds: 2),
        builder: (context, value, child) {
          final pulsate = (1.0 + 0.1 * (value < 0.5 ? value * 2 : (1.0 - value) * 2));
          return AnimatedScale(
            scale: _fabScale * pulsate,
            duration: const Duration(milliseconds: 100),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryBlue(context).withValues(alpha: 0.3 * (1.1 - (pulsate - 1.0) * 5)),
                    blurRadius: 20 * pulsate,
                    spreadRadius: 4 * pulsate,
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        onEnd: () => setState(() {}),
        child: FloatingActionButton(
          onPressed: () async {
            setState(() => _fabScale = 0.9);
            await Future.delayed(const Duration(milliseconds: 100));
            setState(() => _fabScale = 1.0);
            
            if (!mounted) return;
            
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (context, animation, secondaryAnimation) => CreatePostScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                        CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                      ),
                      child: child,
                    ),
                  );
                },
              ),
            ).then((result) {
              if (result == true) {
                _postsTabKey.currentState?.fetchPosts();
              }
            });
          },
          backgroundColor: kPrimaryBlue(context),
          elevation: 0,
          shape: CircleBorder(),
          child: Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
