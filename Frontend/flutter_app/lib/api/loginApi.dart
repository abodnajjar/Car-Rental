import 'package:dio/dio.dart';

class LoginApi {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8000', // ضع هنا رابط السيرفر الحقيقي
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Login
  /// Returns a Map with user info if success
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = {"email": email, "password": password};

    try {
      final res = await _dio.post('/auth/login', data: data);

      // نجاح تسجيل الدخول، يرجع JSON يحتوي على:
      // id, full_name, role, token
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      // إذا كان هناك response من السيرفر
      final msg = e.response?.data?["detail"]?.toString() ?? "Login failed";
      throw Exception(msg);
    }
  }
}
