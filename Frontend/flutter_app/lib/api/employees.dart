import 'package:dio/dio.dart';
import '../model/employee_model.dart';

class EmployeesApi {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<List<Employee>> getEmployees() async {
    try {
      final res = await _dio.get('/users/employees');

      return (res.data as List)
          .map((e) => Employee.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to load employees',
      );
    }
  }

  static Future<Employee> getEmployeeById(String uid) async {
    try {
      final res = await _dio.get('/users/$uid');
      return Employee.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to load employee',
      );
    }
  }

  static Future<Employee> updateEmployeeSalary({
    required String uid,
    required double salary,
  }) async {
    try {
      final res = await _dio.put(
        '/users/$uid',
        data: {
          "salary": salary,
        },
      );

      return Employee.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to update salary',
      );
    }
  }

  static Future<void> deleteEmployee(String uid) async {
    try {
      await _dio.delete('/users/$uid');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to delete employee',
      );
    }
  }
}
