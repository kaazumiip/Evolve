import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'user_profile_screen.dart';
import '../../services/auth_service.dart';
import 'dart:io';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import '../../services/community_service.dart';
import '../../services/socket_service.dart';
import '../../services/api_service.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:giphy_get/giphy_get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:timeago/timeago.dart' as timeago;
import 'package:google_fonts/google_fonts.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../widgets/comment_media_picker.dart';
import '../../../generated/l10n/app_localizations.dart';

Color kPrimaryBlue(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF6366F1) : const Color(0xFF2563EB);

class ChatDetailScreen extends StatefulWidget {
  final int conversationId;
  final int otherUserId;
  final String otherUserName;
  final String otherUserImage;
  final String? otherUserLastSeen;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserImage,
    this.otherUserLastSeen,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final CommunityService _communityService = CommunityService();
  final SocketService _socketService = SocketService();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  int? _currentUserId;
  bool _isLoading = true;
  bool _isSending = false;
  List<File> _selectedImages = [];
  File? _selectedVideo;
  String? _recordingPath;
  bool _isRecording = false;
  late final RecorderController _recorderController;
  final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();
  final String _giphyApiKey = 'KaG7M2d2fNCrcNGI5ceGhqVt4WZpJNOR';
  
  // New state for Chat V2
  Map<String, dynamic>? _replyingTo;
  Map<String, dynamic>? _editingMessage;
  final Map<int, DateTime> _seenTimestamps = {};
  List<StreamSubscription> _subscriptions = [];
  bool _isOtherUserOnline = false;
  String? _otherUserLastSeen;
  
  // Timer for recording
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  DateTime? _recordingStartTime;
  bool _isStartingRecording = false;
  bool _isLongPressMode = false;
  
