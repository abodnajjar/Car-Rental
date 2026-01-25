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

  /// =========================
  /// GET profile by user id
  /// =========================
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

  /// =========================
  /// UPDATE profile
  /// =========================
  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String role,

    // common
    String? fullName,
    String? email,
    String? phone,

    // employee only
    int? salary,
  }) async {
    final Map<String, dynamic> data = {};

    // fields for all
    if (fullName != null) data['full_name'] = fullName;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;

    // employee extra fields
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
