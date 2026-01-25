import 'package:dio/dio.dart';
import '../model/admin_booking_model.dart';

class BookingsApi {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000", // Emulator Android
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static Future<List<Booking>> getAllBookings() async {
    final res = await _dio.get("/admin/bookings");

    final data = res.data as List;
    return data.map((e) => Booking.fromJson(e)).toList();
  }
}
