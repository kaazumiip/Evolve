import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'tabs/home_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/favorites_tab.dart';
import 'community/community_screen.dart';
// import 'dart:convert';
import '../services/socket_service.dart';
import '../services/api_service.dart';
import '../services/community_service.dart';
import 'community/chat_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/push_notification_service.dart';
import 'insight_tab.dart';
import '../generated/l10n/app_localizations.dart';


Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;
  late PageController _pageController;
  
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;
  final SocketService _socketService = SocketService();
  final ApiService _apiService = ApiService();
  final CommunityService _communityService = CommunityService();

  // Define widths for each nav item to make the indicator dynamic
  final List<double> _navWidths = [0.18, 0.28, 0.20, 0.22, 0.20]; // Percentages of total width
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _fcmSubscription;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _loadUserData().then((_) => _initGlobalSocket());
  }

  Future<void> _initGlobalSocket() async {
    final token = await _apiService.getToken();
    if (token != null && _userData['id'] != null) {
      _socketService.connect(ApiService.baseUrl.replaceFirst('/api', ''), token, _userData['id']);
      
      // Join all conversation rooms to receive notifications and compile login unread popup
      final conversations = await _communityService.getConversations();
      int unreadMsgs = 0;
      for (var conv in conversations) {
        _socketService.joinConversation(conv['id']);
        if (conv['unreadCount'] != null) {
          int? parsedInt = int.tryParse(conv['unreadCount'].toString());
          if (parsedInt != null) {
             unreadMsgs += parsedInt;
          }
        }
      }

      final notifications = await _communityService.getNotifications();
      int unreadNotifs = 0;
      for (var notif in notifications) {
        if (notif['is_read'] != null && (notif['is_read'] == 0 || notif['is_read'] == false)) {
          unreadNotifs++;
        }
      }

      if (unreadMsgs > 0 || unreadNotifs > 0) {
        if (unreadMsgs > 0) {
          final unreadConvs = conversations.where((c) {
            final count = int.tryParse(c['unreadCount']?.toString() ?? '0') ?? 0;
            return count > 0;
          }).toList();

          // Loop through every conversation that has unread messages
          for (var conv in unreadConvs) {
            final int convId = conv['id'];
            final allMsgs = await _communityService.getMessages(convId);
            final currentUserId = _userData['id'];
            
            final unreadList = allMsgs.where((m) => 
              (m['is_read'] == 0 || m['is_read'] == false) && 
              m['sender_id'] != currentUserId
            ).toList();
            
            final displayMsgs = unreadList.length > 7 
                ? unreadList.sublist(unreadList.length - 7) 
                : unreadList;

            String lastMsgBody = displayMsgs.isNotEmpty 
                ? (displayMsgs.last['content'] ?? 'Sent a message') 
                : (conv['lastMessage'] ?? 'Sent a message');

            PushNotificationService.showLocalNotification(
              id: convId, // UNIQUE ID per conversation so they don't overwrite
              title: '${conv['otherUserName']}',
              body: lastMsgBody,
              imageUrl: conv['otherUserImage'],
              previousMessages: displayMsgs.map((m) => m['content']?.toString() ?? 'Media').toList(),
              payload: '{"type": "chat", "conversationId": $convId}',
            );
          }
        }

        if (unreadNotifs > 0) {
          final notifications = await _communityService.getNotifications();
          final unreadItems = notifications.where((n) => n['is_read'] == 0 || n['is_read'] == false).toList();
          
          // Loop through every individual social notification
          for (var notif in unreadItems) {
            String sender = notif['senderName'] ?? 'Someone';
            String body = 'interacted with you';
            if (notif['type'] == 'friend_request') body = 'sent you a friend request';
            if (notif['type'] == 'friend_accepted') body = 'accepted your friend request';
            if (notif['type'] == 'friend_mutual') body = 'And you are now friends';
            if (notif['type'] == 'like_post') body = 'liked your post';
            if (notif['type'] == 'comment') body = 'commented on your post';
            if (notif['type'] == 'reply') body = 'replied to your comment';

            PushNotificationService.showLocalNotification(
              id: notif['id'].hashCode, // UNIQUE ID per social event
              title: sender,
              body: body,
              imageUrl: notif['senderImage'],
              payload: '{"type": "notification", "itemId": ${notif['id']}}',
            );
          }
        }
      }

      // Listen for socket notifications (messages) to merely rebuild badge via unread++
      _notificationSubscription = _socketService.notifications.listen((msg) {
        // Native notifications handle popup overlay inherently
        // Socket listener purely kept for data binding / reactive updates if needed
      });
      
      // Native push notifications handle Android UI popup implicitly.
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _notificationSubscription?.cancel();
    _fcmSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authService.getUser();
      if (mounted) {
        setState(() {
          _userData = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _userData = {'name': 'User', 'interests': [1]}; // Fallback
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          
          SafeArea(
            bottom: false,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe between pages
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: [
                HomeTab(userData: _userData),
                const CommunityScreen(),
                InsightTab(userData: _userData),
                const FavoritesTab(),
                ProfileTab(
                  userData: _userData,
                  onRefresh: _loadUserData,
                ),
              ],
            ),
          ),
          
          // Floating Bottom Navigation
          Positioned(
            left: 20,
            right: 20,
            bottom: 60, 
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double totalWidth = constraints.maxWidth;
                    double itemWidth = totalWidth / 5;
                    
                    // Calculate dynamic indicator width and position
                    double indicatorWidth = totalWidth * _navWidths[_selectedIndex];
                    double leftOffset = 0;
                    for (int i = 0; i < _selectedIndex; i++) {
                      leftOffset += itemWidth;
                    }
                    // Center the indicator within the item space
                    leftOffset += (itemWidth - indicatorWidth) / 2;

                    return Stack(
                      children: [
                        // Sliding Dynamic Indicator
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOutQuart,
                          left: leftOffset,
                          top: 8,
                          bottom: 8,
                          width: indicatorWidth,
                          child: Container(
                            decoration: BoxDecoration(
                              color: kPrimaryBlue(context),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: kPrimaryBlue(context).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Nav Items
                        Row(
                          children: List.generate(5, (index) {
                            IconData icon;
                            String label;
                            switch (index) {
                              case 0: icon = Icons.home_rounded; label = AppLocalizations.of(context)!.home; break;
                              case 1: icon = Icons.groups_rounded; label = AppLocalizations.of(context)!.community; break;
                              case 2: icon = Icons.lightbulb_outline_rounded; label = AppLocalizations.of(context)!.insight; break;
                              case 3: icon = Icons.star_outline_rounded; label = AppLocalizations.of(context)!.favorites; break;
                              case 4: default: icon = Icons.settings_outlined; label = AppLocalizations.of(context)!.profile; break;
                            }
                            return _buildNavItem(index, icon, label, itemWidth);
                          }),
                        ),
                      ],
                    );
                  }
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, double width) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      },
      child: Container(
        width: width,
        color: Colors.transparent, // Ensures the whole area is clickable
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutQuart,
          padding: EdgeInsets.only(bottom: isSelected ? 6 : 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with lift animation
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutQuart,
                    transform: Matrix4.translationValues(0, isSelected ? -2 : 0, 0),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : Colors.grey.shade400,
                      size: isSelected ? 26 : 24, 
                    ),
                  ),
                  if (index == 1) // Chat index
                    ValueListenableBuilder<int>(
                      valueListenable: _socketService.unreadCount,
                      builder: (context, count, _) {
                        if (count <= 0) return const SizedBox.shrink();
                        return Positioned(
                          top: -5,
                          right: -5,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
              if (isSelected) ...[
                const SizedBox(height: 4), // Added spacing for better alignment
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: 1.0,
                  child: Text(
                    label,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


