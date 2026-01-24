import 'package:dio/dio.dart';
import '../model/car_model.dart';

class CarsApi {
  static final Dio _dio = Dio(
    BaseOptions(baseUrl: "http://127.0.0.1:8000"),
  );

    static Future<List<Car>> getCars() async {
    final res = await _dio.get("/cars");
    return (res.data as List).map((e) => Car.fromJson(e)).toList();
  }

  static Future<void> deleteCar(int carId) async {
    await _dio.delete("/cars/$carId");
  }

    static Future<Car> addCar(Map<String, dynamic> data) async {
    final res = await _dio.post("/cars", data: data);
    return Car.fromJson(res.data);
  }

   static Future<Car> updateCar(int carId, Map<String, dynamic> data) async {
    final res = await _dio.put("/cars/$carId", data: data);
    return Car.fromJson(res.data);
  }
}
