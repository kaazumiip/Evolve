import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import 'package:flutter/foundation.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();
  final _messageEditController = StreamController<Map<String, dynamic>>.broadcast();
  final _messageDeleteController = StreamController<Map<String, dynamic>>.broadcast();
  final _messageSeenController = StreamController<Map<String, dynamic>>.broadcast();
  final _userStatusController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  Stream<Map<String, dynamic>> get notifications => _notificationController.stream;
  Stream<Map<String, dynamic>> get messageEdits => _messageEditController.stream;
  Stream<Map<String, dynamic>> get messageDeletes => _messageDeleteController.stream;
  Stream<Map<String, dynamic>> get messageSeens => _messageSeenController.stream;
  Stream<Map<String, dynamic>> get userStatus => _userStatusController.stream;

  int? activeConversationId;
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  void resetUnreadCount() {
    unreadCount.value = 0;
  }

  void connect(String url, String token, int userId) {
    if (socket != null && socket!.connected) return;

    socket = IO.io(url, IO.OptionBuilder()
      .setTransports(['websocket'])
      .setExtraHeaders({'Authorization': 'Bearer $token'})
      .build());

    socket!.onConnect((_) {
      print('Connected to socket server');
      socket!.emit('user_connected', userId);
    });

    socket!.on('user_status_changed', (data) {
      _userStatusController.add(Map<String, dynamic>.from(data));
    });

    socket!.on('receive_message', (data) {
      final msg = Map<String, dynamic>.from(data);
      _messageController.add(msg);
      
      // If it's not the active conversation, send to notifications and increment unread count
      if (activeConversationId == null || activeConversationId != msg['conversationId']) {
        if (msg['sender_id'] != userId) {
           _notificationController.add(msg);
           unreadCount.value++;
        }
      }
    });

    socket!.on('message_edited', (data) {
      _messageEditController.add(Map<String, dynamic>.from(data));
    });

    socket!.on('message_deleted', (data) {
      _messageDeleteController.add(Map<String, dynamic>.from(data));
    });

    socket!.on('message_seen', (data) {
      _messageSeenController.add(Map<String, dynamic>.from(data));
    });

    socket!.onDisconnect((_) => print('Disconnected from socket server'));
    
    socket!.connect();
  }

  void joinConversation(int conversationId) {
    socket?.emit('join_conversation', conversationId);
  }

  void sendMessage(int conversationId, Map<String, dynamic> messageData) {
    socket?.emit('send_message', {
      ...messageData,
      'conversationId': conversationId,
    });
  }

  void editMessage(int conversationId, Map<String, dynamic> messageData) {
    socket?.emit('edit_message', {
      ...messageData,
      'conversationId': conversationId,
    });
  }

  void deleteMessage(int conversationId, int messageId) {
    socket?.emit('delete_message', {
      'id': messageId,
      'conversationId': conversationId,
    });
  }

  void seenMessage(int conversationId, int userId) {
    socket?.emit('seen_message', {
      'conversationId': conversationId,
      'userId': userId,
      'seen_at': DateTime.now().toIso8601String(),
    });
  }

  void dispose() {
    socket?.disconnect();
    _messageController.close();
    _notificationController.close();
    _messageEditController.close();
    _messageDeleteController.close();
    _messageSeenController.close();
    _userStatusController.close();
  }
}
