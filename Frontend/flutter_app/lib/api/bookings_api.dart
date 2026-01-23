import 'package:dio/dio.dart';
import '../model/booking_model.dart';

class BookingsApi {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// GET /bookings/pending
  static Future<List<PendingBooking>> getPendingBookings() async {
    try {
      final res = await _dio.get('/bookings/pending');

      return (res.data as List)
          .map((e) => PendingBooking.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to load pending bookings',
      );
    }
  }

  /// GET /bookings/status/{status}
  /// status: pending | accepted | rejected | approved | active | completed | cancelled
  static Future<List<PendingBooking>> getBookingsByStatus(String status) async {
    try {
      final res = await _dio.get('/bookings/status/$status');

      return (res.data as List)
          .map((e) => PendingBooking.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to load bookings',
      );
    }
  }

  /// GET /bookings/details/{booking_id}
  static Future<BookingDetails> getBookingDetails(int bookingId) async {
    try {
      final res = await _dio.get('/bookings/details/$bookingId');
      return BookingDetails.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to load booking details',
      );
    }
  }

  /// PUT /bookings/{booking_id}/status
  /// status: "approved" or "cancelled"
  static Future<void> updateBookingStatus(int bookingId, String status) async {
    try {
      await _dio.put(
        '/bookings/$bookingId/status',
        data: {'status': status},
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to update booking status',
      );
    }
  }
}
