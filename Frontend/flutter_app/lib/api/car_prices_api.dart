import 'package:dio/dio.dart';
import '../model/car_price_model.dart';

class CarPricesApi {
  static final Dio _dio = Dio(

    BaseOptions(
      baseUrl: "http://127.0.0.1:8000",
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {"Content-Type": "application/json"},
    )

  );


  static Future<List<CarPrice>> getCarPrices(int carId) async {
    try {
      final res =
          await _dio.get("/admin/cars/$carId/prices");

      if (res.statusCode == 200) {
        return (res.data as List)
            .map((e) => CarPrice.fromJson(e))
            .toList();
      } else {
        throw Exception("Failed to load prices");
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["detail"] ??
            "Error loading prices",
      );
    }
  }

  static Future<void> updateCarPrice({
    required int carId,
    required String day,
    required double price,
  }) async {
    try {
      final res = await _dio.put(
        "/admin/cars/$carId/prices",
        data: {
          "day": day,
          "price": price,
        },
      );

      if (res.statusCode != 200) {
        throw Exception("Failed to update price");
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["detail"] ??
            "Error updating price",
      );
    }
  }

  static Future<void> updateAllPrices({
    required int carId,
    required List<Map<String, dynamic>> prices,
  }) async {
    try {
      final res = await _dio.put(
        "/cars/$carId",
        data: {
          "prices": prices,
        },
      );

      if (res.statusCode != 200) {
        throw Exception("Failed to update prices");
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["detail"] ??
            "Error updating prices",
      );
    }
  }
}
