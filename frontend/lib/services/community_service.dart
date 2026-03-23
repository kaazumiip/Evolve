import 'package:dio/dio.dart';
import '../services/api_service.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

class CommunityService {
  final ApiService _api = ApiService();

  // Community
  Future<List<Map<String, dynamic>>> getPosts() async {
    try {
      final response = await _api.dio.get('/community/posts');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print('Error fetching posts: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> createPost(String title, String body, List<String> tags, {String? imageUrl, List<String>? mediaUrls}) async {
    try {
      final response = await _api.dio.post('/community/posts', data: {
        'title': title,
        'body': body,
        'tags': tags,
        'image_url': imageUrl,
        'media_urls': mediaUrls,
      });
      return response.data;
    } catch (e) {
      print('Error creating post: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> getPostDetails(int id) async {
    try {
      final response = await _api.dio.get('/community/posts/$id');
      return response.data;
    } catch (e) {
      print('Error fetching post details: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> addComment(int postId, String content, {int? parentId, String? type, String? mediaUrl}) async {
    try {
      final response = await _api.dio.post('/community/posts/$postId/comments', data: {
        'content': content,
        'parent_id': parentId,
        'type': type ?? 'text',
        'media_url': mediaUrl,
      });
      return response.data;
    } catch (e) {
      print('Error adding comment: $e');
      throw e;
    }
  }

   Future<bool> toggleLike(int postId) async {
    try {
      final response = await _api.dio.post('/community/posts/$postId/like');
      return response.data['liked'];
    } catch (e) {
      print('Error toggling like: $e');
      throw e;
    }
  }

  Future<bool> toggleCommentLike(int commentId) async {
    try {
      final response = await _api.dio.post('/community/comments/$commentId/like');
      return response.data['liked'];
    } catch (e) {
      print('Error toggling comment like: $e');
      throw e;
    }
  }

  Future<void> updatePost(int id, String title, String body, List<String> tags, {String? imageUrl, List<String>? mediaUrls}) async {
    try {
      await _api.dio.put('/community/posts/$id', data: {
        'title': title,
        'body': body,
        'tags': tags,
        'image_url': imageUrl,
        'media_urls': mediaUrls,
      });
    } catch (e) {
      print('Error updating post: $e');
      throw e;
    }
  }

  Future<void> deletePost(int id) async {
    try {
      await _api.dio.delete('/community/posts/$id');
    } catch (e) {
      print('Error deleting post: $e');
      throw e;
    }
  }

  Future<void> updateComment(int commentId, String content) async {
    try {
      await _api.dio.put('/community/comments/$commentId', data: {
        'content': content,
      });
    } catch (e) {
      print('Error updating comment: $e');
      throw e;
    }
  }

  Future<void> deleteComment(int commentId) async {
    try {
      await _api.dio.delete('/community/comments/$commentId');
    } catch (e) {
      print('Error deleting comment: $e');
      throw e;
    }
  }



  // Chat
  Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final response = await _api.dio.get('/chat/conversations');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
         // Return empty list on 404/server error to not crash UI for now
        if (e is DioException && e.response?.statusCode == 404) return [];
        print('Error fetching conversations: $e');
        return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> getMessages(int conversationId) async {
     try {
      final response = await _api.dio.get('/chat/conversations/$conversationId/messages');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print('Error fetching messages: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> sendMessage(int conversationId, String content, {String? imageUrl, String? mediaUrl, String? type, int? replyToId, List<String>? mediaGallery}) async {
    try {
      final response = await _api.dio.post('/chat/conversations/$conversationId/messages', data: {
        'content': content,
        'image_url': imageUrl,
        'media_url': mediaUrl,
        'type': type ?? 'text',
        'reply_to_id': replyToId,
        'media_gallery': mediaGallery,
      });
      return response.data;
    } catch (e) {
      print('Error sending message: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> editMessage(int messageId, String content) async {
    try {
      final response = await _api.dio.put('/chat/messages/$messageId', data: {
        'content': content,
      });
      return response.data;
    } catch (e) {
      print('Error editing message: $e');
      throw e;
    }
  }

  Future<void> deleteMessage(int messageId) async {
    try {
      await _api.dio.delete('/chat/messages/$messageId');
    } catch (e) {
      print('Error deleting message: $e');
      throw e;
    }
  }

  // Upload returns a Map with url and resource_type now
  // Notifications
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await _api.dio.get('/notifications');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> markNotificationRead(int id) async {
    try {
      await _api.dio.post('/notifications/$id/read');
    } catch (e) {
      print('Error marking notification read: $e');
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await _api.dio.post('/notifications/read-all');
    } catch (e) {
      print('Error marking all notifications read: $e');
    }
  }
  Future<Map<String, dynamic>> uploadMedia(dynamic file) async {
    try {
       String filePath = file.path;
       String fileName = p.basename(filePath);
       String ext = p.extension(filePath).toLowerCase();
       
       String mimeType = 'image/jpeg';
       if (ext == '.mp4' || ext == '.mov' || ext == '.avi' || ext == '.wmv') mimeType = 'video/mp4';
       if (ext == '.m4a' || ext == '.aac') mimeType = 'audio/mp4';
       if (ext == '.mp3') mimeType = 'audio/mpeg';
       if (ext == '.png') mimeType = 'image/png';
       if (ext == '.gif') mimeType = 'image/gif';
       if (ext == '.webp') mimeType = 'image/webp';
       
       FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(
          filePath, 
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      });

      final response = await _api.dio.post('/upload', data: formData);
      return response.data; // { url: ..., resource_type: ... }
    } catch (e) {
      print('Error uploading media: $e');
      throw e;
    }
  }

  // Search
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final response = await _api.dio.get('/community/users/search', queryParameters: {'q': query});
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print('Error searching users: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> searchPosts(String query) async {
    try {
      final response = await _api.dio.get('/community/posts/search', queryParameters: {'q': query});
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print('Error searching posts: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> searchByTag(String query) async {
    try {
      final response = await _api.dio.get('/community/tags/search', queryParameters: {'q': query});
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print('Error searching by tag: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getRecommendations() async {
    try {
      final response = await _api.dio.get('/community/recommendations');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print('Error fetching recommendations: $e');
      return [];
    }
  }

  Future<int> startConversation(int targetUserId) async {
    try {
      final response = await _api.dio.post('/chat/conversations', data: {
        'targetUserId': targetUserId,
      });
      return response.data['conversationId'];
    } catch (e) {
      print('Error starting conversation: $e');
      throw e;
    }
  }

  // Social
  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final response = await _api.dio.get('/users/profile/$userId');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      print('Error fetching user profile: $e');
      throw e;
    }
  }

  Future<void> sendFriendRequest(int userId) async {
    try {
      await _api.dio.post('/users/friend-request/$userId');
    } catch (e) {
      print('Error sending friend request: $e');
      throw e;
    }
  }

  Future<void> acceptFriendRequest(int userId) async {
    try {
      await _api.dio.post('/users/friend-accept/$userId');
    } catch (e) {
      print('Error accepting friend request: $e');
      throw e;
    }
  }

  Future<void> removeFriend(int userId) async {
    try {
      await _api.dio.delete('/users/friend/$userId');
    } catch (e) {
      print('Error removing friend: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getFriends() async {
    try {
      final response = await _api.dio.get('/users/friends');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print('Error fetching friends: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserActivities(int userId) async {
    try {
      final response = await _api.dio.get('/community/users/$userId/activities');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print('Error fetching user activities: $e');
      return [];
    }
  }
}
