import 'package:dio/dio.dart';
import '../model/booking_model.dart';
import '../model/booking_history_model.dart';

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


  static Future<void> updateBookingStatus(
    int bookingId,
    String status, {
    int? employeeId,
  }) async {
    try {
      await _dio.put(
        '/bookings/$bookingId/status',
        data: {
          'status': status,
          if (employeeId != null) 'employee_id': employeeId,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to update booking status',
      );
    }
  }

  /// PUT /admin/cars/{car_id}/availability
  static Future<void> updateCarAvailability(int carId, bool isAvailable) async {
    try {
      await _dio.put(
        '/admin/cars/$carId/availability',
        data: {'status': isAvailable},
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to update car availability',
      );
    }
  }
}


  // =========================
  // POST /bookings/confirm
  // =========================
  static Future<void> confirmBooking({
    required int userId,
    required int carId,
    required String pickupLocation,
    required String dropoffLocation,
    required DateTime startDate,
    required DateTime endDate,
    required String paymentMethod,
  }) async {
    try {
      await _dio.post(
        '/bookings/confirm',
        data: {
          "user_id": userId,
          "car_id": carId,
          "pickup_location": pickupLocation,
          "dropoff_location": dropoffLocation,
          "start_date": startDate.toIso8601String().split('T').first,
          "end_date": endDate.toIso8601String().split('T').first,
          "payment_method": paymentMethod,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data ?? 'Failed to confirm booking',
      );
    }
  }


  /// GET /bookings/customer/{customer_id}
/// ترجع جميع الحجوزات الخاصة بالمستخدم
/// (pending / approved / completed / cancelled ...)
static Future<List<BookingHistoryItem>> getBookingHistory(
  int customerId,
) async {
  try {
    final res = await _dio.get('/bookings/customer/$customerId');

    final data = res.data as Map<String, dynamic>;
    final list = data['bookings'] as List;

    return list
        .map((e) => BookingHistoryItem.fromJson(e))
        .toList();
  } on DioException catch (e) {
    throw Exception(
      e.response?.data ?? 'Failed to load booking history',
    );
  }
}



}