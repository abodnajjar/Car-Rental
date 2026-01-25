import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../model/booking_history_model.dart';
import '../model/booking_model.dart';

class BookingsApi {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// POST /bookings/price
  static Future<Map<String, dynamic>> calculatePrice({
    required int userId,
    required int carId,
    required String pickupLocation,
    required String dropoffLocation,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final res = await _dio.post(
        '/bookings/price',
        data: {
          'user_id': userId,
          'car_id': carId,
          'pickup_location': pickupLocation,
          'dropoff_location': dropoffLocation,
          'start_date': startDate.toIso8601String().split('T').first,
          'end_date': endDate.toIso8601String().split('T').first,
        },
      );
      return Map<String, dynamic>.from(res.data as Map);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to calculate price',
      );
    }
  }

  /// POST /bookings/confirm
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
          'user_id': userId,
          'car_id': carId,
          'pickup_location': pickupLocation,
          'dropoff_location': dropoffLocation,
          'start_date': startDate.toIso8601String().split('T').first,
          'end_date': endDate.toIso8601String().split('T').first,
          'payment_method': paymentMethod,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to confirm booking',
      );
    }
  }

  /// GET /bookings/customer/{customer_id}
  static Future<List<BookingHistoryItem>> getBookingHistory(int customerId) async {
    try {
      final res = await _dio.get('/bookings/customer/$customerId');
      final data = Map<String, dynamic>.from(res.data as Map);
      final list = (data['bookings'] as List? ?? []);
      return list.map((e) => BookingHistoryItem.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to load booking history',
      );
    }
  }

  /// GET /bookings/pending
  static Future<List<PendingBooking>> getPendingBookings() async {
    try {
      final res = await _dio.get('/bookings/pending');
      return (res.data as List).map((e) => PendingBooking.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to load pending bookings',
      );
    }
  }

  /// GET /bookings/status/{status}
  static Future<List<PendingBooking>> getBookingsByStatus(String status) async {
    try {
      final res = await _dio.get('/bookings/status/$status');
      return (res.data as List).map((e) => PendingBooking.fromJson(e)).toList();
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

  /// PUT /cars/{car_id}/availability
  static Future<void> updateCarAvailability(int carId, bool isAvailable) async {
    try {
      await _dio.put(
        '/cars/$carId/availability',
        data: {'status': isAvailable},
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to update car availability',
      );
    }
  }
}
