import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ProfileApi {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl, // رابط السيرفر الحقيقي
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// جلب بيانات المستخدم بواسطة ID
  Future<Map<String, dynamic>> getProfile(int userId) async {
    try {
      final res = await _dio.get('/users/$userId'); // Endpoint في Backend
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      final msg = e.response?.data?["detail"]?.toString() ?? "Failed to fetch profile";
      throw Exception(msg);
    }
  }
}
