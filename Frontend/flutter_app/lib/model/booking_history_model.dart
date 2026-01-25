class BookingHistoryItem {
  final String brand;
  final String model;
  final String category;
  final bool carStatus;
  final String? imageUrl;
  final String? pickupLocation;
  final String? dropoffLocation;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String bookingStatus;

  BookingHistoryItem({
    required this.brand,
    required this.model,
    required this.category,
    required this.carStatus,
    this.imageUrl,
    this.pickupLocation,
    this.dropoffLocation,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.bookingStatus,
  });

  factory BookingHistoryItem.fromJson(Map<String, dynamic> json) {
    return BookingHistoryItem(
      brand: json['brand'],
      model: json['model'],
      category: json['category'],
      carStatus: json['car_status'],
      imageUrl: json['image_url'],
      pickupLocation: json['pickup_location'],
      dropoffLocation: json['dropoff_location'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalPrice: (json['total_price'] as num).toDouble(),
      bookingStatus: json['booking_status'],
    );
  }
}
