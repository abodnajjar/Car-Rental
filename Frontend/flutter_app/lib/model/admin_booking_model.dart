class Booking {
  final int id;
  final int userId;
  final int? employeeId;
  final int carId;

  final String? pickupLocation;
  final String? dropoffLocation;

  final DateTime? startDate;
  final DateTime? endDate;

  final double? totalPrice;
  final String status;
  final DateTime? createdAt;

  Booking({
    required this.id,
    required this.userId,
    required this.employeeId,
    required this.carId,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      return double.tryParse(v.toString());
    }

    return Booking(
      id: json['id'],
      userId: json['user_id'],
      employeeId: json['employee_id'],
      carId: json['car_id'],
      pickupLocation: json['pickup_location'],
      dropoffLocation: json['dropoff_location'],
      startDate: parseDate(json['start_date']),
      endDate: parseDate(json['end_date']),
      totalPrice: parseDouble(json['total_price']),
      status: (json['status'] ?? 'pending').toString(),
      createdAt: parseDate(json['created_at']),
    );
  }
}