  // Rich media state (now handled by CommentMediaPicker)

  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _otherUserLastSeen = widget.otherUserLastSeen;
    _recorderController = RecorderController();
    _initSocketAndFetchMessages();
  }

  Future<void> _initSocketAndFetchMessages() async {
    // Fetch current user ID first
    try {
      final user = await _authService.getUser();
      if (mounted) {
        setState(() {
          _currentUserId = user['id'];
        });
      }
    } catch (e) {
      print('Error fetching current user: $e');
    }

    final token = await _apiService.getToken();
    if (token != null) {
      _socketService.activeConversationId = widget.conversationId;
      _socketService.joinConversation(widget.conversationId);
      
      _subscriptions.add(_socketService.userStatus.listen((data) {
        if (mounted && data['userId'] == widget.otherUserId) {
          setState(() {
            _isOtherUserOnline = data['status'] == 'online';
            if (data['last_seen'] != null) {
              _otherUserLastSeen = data['last_seen'];
            }
          });
        }
      }));

      _subscriptions.add(_socketService.messages.listen((data) {
        if (mounted && data['conversationId'] == widget.conversationId) {
          setState(() {
            // Check for both ID and optimistic ID matching
            final existingIndex = _messages.indexWhere((m) => 
               m['id'] == data['id'] || 
               (m['isOptimistic'] == true && m['content'] == data['content'] && m['type'] == data['type'])
            );
            
            if (existingIndex != -1) {
              _messages[existingIndex] = data; // Replace optimistic with real
            } else {
              _messages.add(data);
            }
            // Once we receive a new message while in chat, tell the server we've seen it right away
            if (data['sender_id'] != _currentUserId) {
              _socketService.seenMessage(widget.conversationId, _currentUserId ?? 0);
            }
          });
          _scrollToBottom();
        }
      }));

      _subscriptions.add(_socketService.messageEdits.listen((data) {
        if (mounted && data['conversationId'] == widget.conversationId) {
          setState(() {
            final index = _messages.indexWhere((m) => m['id'] == data['id']);
            if (index != -1) {
              _messages[index] = {..._messages[index], ...data};
            }
          });
        }
      }));

      _subscriptions.add(_socketService.messageDeletes.listen((data) {
        if (mounted && data['conversationId'] == widget.conversationId) {
          setState(() {
            _messages.removeWhere((m) => m['id'] == data['id']);
          });
        }
      }));

      _subscriptions.add(_socketService.messageSeens.listen((data) {
        if (mounted && data['conversationId'] == widget.conversationId) {
          setState(() {
            _seenTimestamps[data['userId']] = DateTime.parse(data['seen_at']);
          });
        }
      }));

      // Notify other user I've seen current messages
      _socketService.seenMessage(widget.conversationId, _currentUserId ?? 0);
    }
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final serverMessages = await _communityService.getMessages(widget.conversationId);
      if (mounted) {
        setState(() {
          for (var msg in serverMessages) {
            // Robust ID matching (handling String vs int)
            final msgId = int.tryParse(msg['id']?.toString() ?? '') ?? msg['id'];
            final idx = _messages.indexWhere((m) => 
               (int.tryParse(m['id']?.toString() ?? '') ?? m['id']) == msgId);
            
            if (idx == -1) {
              _messages.add(msg);
            } else {
              _messages[idx] = msg; // Update with latest server data
            }
          }
          // Sort messages by time to ensure correct order
          _messages.sort((a, b) => (DateTime.tryParse(a['created_at'] ?? '') ?? DateTime.now())
              .compareTo(DateTime.tryParse(b['created_at'] ?? '') ?? DateTime.now()));
          
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((f) => File(f.path)));
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedVideo = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        _sendRichMessage(type: 'file', mediaFile: file, content: fileName);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick file: $e')));
      }
    }
  }


  Future<void> _pickGiphy() async {
    // This method is now integrated into _showRichMediaPicker
    _showRichMediaPicker();
  }

  Future<void> _startRecording() async {
    if (_isStartingRecording || _isRecording) return;
    
    try {
      if (await _recorderController.checkPermission()) {
        _isStartingRecording = true;
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _recorderController.record(
          path: path,
          recorderSettings: RecorderSettings(
            androidEncoderSettings: const AndroidEncoderSettings(
              androidEncoder: AndroidEncoder.aacLc,
            ),
            iosEncoderSettings: const IosEncoderSetting(
              iosEncoder: IosEncoder.kAudioFormatMPEG4AAC,
            ),
            sampleRate: 44100,
            bitRate: 128000,
          ),
        );
        HapticFeedback.vibrate();
        
        if (mounted) {
          setState(() {
            _isRecording = true;
            _isStartingRecording = false;
            _recordingPath = path;
            _recordingDuration = 0;
            _recordingStartTime = DateTime.now();
          });

          _recordingTimer?.cancel();
          _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
            if (mounted && _recordingStartTime != null) {
              setState(() {
                _recordingDuration = DateTime.now().difference(_recordingStartTime!).inSeconds;
              });
            }
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
        );
      }
    } catch (e) {
      print('Error starting recording: $e');
      if (mounted) {
        setState(() => _isStartingRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
      }
    }
  }

  Future<void> _stopRecording({bool shouldSend = true}) async {
    // If we're still initializing, wait a bit or ignore
    if (_isStartingRecording) {
      await Future.delayed(const Duration(milliseconds: 300));
    }
    
    if (!_isRecording) return;

    try {
      _recordingTimer?.cancel();
      final path = await _recorderController.stop();
      print('Recording stopped, path: $path, shouldSend: $shouldSend');
      
      final duration = _recordingStartTime != null 
          ? DateTime.now().difference(_recordingStartTime!).inMilliseconds / 1000.0
          : 0.0;

      setState(() {
        _isRecording = false;
        _isStartingRecording = false;
        _recordingDuration = 0;
        _recordingStartTime = null;
        _isLongPressMode = false;
      });

      if (path != null) {
        if (shouldSend) {
          if (duration > 0.1) { // Slight increase in threshold
             _sendRichMessage(type: 'voice', mediaFile: File(path));
          } else {
            print('Recording too short: $duration s');
            // Cleanup file if too short
            try { await File(path).delete(); } catch (_) {}
          }
        } else {
          // Manual cancel - cleanup file
          try { await File(path).delete(); } catch (_) {}
        }
      }
    } catch (e) {
      print('Error stopping recording: $e');
      if (mounted) {
        setState(() {
          _isRecording = false;
          _isStartingRecording = false;
          _isLongPressMode = false;
        });
      }
    }
  }

  Future<void> _cancelRecording() async {
    await _stopRecording(shouldSend: false);
    HapticFeedback.mediumImpact();
  }

  Future<void> _stopAndSendRecording() async {
     await _stopRecording(shouldSend: true);
     HapticFeedback.lightImpact();
  }

  // Removed _showMediaMenu as buttons are moved outside

  Widget _buildMediaOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showRichMediaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CommentMediaPicker(
        onSelected: ({required type, content, mediaUrl}) {
          Navigator.pop(context);
          
          // Map types to chat system
          String chatType = type;
          if (type == 'emoticon') chatType = 'text';
          if (type == 'gifs' || type == 'gif') chatType = 'gif';
          if (type == 'stickers' || type == 'sticker') chatType = 'sticker';
          
          _sendRichMessage(
            type: chatType,
            content: content,
            mediaUrl: mediaUrl,
            replyToId: _replyingTo?['id'],
          );
        },
      ),
    );
  }

  void _showAttachmentMenu() {
    // Deprecated, popup menu used directly inside _buildMessageInput
  }

  Widget _buildPopupItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(label, style: GoogleFonts.outfit(fontSize: 14)),
      ],
    );
  }

  Widget _buildAttachmentItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildEmptyAttachmentItem() {
    return const SizedBox(width: 60);
  }


  // Removed unused Giphy methods as they are in CommentMediaPicker now

  Future<void> _sendRichMessage({String type = 'text', String? content, File? mediaFile, String? mediaUrl, List<String>? mediaGallery, int? replyToId}) async {
    setState(() => _isSending = true);
    
    final optimisticId = DateTime.now().millisecondsSinceEpoch;
    final optimisticMsg = {
      'id': optimisticId,
      'content': content,
      'senderName': 'Me',
      'type': type,
      'media_url': mediaFile?.path ?? mediaUrl ?? (mediaGallery != null && mediaGallery.isNotEmpty ? mediaGallery[0] : null),
      'media_gallery': mediaGallery,
      'sender_id': _currentUserId ?? 0,
      'created_at': DateTime.now().toIso8601String(),
      'isOptimistic': true, 
      'replyToContent': _replyingTo?['content'],
      'replyToSenderName': _replyingTo?['senderName'],
    };
    
    setState(() {
      _messages.add(optimisticMsg);
      _replyingTo = null; // Clear reply state after sending
    });
    _scrollToBottom();

    try {
      String? finalMediaUrl = mediaUrl;
      
      if (mediaFile != null) {
        final result = await _communityService.uploadMedia(mediaFile);
        finalMediaUrl = result['url'];
      }

      final newMessage = await _communityService.sendMessage(
        widget.conversationId, 
        content ?? '',
        mediaUrl: finalMediaUrl,
        type: type,
        replyToId: replyToId,
        mediaGallery: mediaGallery,
      );

      _socketService.sendMessage(widget.conversationId, newMessage);

      if (mounted) {
        setState(() {
          // The socket listener might have already replaced the optimistic message
          final index = _messages.indexWhere((m) => 
            m['id'] == optimisticId || m['id'] == newMessage['id']
          );
          
          if (index != -1) {
            _messages[index] = newMessage;
          } else {
            // Only add if not already there (though socket should have added it)
            if (!_messages.any((m) => m['id'] == newMessage['id'])) {
              _messages.add(newMessage);
            }
          }
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
       if (mounted) {
          setState(() {
            _messages.removeWhere((m) => m['id'] == optimisticId);
            _isSending = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
       }
    }
  }

  void _onReply(Map<String, dynamic> message) {
    setState(() {
      _replyingTo = message;
      _editingMessage = null;
    });
  }

  void _onEdit(Map<String, dynamic> message) {
    if (message['type'] != 'text') return; // Only text edit for now
    setState(() {
      _editingMessage = message;
      _replyingTo = null;
      _messageController.text = message['content'];
    });
  }

  Future<void> _onDelete(Map<String, dynamic> message) async {
    try {
      await _communityService.deleteMessage(message['id']);
      _socketService.deleteMessage(widget.conversationId, message['id']);
      setState(() {
        _messages.removeWhere((m) => m['id'] == message['id']);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  void _showMessageActions(Map<String, dynamic> message, bool isMe) {
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
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: kPrimaryBlue(context).withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(Icons.reply, color: kPrimaryBlue(context), size: 20),
                  ),
                  title: Text('Reply', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                  subtitle: Text('Quote this message', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                  onTap: () {
                    Navigator.pop(context);
                    _onReply(message);
                  },
                ),
                if (isMe && message['type'] == 'text')
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: kPrimaryBlue(context).withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.edit_rounded, color: kPrimaryBlue(context), size: 20),
                    ),
                    title: Text('Edit', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Text('Modify your message', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                    onTap: () {
                      Navigator.pop(context);
                      _onEdit(message);
                    },
                  ),
                if (isMe)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                    ),
                    title: Text('Delete', style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Text('Remove message for everyone', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteConfirmDialog(message);
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

  void _showDeleteConfirmDialog(Map<String, dynamic> message) {
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
                  'Delete Message',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to delete this message? This action cannot be undone.',
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
                        onPressed: () {
                          Navigator.pop(context);
                          _onDelete(message);
                        },
                        child: Text('Delete', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _selectedImages.isEmpty && _selectedVideo == null) return;
    
    if (_editingMessage != null) {
      final newContent = _messageController.text.trim();
      final msgId = _editingMessage!['id'];
      _messageController.clear();
      setState(() => _editingMessage = null);
      
      try {
        final updated = await _communityService.editMessage(msgId, newContent);
        _socketService.editMessage(widget.conversationId, updated);
        setState(() {
          final idx = _messages.indexWhere((m) => m['id'] == msgId);
          if (idx != -1) _messages[idx] = updated;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Edit failed: $e')));
      }
      return;
    }

    final videoFile = _selectedVideo;
    final imageFiles = List<File>.from(_selectedImages);
    final content = _messageController.text.trim();
    final replyId = _replyingTo?['id'];

    _messageController.clear();
    setState(() {
      _selectedImages = [];
      _selectedVideo = null;
    });

    if (imageFiles.isNotEmpty) {
      setState(() => _isSending = true);
      
      // Upload all images
      List<String> uploadedUrls = [];
      for (var file in imageFiles) {
        final res = await _communityService.uploadMedia(file);
        uploadedUrls.add(res['url']);
      }

      await _sendRichMessage(
        type: 'image',
        content: content,
        mediaGallery: uploadedUrls,
        replyToId: replyId,
      );
    } else if (videoFile != null) {
      await _sendRichMessage(
        type: 'text',
        content: content,
        replyToId: replyId,
      );
    }
  }

  @override
  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _socketService.activeConversationId = null; // Clear active conversation
    _recorderController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: titleColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: (widget.otherUserImage.isNotEmpty && widget.otherUserImage.startsWith('http')) 
                      ? NetworkImage(widget.otherUserImage) 
                      : null,
                  backgroundColor: kPrimaryBlue(context).withOpacity(0.1),
                  child: (widget.otherUserImage.isEmpty || !widget.otherUserImage.startsWith('http')) 
                      ? Text(widget.otherUserName[0], 
                          style: GoogleFonts.outfit(color: kPrimaryBlue(context), fontWeight: FontWeight.bold, fontSize: 14)) 
                      : null,
                ),
                if (_isOtherUserOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: GoogleFonts.outfit(
                      color: titleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _isOtherUserOnline ? AppLocalizations.of(context)!.online : (_otherUserLastSeen != null ? AppLocalizations.of(context)!.lastSeenTimeAgo(timeago.format(DateTime.parse(_otherUserLastSeen!).toLocal())) : AppLocalizations.of(context)!.offline),
                    style: GoogleFonts.outfit(
                      color: _isOtherUserOnline ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: const [
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                // Robust comparison for sender_id (String vs int)
                final senderId = int.tryParse(msg['sender_id']?.toString() ?? msg['Sender_Id']?.toString() ?? '') ?? (msg['sender_id'] ?? msg['Sender_Id']);
                final isMe = senderId.toString() == _currentUserId?.toString();
                return Column(
                  children: [
                    _buildMessageRow(msg, isMe),
                    if (index == _messages.length - 1 && isMe) _buildSeenStatus(msg),
                  ],
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildSeenStatus(Map<String, dynamic> lastMessage) {
    bool isSeen = false;
    
    // Check direct property from database or optimistic update
    if (lastMessage['is_read'] == 1 || lastMessage['is_read'] == true || lastMessage['Is_Read'] == 1 || lastMessage['Is_Read'] == true) {
      isSeen = true;
    }
    
    // Fallback: check if other user emitted a seen event after this message was sent
    if (!isSeen && lastMessage['created_at'] != null && _seenTimestamps.containsKey(widget.otherUserId)) {
      try {
        final messageTime = DateTime.parse(lastMessage['created_at']);
        final seenTime = _seenTimestamps[widget.otherUserId];
        if (seenTime != null && seenTime.isAfter(messageTime)) {
          isSeen = true;
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }

    if (!isSeen) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            AppLocalizations.of(context)!.seen,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          Icon(Icons.done_all, size: 14, color: kPrimaryBlue(context)),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_replyingTo != null) _buildReplyPreview(),
        if (_selectedImages.isNotEmpty || _selectedVideo != null) _buildAttachmentPreview(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80), // Elevated significantly as requested
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFF1E293B).withOpacity(0.5) 
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                if (!_isRecording) ...[
                  PopupMenuButton<VoidCallback>(
                    offset: const Offset(0, -280),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
                    onSelected: (action) => action(),
                    itemBuilder: (context) => [
                      PopupMenuItem(value: _pickImage, child: _buildPopupItem(Icons.image_rounded, AppLocalizations.of(context)!.gallery, Colors.blue)),
                      PopupMenuItem(value: _takePhoto, child: _buildPopupItem(Icons.camera_alt_rounded, AppLocalizations.of(context)!.camera, Colors.pink)),
                      PopupMenuItem(value: _pickVideo, child: _buildPopupItem(Icons.videocam_rounded, AppLocalizations.of(context)!.video, Colors.purple)),
                      PopupMenuItem(value: _pickFile, child: _buildPopupItem(Icons.insert_drive_file_rounded, AppLocalizations.of(context)!.file, Colors.orange)),
                      PopupMenuItem(value: _showRichMediaPicker, child: _buildPopupItem(Icons.sentiment_satisfied_alt_rounded, AppLocalizations.of(context)!.content, Colors.teal)),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kPrimaryBlue(context),
                        shape: BoxShape.circle,
                        boxShadow: [
                           BoxShadow(color: kPrimaryBlue(context).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded, 
                        color: Colors.white, 
                        size: 24
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),
                ] else
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: _cancelRecording,
                  ),
                _buildRecordButton(),
                const SizedBox(width: 8),
                Expanded(
                  child: _isRecording 
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) => AudioWaveforms(
                                  size: Size(constraints.maxWidth, 40),
                                  recorderController: _recorderController,
                                  enableGesture: true,
                                  waveStyle: const WaveStyle(
                                    waveColor: Colors.red,
                                    bottomPadding: 0,
                                    showMiddleLine: false,
                                    spacing: 3.5,
                                    extendWaveform: true,
                                    backgroundColor: Colors.transparent,
                                  ),
                                ), 
                              ), 
                            ), 
                            const SizedBox(width: 8),
                            _buildRecordingTimer(),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: TextField(
                          controller: _messageController,
                          maxLines: 5, // Allow up to 5 lines of growth
                          minLines: 1, // Start with 1 line
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: _editingMessage != null ? AppLocalizations.of(context)!.editMessage : AppLocalizations.of(context)!.typeAMessage,
                            border: InputBorder.none,
                            hintStyle: GoogleFonts.outfit(color: const Color(0xFF94A3B8)),
                          ),
                          onChanged: (_) {
                            setState(() {});
                          },

                        ),
                      ),
                ),
                if (_isRecording)
                  IconButton(
                    icon: Icon(Icons.send, color: kPrimaryBlue(context)),
                    onPressed: () => _stopRecording(shouldSend: true),
                  )
                else if (_messageController.text.isNotEmpty || _selectedImages.isNotEmpty || _selectedVideo != null)
                  IconButton(
                    icon: Icon(
                      _editingMessage != null ? Icons.check_circle : Icons.send, 
                      color: kPrimaryBlue(context)
                    ),
                    onPressed: _sendMessage,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildRecordingTimer() {
    return Text(
      _formatDuration(_recordingDuration * 1000), // convert seconds to ms for formatter
      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
    );
  }

  String _formatDuration(int milliseconds) {
    if (milliseconds == 0) return "00:00";
    final Duration duration = Duration(milliseconds: milliseconds);
    final int minutes = duration.inMinutes;
    final int seconds = (duration.inSeconds % 60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showAttachmentOptions() {
    _showRichMediaPicker();
  }

  Widget _buildAttachmentPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _selectedVideo != null ? "Video selected" : "${_selectedImages.length} images selected",
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() { _selectedImages = []; _selectedVideo = null; }),
                child: const Icon(Icons.close_rounded, size: 20, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedVideo != null ? 1 : _selectedImages.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _selectedVideo != null 
                        ? Container(
                           width: 80, 
                           height: 80, 
                           color: Colors.black, 
                           child: const Icon(Icons.videocam_rounded, color: Colors.white)
                          )
                        : Image.file(_selectedImages[index], height: 80, width: 80, fit: BoxFit.cover),
                    ),
                    if (_selectedVideo == null)
                      Positioned(
                        top: 2, right: 2,
                        child: GestureDetector(
                          onTap: () => setState(() { _selectedImages.removeAt(index); }),
                          child: const CircleAvatar(radius: 10, backgroundColor: Colors.white, child: Icon(Icons.close, size: 14, color: Colors.black)),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onLongPress: () {
        setState(() => _isLongPressMode = true);
        _startRecording();
      },
      onLongPressUp: () {
        if (_isLongPressMode && _isRecording) {
          _stopRecording(shouldSend: true);
        }
      },
      onTap: () {
        if (!_isRecording) {
          _isLongPressMode = false;
          _startRecording();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: _isRecording 
          ? const Icon(Icons.mic, color: Colors.red, size: 26) // Removed pulsing animation
          : Icon(Icons.mic_none_outlined, color: kPrimaryBlue(context), size: 26),
      ),
    );
  }

  Widget _buildReplyPreview() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade50,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Icon(Icons.reply, color: kPrimaryBlue(context), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.replyingToName(_replyingTo!['senderName']),
                  style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryBlue(context), fontSize: 12),
                ),
                Text(
                  _replyingTo!['content'] ?? AppLocalizations.of(context)!.media,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => setState(() => _replyingTo = null),
          ),
        ],
      ),
    );
  }

  Widget _buildMeshBackground() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100, right: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(color: const Color(0xFFBBDEFB).withOpacity(0.4), shape: BoxShape.circle),
            ),
          ),
          Positioned(
            bottom: -80, left: -60,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(color: const Color(0xFFE3F2FD).withOpacity(0.6), shape: BoxShape.circle),
            ),
          ),
          Positioned(
            top: 200, left: -100,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(color: const Color(0xFFE3F2FD).withOpacity(0.3), shape: BoxShape.circle),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageRow(Map<String, dynamic> msg, bool isMe) {
    return SwipeTo(
      onRightSwipe: (details) => _onReply(msg),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isMe) ...[
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(
                      userId: msg['sender_id'],
                      userName: msg['senderName'] ?? 'Unknown',
                      userImage: msg['senderImage'] ?? '',
                    ))),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundImage: (msg['senderImage'] != null && msg['senderImage'].startsWith('http')) ? NetworkImage(msg['senderImage']) : null,
                      backgroundColor: Colors.grey.shade300,
                        child: (msg['senderImage'] == null || !msg['senderImage'].startsWith('http')) ? Text(msg['senderName']?[0] ?? '?', style: const TextStyle(fontSize: 10)) : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(child: _buildMessageBubble(msg, isMe)),
              ],
            ),
            if (msg['isOptimistic'] == true)
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 4),
                child: Text(AppLocalizations.of(context)!.sending, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
              ),
          ],
        ),
      ),
    );
  }

  bool _isOnlyEmoji(String text) {
    if (text.isEmpty) return false;
    final emojiRegex = RegExp(
      r'^(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])+$',
    );
    return emojiRegex.hasMatch(text.replaceAll(RegExp(r'\s+'), ''));
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    final type = message['type'] ?? 'text';
    // Try multiple possible field names for content due to backend variations
    final content = message['content'] ?? message['Content'] ?? message['message_text'] ?? message['text'];
    final mediaUrl = message['media_url'] ?? message['image_url'];
    final isImage = type == 'image' && mediaUrl != null;
    
    final bool isEmojiOnly = type == 'text' && content != null && _isOnlyEmoji(content);
    final bool isSticker = type == 'sticker';
    
    // Bubble is skipped for images, videos, voice, stickers, and emoji-only messages
    final isNoBubble = isImage || type == 'video' || type == 'voice' || isSticker || isEmojiOnly;
    final isReply = message['reply_to_id'] != null || message['replyToContent'] != null;

    return GestureDetector(
      onLongPress: () => _showMessageActions(message, isMe),
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        padding: EdgeInsets.all(isNoBubble ? 0 : (type == 'gif' ? 4 : 12)),
        decoration: isNoBubble 
            ? null 
            : BoxDecoration(
                  color: isMe 
                      ? kPrimaryBlue(context) 
                      : (Theme.of(context).brightness == Brightness.dark 
                          ? const Color(0xFF1E293B) 
                          : Colors.white.withOpacity(0.8)),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(24),
                    topRight: const Radius.circular(24),
                    bottomLeft: Radius.circular(isMe ? 24 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 24),
                  ),
                  border: !isMe ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
                ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isReply) _buildReplyPreviewBubble(message, isMe),
            if (type == 'sticker') ...[
               if (mediaUrl != null) 
                 _buildStickerContent(mediaUrl)
               else if (content != null)
                 Text(content, style: const TextStyle(fontSize: 80)),
            ],
            if (isImage) ...[
               if (message['media_gallery'] != null)
                 _buildImageGallery(message['media_gallery'])
               else
                 _buildImageContent(mediaUrl!),
            ],
            if (type == 'video' && mediaUrl != null)
               _buildVideoContent(mediaUrl),
            if (type == 'file' && mediaUrl != null)
               _buildFileContent(mediaUrl, content ?? 'File'),
            if (type == 'gif' && mediaUrl != null)
               _buildGifContent(mediaUrl),
            if (type == 'voice' && mediaUrl != null)
               _buildVoiceContent(mediaUrl, isMe),

            
            if (content != null && content.isNotEmpty && type != 'sticker' && type != 'image') ...[
              if (type == 'video' || type == 'gif' || type == 'voice') const SizedBox(height: 8),
              Text(
                content,
                style: TextStyle(
                  color: (isMe && !isNoBubble) 
                      ? Colors.white 
                      : (Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A237E)),
                  fontSize: isEmojiOnly ? 40 : 15,
                  height: 1.3,
                ),
              ),
            ],
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min, // This makes the row only as wide as its children
              children: [
                if (message['is_edited'] == 1 || message['is_edited'] == true || message['Is_Edited'] == 1 || message['Is_Edited'] == true)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(AppLocalizations.of(context)!.edited, style: TextStyle(fontSize: 9, color: (isMe && !isNoBubble) ? Colors.white70 : Colors.black38)),
                  ),
                const SizedBox(width: 8), // Replaces Spacer to keep it compact
                  Text(
                    _formatTime(message['created_at'] ?? message['Created_At']),
                    style: TextStyle(
                      color: (isMe && !isNoBubble) 
                          ? Colors.white.withOpacity(0.7) 
                          : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black45),
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreviewBubble(Map<String, dynamic> message, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMe ? Colors.black.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: isMe ? Colors.white70 : kPrimaryBlue(context), width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message['replyToSenderName'] ?? 'Unknown',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isMe ? Colors.white : kPrimaryBlue(context)),
          ),
          const SizedBox(height: 2),
          Text(
            message['replyToContent'] ?? AppLocalizations.of(context)!.media,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: isMe ? Colors.white70 : Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(dynamic galleryData) {
    List<String> urls = [];
    if (galleryData is List) {
      urls = List<String>.from(galleryData);
    } else if (galleryData is String) {
      try {
        urls = List<String>.from(jsonDecode(galleryData));
      } catch (_) {}
    }

    if (urls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: urls.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) => _buildImageContent(urls[index], width: 200),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            "${urls.length} images",
            style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent(String url, {double? width}) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: width ?? MediaQuery.of(context).size.width * 0.7,
            maxHeight: 350,
          ),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: width ?? 280,
                height: 200,
                color: Colors.grey.shade100,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(kPrimaryBlue(context)))),
              );
            },
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PhotoView(
            imageProvider: NetworkImage(url),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent(String url) {
    return GestureDetector(
      onTap: () => _showFullScreenVideo(url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7, 
            maxHeight: 300,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoBubble(url: url),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenVideo(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: VideoBubble(url: url, isFullScreen: true),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 32),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileContent(String url, String fileName) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  AppLocalizations.of(context)!.tapToOpen,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildGifContent(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
          );
        },
      ),
    );
  }

  Widget _buildStickerContent(String url) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 180, maxWidth: 180),
      child: Image.network(
        url,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(
            width: 150,
            height: 150,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(
            width: 150,
            height: 150,
            child: Center(child: Icon(Icons.broken_image, color: Colors.grey)),
          );
        },
      ),
    );
  }

  Widget _buildVoiceContent(String url, bool isMe) {
    // We don't have the duration here easily without fetching, 
    // but the VoiceBubble child will handle its own sizing internally 
    // now to be more dynamic.
    return VoiceBubble(url: url, isMe: isMe);
  }


  Widget _buildRecordingDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }

  String get _stopwatchValue {
    final minutes = (_recordingDuration / 60).floor();
    final seconds = _recordingDuration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildStatusInfo() {
    if (_isOtherUserOnline) {
      return Text(AppLocalizations.of(context)!.online, style: const TextStyle(color: Colors.green, fontSize: 11));
    }

    if (_otherUserLastSeen == null) {
      return Text(AppLocalizations.of(context)!.offline, style: const TextStyle(color: Colors.grey, fontSize: 11));
    }
    
    try {
      // Must ensure UTC parsing if SQL sends UTC, or append 'Z' if missing and expected
      var lastSeenStr = _otherUserLastSeen!;
      if (!lastSeenStr.endsWith('Z') && !lastSeenStr.contains('+')) {
        lastSeenStr += 'Z'; // Assuming the backend saves UTC `CURRENT_TIMESTAMP`
      }
      final lastSeen = DateTime.parse(lastSeenStr).toLocal();
      final now = DateTime.now();
      final difference = now.difference(lastSeen);
      
      if (difference.inMinutes < 1) {
        return Text(AppLocalizations.of(context)!.lastSeenJustNow, style: const TextStyle(color: Colors.grey, fontSize: 11));
      } else if (difference.inMinutes < 60) {
        return Text(AppLocalizations.of(context)!.lastSeenMinsAgo(difference.inMinutes.toString()), style: const TextStyle(color: Colors.grey, fontSize: 11));
      } else if (difference.inHours < 24) {
        return Text(AppLocalizations.of(context)!.lastSeenHoursAgo(difference.inHours.toString()), style: const TextStyle(color: Colors.grey, fontSize: 11));
      } else {
        return Text(AppLocalizations.of(context)!.lastSeenTimeAgo(timeago.format(lastSeen)), style: const TextStyle(color: Colors.grey, fontSize: 11));
      }
    } catch (e) {
      return const Text('Offline', style: TextStyle(color: Colors.grey, fontSize: 11));
    }
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return '';
    try {
      final rawDate = DateTime.parse(isoString);
      final date = rawDate.isUtc ? rawDate.toLocal() : rawDate.add(rawDate.timeZoneOffset).toLocal();
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}

class VideoBubble extends StatefulWidget {
  final String url;
  final bool isFullScreen;
  const VideoBubble({super.key, required this.url, this.isFullScreen = false});

  @override
  State<VideoBubble> createState() => _VideoBubbleState();
}

class _VideoBubbleState extends State<VideoBubble> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;
  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }
  Future<void> _initializePlayer() async {
    _controller = widget.url.startsWith('http') 
        ? VideoPlayerController.networkUrl(Uri.parse(widget.url))
        : VideoPlayerController.file(File(widget.url));
    await _controller.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      aspectRatio: _controller.value.aspectRatio,
      autoPlay: widget.isFullScreen, // Autoplay if full screen
      looping: false,
    );
    if (mounted) setState(() {});
  }
  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if (_chewieController == null || !_chewieController!.videoPlayerController.value.isInitialized) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.isFullScreen ? 0 : 12),
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Chewie(controller: _chewieController!),
      ),
    );
  }
}

