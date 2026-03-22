import 'dart:io';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/sticker_model.dart';
import '../services/auth_service.dart';

class StickerService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiService.baseUrl));
  final AuthService _authService = AuthService();

  Future<List<StickerModel>> getPublicStickers() async {
    try {
      final response = await _dio.get('/stickers');
      return (response.data as List).map((s) => StickerModel.fromJson(s)).toList();
    } catch (e) {
      throw Exception('Failed to load public stickers');
    }
  }

  Future<List<StickerModel>> getMyStickers() async {
    try {
      final token = await _authService.getToken();
      final response = await _dio.get('/stickers/my', options: Options(
        headers: {'Authorization': 'Bearer $token'}
      ));
      return (response.data as List).map((s) => StickerModel.fromJson(s)).toList();
    } catch (e) {
      throw Exception('Failed to load my stickers');
    }
  }

  Future<List<StickerModel>> searchStickers(String query) async {
    try {
      final response = await _dio.get('/stickers/search', queryParameters: {'q': query});
      return (response.data as List).map((s) => StickerModel.fromJson(s)).toList();
    } catch (e) {
      throw Exception('Failed to search stickers');
    }
  }

  Future<StickerModel> createSticker({
    required String name,
    required bool isPublic,
    required File imageFile,
  }) async {
    try {
      final token = await _authService.getToken();
      
      FormData formData = FormData.fromMap({
        'name': name,
        'is_public': isPublic.toString(),
        'image': await MultipartFile.fromFile(imageFile.path, filename: 'sticker.png'),
      });

      final response = await _dio.post(
        '/stickers',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return StickerModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create sticker');
    }
  }
}
