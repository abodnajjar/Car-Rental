import 'package:dio/dio.dart';
import '../model/employee_model.dart';

class EmployeesApi {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.32.193:8000',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<List<Employee>> getEmployees() async {
    try {
      final res = await _dio.get('/users/employees');

      print("STATUS CODE: ${res.statusCode}");
      print("RAW DATA: ${res.data}");

      final data = res.data as List;

      return data.map((e) => Employee.fromJson(e)).toList();
    } on DioException catch (e) {
      print("DIO ERROR: ${e.response?.statusCode}");
      print("DIO DATA: ${e.response?.data}");
      throw Exception("Failed to load employees");
    }
  }
}