class VoiceBubble extends StatefulWidget {
  final String url;
  final bool isMe;
  const VoiceBubble({Key? key, required this.url, required this.isMe}) : super(key: key);
  @override
  _VoiceBubbleState createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<VoiceBubble> {
  late PlayerController _playerController;
  late StreamSubscription<PlayerState> _playerStateSubscription;
  bool _isPlayerReady = false;
  int _currentPosition = 0;
  int _totalDuration = 0;

  @override
  void initState() {
    super.initState();
    _playerController = PlayerController();
    _preparePlayer();
    _playerStateSubscription = _playerController.onPlayerStateChanged.listen((state) {
      if (mounted) {
        if (state == PlayerState.stopped || state == PlayerState.paused) {
          // If we reached the end (total duration matches current or state is stopped)
          // we can reset to beginning if needed, but setState is enough for basic icon update
        }
        setState(() {});
      }
    });
    _playerController.onCurrentDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _currentPosition = duration;
        });
      }
    });
  }

  Future<void> _preparePlayer() async {
    try {
      // For network URLs, audio_waveforms preparePlayer might need a local path for waveform extraction
      // but let's try direct path first as some versions support it
      await _playerController.preparePlayer(
        path: widget.url,
        shouldExtractWaveform: true,
      );
      if (mounted) {
        final duration = await _playerController.getDuration(DurationType.max);
        setState(() {
          _isPlayerReady = true;
          _totalDuration = duration;
        });
      }
    } catch (e) {
      debugPrint("Error preparing player: $e");
    }
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    _playerController.dispose();
    super.dispose();
  }

  bool get _isPlaying => _playerController.playerState.isPlaying;

  String _formatDuration(int ms) {
    if (ms <= 0) return "0:00";
    final duration = Duration(milliseconds: ms);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = kPrimaryBlue(context);
    final Color secondaryTextColor = Colors.black54;

    // Use a fixed maximum width from MediaQuery to prevent infinite width issues
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBubbleWidth = screenWidth * 0.70; // 70% of screen max

    // Make the waveform width purely dependent on audio duration, with a hard cap.
    // 50 pixels per second, min 80, max allowable space.
    double rawWaveformWidth = 80.0 + (_totalDuration / 1000.0) * 30.0;
    
    // We need space for: Icon (~48) + Spacing (8)
    double availableWaveformSpace = maxBubbleWidth - 120.0; // Padded slightly more for safety
    double finalWaveformWidth = rawWaveformWidth.clamp(80.0, availableWaveformSpace);

    double spacing = 2.5;
    double waveThickness = 2.0;

    return Container(
      constraints: BoxConstraints(maxWidth: maxBubbleWidth),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isMe 
            ? kPrimaryBlue(context).withOpacity(0.08) 
            : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Hug contents tightly
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: accentColor,
              size: 34,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () async {
              if (!_isPlayerReady) return;
              if (_isPlaying) {
                await _playerController.pausePlayer();
              } else {
                await _playerController.startPlayer();
              }
              setState(() {});
            },
          ),
          const SizedBox(width: 8),
          
          Flexible(
            child: _isPlayerReady
              ? AudioFileWaveforms(
                  size: Size(finalWaveformWidth, 30),
                  playerController: _playerController,
                  enableSeekGesture: true,
                  waveformType: WaveformType.fitWidth,
                  playerWaveStyle: PlayerWaveStyle(
                    fixedWaveColor: accentColor.withOpacity(0.2),
                    liveWaveColor: accentColor,
                    spacing: spacing,
                    waveThickness: waveThickness,
                    seekLineColor: accentColor,
                    seekLineThickness: 2.0,
                  ),
                )
              : SizedBox(
                  width: 80, 
                  height: 30, 
                  child: const Center(child: LinearProgressIndicator(minHeight: 2))
                ),
          ),
            
          const SizedBox(width: 12),
          
          // Single dynamic timer: shows current play head if playing, or total if stopped
          SizedBox(
            width: 35, // Fixed width to prevent jumping numbers
            child: Text(
              _isPlaying || _currentPosition > 0 
                  ? _formatDuration(_currentPosition) 
                  : _formatDuration(_totalDuration),
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : secondaryTextColor, 
                fontSize: 11, 
                fontWeight: FontWeight.w500
              ),
            ),
          ),
        ],
      ),
    );
  }
}
