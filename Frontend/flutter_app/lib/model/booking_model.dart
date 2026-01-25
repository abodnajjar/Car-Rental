class PendingBooking {
  final int bookingId;
  final int userId;
  final int carId;
  final String? imageUrl;
  final String? pickupLocation;
  final String? dropoffLocation;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String bookingStatus;
  final DateTime createdAt;

  PendingBooking({
    required this.bookingId,
    required this.userId,
    required this.carId,
    this.imageUrl,
    this.pickupLocation,
    this.dropoffLocation,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.bookingStatus,
    required this.createdAt,
  });

  factory PendingBooking.fromJson(Map<String, dynamic> json) {
    return PendingBooking(
      bookingId: json['booking_id'],
      userId: json['user_id'],
      carId: json['car_id'],
      imageUrl: json['image_url'],
      pickupLocation: json['pickup_location'],
      dropoffLocation: json['dropoff_location'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalPrice: (json['total_price'] as num).toDouble(),
      bookingStatus: json['booking_status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class CustomerInfo {
  final String fullName;
  final String email;
  final String phone;
  final String? drivingLicenseNo;

  CustomerInfo({
    required this.fullName,
    required this.email,
    required this.phone,
    this.drivingLicenseNo,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      drivingLicenseNo: json['driving_license_no'],
    );
  }
}

class CarInfo {
  final String brand;
  final String model;
  final String category;
  final int year;
  final bool carStatus;
  final String? imageUrl;

  CarInfo({
    required this.brand,
    required this.model,
    required this.category,
    required this.year,
    required this.carStatus,
    this.imageUrl,
  });

  factory CarInfo.fromJson(Map<String, dynamic> json) {
    return CarInfo(
      brand: json['brand'],
      model: json['model'],
      category: json['category'],
      year: json['year'],
      carStatus: json['car_status'],
      imageUrl: json['image_url'],
    );
  }
}

class BookingDetails {
  final int bookingId;
  final int carId;
  final CustomerInfo customer;
  final CarInfo car;
  final String? pickupLocation;
  final String? dropoffLocation;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String bookingStatus;

  BookingDetails({
    required this.bookingId,
    required this.carId,
    required this.customer,
    required this.car,
    this.pickupLocation,
    this.dropoffLocation,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.bookingStatus,
  });

  factory BookingDetails.fromJson(Map<String, dynamic> json) {
    return BookingDetails(
      bookingId: json['booking_id'],
      carId: json['car_id'],
      customer: CustomerInfo.fromJson(json['customer']),
      car: CarInfo.fromJson(json['car']),
      pickupLocation: json['pickup_location'],
      dropoffLocation: json['dropoff_location'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalPrice: (json['total_price'] as num).toDouble(),
      bookingStatus: json['booking_status'],
    );
  }
}
