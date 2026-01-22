import 'package:dio/dio.dart';
import '../model/car_model.dart';

class CarsApi {
  static final Dio _dio = Dio(
    BaseOptions(baseUrl: "http://127.0.0.1:8000"),
  );

  static Future<List<Car>> getCars() async {
    final res = await _dio.get("/admin/cars");
    return (res.data as List)
        .map((e) => Car.fromJson(e))
        .toList();
  }

  static Future<void> deleteCar(int id) async {
    await _dio.delete("/admin/cars/$id");
  }

  static Future<void> addCar(Map<String, dynamic> data) async {
    await _dio.post("/admin/cars", data: data);
  }

  static Future<void> updateCar(int id, Map<String, dynamic> data) async {
    await _dio.put("/admin/cars/$id", data: data);
  }
}
