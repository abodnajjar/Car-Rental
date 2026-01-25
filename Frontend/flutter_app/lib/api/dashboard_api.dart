import 'package:dio/dio.dart';
import '../config/api_config.dart';

class DashboardApi {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get("/dashboard");

      return response.data;
    } catch (e) {
      throw Exception("Failed to load dashboard data");
    }
  }
}