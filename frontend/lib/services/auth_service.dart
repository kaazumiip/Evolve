import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'api_service.dart';
import 'push_notification_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.dio.post('auth/login', data: {
        'email': email,
        'password': password,
      });
      
      final data = response.data;
      if (data != null && data['token'] != null) {
        await _apiService.setToken(data['token']);
        if (data['user'] != null && data['user']['id'] != null) {
          await _apiService.setUserId(data['user']['id'].toString());
        }
        await updateFcmToken();
      }
      return data;
    } on DioException catch (e) {
        throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String otp) async {
    try {
      final response = await _apiService.dio.post('auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'otp': otp,
      });
      
      final data = response.data;
      if (data != null && data['token'] != null) {
        await _apiService.setToken(data['token']);
        if (data['user'] != null && data['user']['id'] != null) {
          await _apiService.setUserId(data['user']['id'].toString());
        }
        await updateFcmToken();
      }
      return data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '743869151112-k64n63b3p3vdslkp6luepood87t97og8.apps.googleusercontent.com',
  );

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Force account picker by signing out first
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In aborted');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get ID Token from Google');
      }

      final response = await _apiService.dio.post('auth/google/native', data: {
        'idToken': idToken,
      });

      final data = response.data;
      if (data != null && data['token'] != null) {
        await _apiService.setToken(data['token']);
        if (data['user'] != null && data['user']['id'] != null) {
          await _apiService.setUserId(data['user']['id'].toString());
        }
        await updateFcmToken();
      }
      return data;
    } on DioException catch (e) {
       throw _handleError(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        
        final response = await _apiService.dio.post('auth/facebook', data: {
          'accessToken': accessToken.tokenString,
        });

        final data = response.data;
        if (data != null && data['token'] != null) {
          await _apiService.setToken(data['token']);
          if (data['user'] != null && data['user']['id'] != null) {
            await _apiService.setUserId(data['user']['id'].toString());
          }
          await updateFcmToken();
        }
        return data;
      } else if (result.status == LoginStatus.cancelled) {
        throw Exception('Facebook Sign-In cancelled');
      } else {
        throw Exception('Facebook Sign-In failed: ${result.message}');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    ApiService.resetState();
    await _apiService.clearToken();
  }
  
  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null;
  }

  Future<void> setToken(String token) async {
    await _apiService.setToken(token);
  }

  Future<String?> getToken() async {
    return await _apiService.getToken();
  }

  Future<Map<String, dynamic>> getUser() async {
    try {
      final response = await _apiService.dio.get('auth/me');
      final data = response.data;
      if (data != null && data['id'] != null) {
        await _apiService.setUserId(data['id'].toString());
        ApiService.currentGlobalSubscription = data['subscription_plan'] ?? 'Free Access';
      }
      return data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateFcmToken() async {
    try {
      final token = await PushNotificationService.getToken();
      if (token != null) {
        await _apiService.dio.post('auth/update-fcm-token', data: {
          'fcmToken': token,
        });
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getInterests() async {
    try {
      final response = await _apiService.dio.get('interests');
      // We will parse this in the UI or Helper, but better to return raw list here or List<Interest> if using models
      // For consistency with existing code style which uses Maps often, let's return List<dynamic>
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateProfile(String name, {String? bio, String? email}) async {
    try {
      final response = await _apiService.dio.put('auth/me', data: {
        'name': name,
        if (bio != null) 'bio': bio,
        if (email != null) 'email': email,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> uploadProfilePicture(String filePath) async {
    try {
      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _apiService.dio.post(
        'auth/upload-profile-picture', 
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> saveInterests(List<int> interestIds, [List<int>? subInterestIds]) async {
    try {
      await _apiService.dio.post('interests/user', data: {
        'interestIds': interestIds,
        'subInterestIds': subInterestIds ?? [],
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> changePassword({String? oldPassword, required String newPassword, String? otp}) async {
    try {
      final response = await _apiService.dio.post('auth/change-password', data: {
        if (oldPassword != null) 'oldPassword': oldPassword,
        'newPassword': newPassword,
        if (otp != null) 'otp': otp,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> sendOTP(String email, String type) async {
    try {
      await _apiService.dio.post('auth/send-otp', data: {
        'email': email,
        'type': type,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> verifyOTP(String email, String otp, String type) async {
    try {
      final response = await _apiService.dio.post('auth/verify-otp', data: {
        'email': email,
        'otp': otp,
        'type': type,
      });
      return response.data['success'] ?? false;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _apiService.dio.post('auth/forgot-password', data: {
        'email': email,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    try {
      await _apiService.dio.post('auth/reset-password', data: {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null && e.response!.data != null) {
      if (e.response!.data is Map && e.response!.data['msg'] != null) {
         return e.response!.data['msg'];
      }
      return e.response!.data.toString();
    } else {
      return e.message ?? 'Unknown error occurred';
    }
  }
}
