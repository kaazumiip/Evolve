import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static String currentGlobalSubscription = 'Free Access';
  static bool isDarkMode = false;
  static String currentLanguage = 'en';

  static void resetState() {
    currentGlobalSubscription = 'Free Access';
    isDarkMode = false;
  }

  // --- DEVICE HOST CONFIGURATION ---
  static const String _localhost = '127.0.0.1';   // Use for Windows/Web/Desktop
  static const String _emulatorHost = '10.0.2.2'; // Standard Android Emulator host
  static const String _wifiHost = '172.21.0.211';   // Your current Wi-Fi IP (from ipconfig)
  static const String _usbHost = '127.0.0.1';    // Use when connected via USB (adb reverse tcp:5000 tcp:5000)


  static const String baseUrl = 'https://evolve-rv6a.onrender.com/api/'; 
  // static const String baseUrl = 'http://192.168.1.5:5000/api/'; 

  
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {     
          // Add auth token to headers if available
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept-Language'] = currentLanguage;
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Add global error handling here if needed
          print('API Error: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> setToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> setUserId(String userId) async {
    await _storage.write(key: 'user_id', value: userId);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_id');
  }

  // Scholarship Scouting
  Future<List<dynamic>> getScoutedScholarships({int page = 1, int limit = 10, bool force = false}) async {
    try {
      final response = await _dio.get(
        'scholarships/scout',
        queryParameters: {
          'page': page,
          'limit': limit,
          'force': force,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 120), // AI generation takes time
        ),
      );
      return response.data;
    } catch (e) {
      print('Scholarship Fetch Error: $e');
      return [];
    }
  }

  // Favorites
  Future<Map<String, dynamic>> toggleFavorite(String itemType, int itemId) async {
    try {
      final userId = await _storage.read(key: 'user_id'); // Assuming user_id is stored during auth
      final response = await _dio.post(
        'favorites/toggle',
        data: {
          'userId': userId,
          'itemType': itemType,
          'itemId': itemId,
        },
      );
      return response.data;
    } catch (e) {
      print('Toggle Favorite Error: $e');
      return {'isFavorited': false};
    }
  }

  Future<bool> checkFavorite(String itemType, int itemId) async {
    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId == null) return false;
      
      final response = await _dio.get(
        'favorites/check',
        queryParameters: {
          'userId': userId,
          'itemType': itemType,
          'itemId': itemId,
        },
      );
      return response.data['isFavorited'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getFavorites() async {
    try {
      final userId = await _storage.read(key: 'user_id');
      if (userId == null) return [];

      final response = await _dio.get('favorites/$userId');
      return response.data;
    } catch (e) {
      print('Get Favorites Error: $e');
      return [];
    }
  }

  // Careers (AI Generated Maps)
  Future<Map<String, dynamic>?> getCareerComparison(List<int> interestIds) async {
    try {
      final response = await _dio.post(
        'careers/compare',
        data: {'interestIds': interestIds},
        options: Options(receiveTimeout: const Duration(seconds: 45)), // Generative AI takes longer
      );
      return response.data;
    } catch (e) {
      print('Career Comparison Generation Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCareerRoadmap(String careerTitle) async {
    try {
      final response = await _dio.post(
        'careers/roadmap',
        data: {'careerTitle': careerTitle},
        options: Options(receiveTimeout: const Duration(seconds: 45)), // Generative AI takes longer
      );
      return response.data;
    } catch (e) {
      print('Career Roadmap Generation Error: $e');
      return null;
    }
  }
  // User & Friends
  Future<Map<String, dynamic>?> getUserProfile(int userId) async {
    try {
      final response = await _dio.get('users/profile/$userId');
      return response.data;
    } catch (e) {
      print('Get User Profile Error: $e');
      return null;
    }
  }

  Future<bool> sendFriendRequest(int targetUserId) async {
    try {
      await _dio.post('users/friend-request/$targetUserId');
      return true;
    } catch (e) {
      print('Send Friend Request Error: $e');
      return false;
    }
  }

  Future<bool> acceptFriendRequest(int targetUserId) async {
    try {
      await _dio.post('users/friend-accept/$targetUserId');
      return true;
    } catch (e) {
      print('Accept Friend Request Error: $e');
      return false;
    }
  }

  Future<bool> removeFriend(int targetUserId) async {
    try {
      await _dio.delete('users/friend/$targetUserId');
      return true;
    } catch (e) {
      print('Remove Friend Error: $e');
      return false;
    }
  }

  Future<List<dynamic>> searchUsers(String query) async {
    try {
      // Assuming a generic user search endpoint exists or searching by query params
      final response = await _dio.get('users/search', queryParameters: {'q': query});
      return response.data;
    } catch (e) {
      print('Search Users Error: $e');
      return [];
    }
  }

  Future<void> logScholarshipView(int scholarshipId, String title) async {
    try {
      await _dio.post('scholarships/view', data: {
        'scholarshipId': scholarshipId,
        'title': title,
      });
    } catch (e) {
      print('Error logging scholarship view: $e');
    }
  }

  Future<bool> updateSubscription(String planName) async {
    try {
      await _dio.put('users/subscription', data: {'planName': planName});
      currentGlobalSubscription = planName; // Update local state for UI consistency
      return true;
    } catch (e) {
      print('Update Subscription Error: $e');
      return false;
    }
  }
}
