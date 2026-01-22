import 'package:dio/dio.dart';
import '../model/car_price_model.dart';

class CarPricesApi {
  static final Dio _dio = Dio(
    BaseOptions(baseUrl: "http://127.0.0.1:8000"),
  );

  // ===============================
  // GET prices for one car
  // ===============================
  static Future<List<CarPrice>> getCarPrices(int carId) async {
    final res = await _dio.get("/admin/cars/$carId/prices");

    return (res.data as List)
        .map((e) => CarPrice.fromJson(e))
        .toList();
  }

  // ===============================
  // UPDATE price (existing)
  // ===============================
  static Future<void> updateCarPrice({
    required int carId,
    required String day,
    required double price,
  }) async {
    await _dio.put(
      "/admin/cars/$carId/prices",
      data: {
        "day": day,
        "price": price,
      },
    );
  }
}
