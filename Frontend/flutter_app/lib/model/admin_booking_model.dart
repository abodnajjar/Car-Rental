class AdminBooking {
  final int bookingId;
  final int userId;
  final int carId;

  final String carBrand;
  final String carModel;
  final String customerName;

  final String? imageUrl;
  final String? pickupLocation;
  final String? dropoffLocation;

  final DateTime startDate;
  final DateTime endDate;

  final double totalPrice;
  final String status;
  final DateTime createdAt;

  AdminBooking({
    required this.bookingId,
    required this.userId,
    required this.carId,
    required this.carBrand,
    required this.carModel,
    required this.customerName,
    this.imageUrl,
    this.pickupLocation,
    this.dropoffLocation,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  factory AdminBooking.fromJson(Map<String, dynamic> json) {
    return AdminBooking(
      bookingId: json['booking_id'],
      userId: json['user_id'],
      carId: json['car_id'],
      carBrand: json['car_brand'],
      carModel: json['car_model'],
      customerName: json['customer_name'],
      imageUrl: json['image_url'],
      pickupLocation: json['pickup_location'],
      dropoffLocation: json['dropoff_location'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalPrice: (json['total_price'] as num).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // 🔥 Helper properties للتقسيم حسب التاريخ
  bool get isUpcoming => startDate.isAfter(DateTime.now());

  bool get isActive =>
      startDate.isBefore(DateTime.now()) &&
      endDate.isAfter(DateTime.now());

  bool get isCompleted => endDate.isBefore(DateTime.now());
}
