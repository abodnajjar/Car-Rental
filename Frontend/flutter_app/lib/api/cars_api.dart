import 'package:dio/dio.dart';
import 'dart:typed_data';
import '../model/car_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CarsApi {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl:"http://127.0.0.1:8000",
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {"Content-Type": "application/json"},
    ),
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
 static Future<void> uploadCarImage(
    int carId, {
    required String fileName,
    Uint8List? bytes,   // web
    String? filePath,   // mobile
  }) async {
    MultipartFile file;

    if (kIsWeb) {
      if (bytes == null) throw Exception("Image bytes are missing");
      file = MultipartFile.fromBytes(bytes, filename: fileName);
    } else {
      if (filePath == null) throw Exception("Image path is missing");
      file = await MultipartFile.fromFile(filePath, filename: fileName);
    }

    final form = FormData.fromMap({"image": file});
    await _dio.post("/cars/$carId/image", data: form);
  }
   static Future<Car> updateCar(int carId, Map<String, dynamic> data) async {
    final res = await _dio.put("/cars/$carId", data: data);
    return Car.fromJson(res.data);
  }
}
