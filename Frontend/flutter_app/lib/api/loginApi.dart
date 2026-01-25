import 'package:dio/dio.dart';
import '../config/api_config.dart';

class LoginApi {
  final Dio _dio = Dio(
    BaseOptions(
       baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = {"email": email, "password": password};

    try {
      final res = await _dio.post('/auth/login', data: data);


      return Map<String, dynamic>.from(res.data);
    }  on DioException catch (e) {
  print("STATUS: ${e.response?.statusCode}");
  print("DATA: ${e.response?.data}");
  print("MESSAGE: ${e.message}");
  print("TYPE: ${e.type}");
  throw Exception(e.response?.data.toString() ?? e.message ?? "Login failed");
}

  }
}