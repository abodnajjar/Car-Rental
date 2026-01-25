import 'package:dio/dio.dart';
import '../config/api_config.dart';

class Editprofileapi {
  final Dio _dio = Dio(
    BaseOptions(

      baseUrl: 'http://127.0.0.1:8000'
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<Map<String, dynamic>> getProfile(int userId) async {
    try {
      final res = await _dio.get('/users/$userId');
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      final msg =
          e.response?.data?['detail']?.toString() ?? 'Failed to load profile';
      throw Exception(msg);
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String role,

    String? fullName,
    String? email,
    String? phone,

    int? salary,
  }) async {
    final Map<String, dynamic> data = {};

    if (fullName != null) data['full_name'] = fullName;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;

    if (role == 'employee') {
      if (salary != null) {
        data['salary'] = salary;
      }
    }

    try {
      final res = await _dio.put('/users/$userId', data: data);
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      final msg =
          e.response?.data?['detail']?.toString() ?? 'Failed to update profile';
      throw Exception(msg);
    }
  }
}
