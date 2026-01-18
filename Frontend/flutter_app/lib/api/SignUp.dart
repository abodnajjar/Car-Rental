import 'package:dio/dio.dart';

class AuthApi {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8000',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String phone,
    required String role, 
    required String password,
    String? drivingLicenseNo, 
    double? salary,
  }) async {
    final data = <String, dynamic>{
      "full_name": fullName,
      "email": email,
      "phone": phone,
      "role": role,
      "password": password,
    };

    if (role == "customer") {
      if (drivingLicenseNo != null && drivingLicenseNo.trim().isNotEmpty) {
        data["driving_license_no"] = drivingLicenseNo.trim();
      }
    }

    if (role == "employee") {
      if (salary == null) {
        throw Exception("Salary is required for employee signup");
      }
      data["salary"] = salary;
    }

    try {
      final res = await _dio.post('/auth/signup', data: data);
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
        final msg = e.response?.data?["detail"]?.toString()
      ?? "Signup failed";

  throw Exception(msg); 
    }
  }
}
