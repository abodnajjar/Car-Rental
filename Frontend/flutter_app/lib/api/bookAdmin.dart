import 'package:dio/dio.dart';
import '../model/admin_booking_model.dart';

class BookAdminApi {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:8000",
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {"Content-Type": "application/json"},
    ),
  );

  // ===============================
  // GET ALL BOOKINGS (Admin View)
  // ===============================
  static Future<List<AdminBooking>> getAllBookings() async {
    try {
      final res = await _dio.get("/bookings");

      return (res.data as List)
          .map((e) => AdminBooking.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to load bookings',
      );
    }
  }

  // ===============================
  // GET BOOKING DETAILS
  // ===============================
  static Future<AdminBooking> getBookingDetails(int bookingId) async {
    try {
      final res =
          await _dio.get("/bookings/details/$bookingId");

      return AdminBooking.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ??
            'Failed to load booking details',
      );
    }
  }

  // ===============================
  // UPDATE BOOKING STATUS
  // ===============================
  static Future<void> updateBookingStatus(
      int bookingId, String status) async {
    try {
      await _dio.put(
        "/bookings/$bookingId/status",
        data: {"status": status},
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ??
            'Failed to update booking status',
      );
    }
  }

  // ===============================
  // DELETE BOOKING (Optional)
  // ===============================
  static Future<void> deleteBooking(int bookingId) async {
    try {
      await _dio.delete("/bookings/$bookingId");
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ??
            'Failed to delete booking',
      );
    }
  }
}
