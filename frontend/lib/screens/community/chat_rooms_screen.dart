import 'package:flutter/material.dart';
import '../../services/community_service.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../services/socket_service.dart';
import '../../services/api_service.dart';
import 'chat_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB);

class ChatRoomsScreen extends StatefulWidget {
  const ChatRoomsScreen({super.key});

  @override
  State<ChatRoomsScreen> createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CommunityService _communityService = CommunityService();
  final ApiService _apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _conversationsFuture;
  final SocketService _socketService = SocketService();
  final Map<int, bool> _onlineUsers = {};

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearchingUsers = false;
  bool _showArchived = false;
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _refreshConversations();
    _searchController.addListener(_onSearchChanged);
    _initSocketListeners();
  }

  void _initSocketListeners() {
    _subscriptions.add(_socketService.userStatus.listen((data) {
      if (mounted) {
        setState(() {
          _onlineUsers[data['userId']] = data['status'] == 'online';
        });
      }
    }));

    _subscriptions.add(_socketService.messages.listen((data) {
      if (mounted) _refreshConversations();
    }));

    _subscriptions.add(_socketService.messageSeens.listen((data) {
      if (mounted) _refreshConversations();
    }));
  }

  void _refreshConversations() {
    setState(() {
      _conversationsFuture = _communityService.getConversations();
    });
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearchingUsers = false;
      });
    } else {
      _performSearch(_searchController.text);
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearchingUsers = true;
    });
    try {
      final results = await _communityService.searchUsers(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearchingUsers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearchingUsers = false;
        });
      }
    }
  }

  Future<void> _startConversation(Map<String, dynamic> user) async {
    try {
      final conversationId = await _communityService.startConversation(user['id']);
      if (mounted) {
        // Navigate to chat
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              conversationId: conversationId,
              otherUserId: user['id'],
              otherUserName: user['name'],
              otherUserImage: user['userImage'] ?? '',
            ),
          ),
        ).then((_) {
          _searchController.clear(); // Clear search on return
          _refreshConversations();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToStartConversation)),
        );
      }
    }
  }

  @override
  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
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
        leadingWidth: 70,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _showArchived ? "Archived Chats" : AppLocalizations.of(context)!.messages,
          style: GoogleFonts.outfit(
            color: titleColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_showArchived ? Icons.chat_rounded : Icons.archive_outlined, color: kPrimaryBlue(context)),
            onPressed: () => setState(() => _showArchived = !_showArchived),
            tooltip: _showArchived ? "Back to Chats" : "Archived Chats",
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Theme.of(context).dividerColor.withOpacity(0.1), height: 1),
        ),
      ),
      body: Column(
        children: [
          // Modern Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Container(
              decoration: BoxDecoration(
                color: kPrimaryBlue(context).withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kPrimaryBlue(context).withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryBlue(context).withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.outfit(fontSize: 15),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchPeople,
                  hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search_rounded, color: kPrimaryBlue(context).withOpacity(0.6), size: 22),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Colors.grey, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                ),
              ),
            ),
          ),

        // Content
        Expanded(
          child: _searchController.text.isNotEmpty
              ? _buildSearchResults()
              : _buildConversationList(),
        ),
      ],
    ),
   );
  }

  Widget _buildSearchResults() {
    if (_isSearchingUsers) {
      return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryBlue(context))));
    }

    if (_searchResults.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noUsersFound));
    }

    return Container(
      color: Colors.transparent,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final user = _searchResults[index];
          final name = user['name'] ?? 'Unknown';
          final imageUrl = user['userImage'];

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              backgroundColor: Colors.blueGrey,
              child: imageUrl == null
                  ? Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(color: Colors.white))
                  : null,
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Icon(Icons.message, color: kPrimaryBlue(context)),
            onTap: () => _startConversation(user),
          );
        },
      ),
    );
  }

  Widget _buildConversationList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _conversationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryBlue(context))));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final allChats = snapshot.data ?? [];
        final chats = allChats.where((c) {
          final isArchived = c['status'] == 'archived' && c['archived_by'] == _socketService.currentUserId;
          return _showArchived ? isArchived : !isArchived;
        }).toList();

        if (chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_showArchived ? Icons.archive_outlined : Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(_showArchived ? "No archived requests" : AppLocalizations.of(context)!.noConversationsYet, style: GoogleFonts.outfit(color: Colors.grey)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _refreshConversations();
          },
          child: Container(
            color: Colors.transparent,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                final name = chat['otherUserName'] ?? 'Unknown';
                final message = chat['lastMessage'] ?? AppLocalizations.of(context)!.startAConversation;
                final time = chat['lastMessageTime'] != null
                    ? _formatTime(chat['lastMessageTime'])
                    : '';
                final unreadCount = chat['unreadCount'] ?? 0;
                final imageUrl = chat['otherUserImage'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      if (chat['status'] == 'archived' && chat['archived_by'] == _socketService.currentUserId) {
                        _showStrangerActionDialog(chat);
                        return;
                      }
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            conversationId: chat['id'],
                            otherUserId: chat['otherUserId'],
                            otherUserName: name,
                            otherUserImage: imageUrl ?? '',
                            otherUserLastSeen: chat['otherUserLastSeen'],
                          ),
                        ),
                      );
                      _refreshConversations();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: kPrimaryBlue(context).withOpacity(0.1), width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundImage: imageUrl != null && imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                                  backgroundColor: kPrimaryBlue(context).withOpacity(0.1),
                                  child: (imageUrl == null || imageUrl.isEmpty)
                                      ? Text(name.isNotEmpty ? name[0] : '?', 
                                          style: GoogleFonts.outfit(color: kPrimaryBlue(context), fontWeight: FontWeight.bold, fontSize: 20))
                                      : null,
                                ),
                              ),
                              if (_isUserOnline(chat))
                                Positioned(
                                  right: 4,
                                  bottom: 4,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981), // Emerald green
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      name,
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Theme.of(context).textTheme.titleLarge?.color,
                                      ),
                                    ),
                                    Text(
                                      time,
                                      style: GoogleFonts.outfit(
                                        color: Colors.grey.shade400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _getMessagePreview(chat['lastMessageType'], message),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.outfit(
                                          color: unreadCount > 0 ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87) : Colors.grey.shade500,
                                          fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    if (unreadCount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [kPrimaryBlue(context), kPrimaryBlue(context).withOpacity(0.7)],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '$unreadCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showStrangerActionDialog(Map<String, dynamic> chat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Message Request", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("${chat['otherUserName']} wants to message you. If you accept, you can chat with each other.", textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.grey)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _apiService.handleStrangerChat(chat['id'], 'reject');
                      _refreshConversations();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                    ),
                    child: const Text("Reject", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _apiService.handleStrangerChat(chat['id'], 'accept');
                      _refreshConversations();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: kPrimaryBlue(context),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Accept", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getMessagePreview(String? type, String content) {
    if (type == null || type == 'text') return content;
    switch (type) {
      case 'image': return '📸 ${AppLocalizations.of(context)!.photo}';
      case 'video': return '📹 ${AppLocalizations.of(context)!.video}';
      case 'voice': return '🎤 ${AppLocalizations.of(context)!.voiceMessage}';
      case 'gif': return AppLocalizations.of(context)!.gif;
      case 'sticker': return AppLocalizations.of(context)!.sticker;
      default: return content;
    }
  }

  String _formatTime(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (date.year == now.year) {
        return '${date.day}/${date.month}';
      }
      return '${date.day}/${date.month}/${date.year.toString().substring(2)}';
    } catch (e) {
      return '';
    }
  }

  bool _isUserOnline(Map<String, dynamic> chat) {
    // Check real-time map first
    final userId = chat['otherUserId'];
    if (userId != null && _onlineUsers.containsKey(userId)) {
      return _onlineUsers[userId]!;
    }
    
    // Fallback to static lastSeen if it's very recent (e.g. within 1 minute)
    final lastSeenStr = chat['otherUserLastSeen'];
    if (lastSeenStr != null) {
      try {
        final lastSeen = DateTime.parse(lastSeenStr).toLocal();
        return DateTime.now().difference(lastSeen).inMinutes < 1;
      } catch (e) {
        return false;
      }
    }
    
    return false;
  }
}
