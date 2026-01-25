import '../model/booking_model.dart';

const bool kUseMockData = false;

class MockBookingData {
  static final DateTime _seedNow = DateTime.now();

  static final List<PendingBooking> _employeeBookings = [
    PendingBooking(
      bookingId: 101,
      userId: 12,
      carId: 7,
      imageUrl:
          'https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=900&q=80',
      pickupLocation: 'Downtown Branch',
      dropoffLocation: 'Airport Terminal',
      startDate: _seedNow.add(const Duration(days: 1)),
      endDate: _seedNow.add(const Duration(days: 4)),
      totalPrice: 285.00,
      bookingStatus: 'pending',
      createdAt: _seedNow.subtract(const Duration(hours: 3)),
    ),
    PendingBooking(
      bookingId: 102,
      userId: 18,
      carId: 3,
      imageUrl:
          'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=900&q=80',
      pickupLocation: 'City Mall',
      dropoffLocation: 'City Mall',
      startDate: _seedNow.add(const Duration(days: 2)),
      endDate: _seedNow.add(const Duration(days: 5)),
      totalPrice: 210.50,
      bookingStatus: 'approved',
      createdAt: _seedNow.subtract(const Duration(hours: 7)),
    ),
    PendingBooking(
      bookingId: 103,
      userId: 25,
      carId: 11,
      imageUrl:
          'https://images.unsplash.com/photo-1493238792000-8113da705763?auto=format&fit=crop&w=900&q=80',
      pickupLocation: 'Main Station',
      dropoffLocation: 'Hotel District',
      startDate: _seedNow.add(const Duration(days: 3)),
      endDate: _seedNow.add(const Duration(days: 6)),
      totalPrice: 360.00,
      bookingStatus: 'cancelled',
      createdAt: _seedNow.subtract(const Duration(days: 1, hours: 2)),
    ),
  ];

  static final Map<int, BookingDetails> _detailsById = {
    101: BookingDetails(
      bookingId: 101,
      carId: 7,
      customer: CustomerInfo(
        fullName: 'Sara Johnson',
        email: 'sara.johnson@example.com',
        phone: '+1 202 555 0136',
        drivingLicenseNo: 'D-104-889-22',
      ),
      car: CarInfo(
        brand: 'BMW',
        model: 'X5',
        category: 'SUV',
        year: 2023,
        carStatus: true,
        imageUrl:
            'https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=1200&q=80',
      ),
      pickupLocation: 'Downtown Branch',
      dropoffLocation: 'Airport Terminal',
      startDate: _seedNow.add(const Duration(days: 1)),
      endDate: _seedNow.add(const Duration(days: 4)),
      totalPrice: 285.00,
      bookingStatus: 'pending',
    ),
    102: BookingDetails(
      bookingId: 102,
      carId: 3,
      customer: CustomerInfo(
        fullName: 'Ali Ahmed',
        email: 'ali.ahmed@example.com',
        phone: '+1 202 555 0198',
        drivingLicenseNo: 'A-558-992-10',
      ),
      car: CarInfo(
        brand: 'Toyota',
        model: 'Corolla',
        category: 'Sedan',
        year: 2022,
        carStatus: true,
        imageUrl:
            'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1200&q=80',
      ),
      pickupLocation: 'City Mall',
      dropoffLocation: 'City Mall',
      startDate: _seedNow.add(const Duration(days: 2)),
      endDate: _seedNow.add(const Duration(days: 5)),
      totalPrice: 210.50,
      bookingStatus: 'approved',
    ),
    103: BookingDetails(
      bookingId: 103,
      carId: 11,
      customer: CustomerInfo(
        fullName: 'Emily Chen',
        email: 'emily.chen@example.com',
        phone: '+1 202 555 0177',
        drivingLicenseNo: 'C-221-774-55',
      ),
      car: CarInfo(
        brand: 'Tesla',
        model: 'Model 3',
        category: 'Electric',
        year: 2024,
        carStatus: false,
        imageUrl:
            'https://images.unsplash.com/photo-1493238792000-8113da705763?auto=format&fit=crop&w=1200&q=80',
      ),
      pickupLocation: 'Main Station',
      dropoffLocation: 'Hotel District',
      startDate: _seedNow.add(const Duration(days: 3)),
      endDate: _seedNow.add(const Duration(days: 6)),
      totalPrice: 360.00,
      bookingStatus: 'cancelled',
    ),
  };

  static List<PendingBooking> employeeBookings() {
    return List<PendingBooking>.from(_employeeBookings);
  }

  static BookingDetails? bookingDetailsById(int bookingId) {
    return _detailsById[bookingId];
  }

  static void updateBookingStatus(int bookingId, String status) {
    final index =
        _employeeBookings.indexWhere((booking) => booking.bookingId == bookingId);
    if (index != -1) {
      final current = _employeeBookings[index];
      _employeeBookings[index] = PendingBooking(
        bookingId: current.bookingId,
        userId: current.userId,
        carId: current.carId,
        imageUrl: current.imageUrl,
        pickupLocation: current.pickupLocation,
        dropoffLocation: current.dropoffLocation,
        startDate: current.startDate,
        endDate: current.endDate,
        totalPrice: current.totalPrice,
        bookingStatus: status,
        createdAt: current.createdAt,
      );
    }

    final detail = _detailsById[bookingId];
    if (detail != null) {
      _detailsById[bookingId] = BookingDetails(
        bookingId: detail.bookingId,
        carId: detail.carId,
        customer: detail.customer,
        car: detail.car,
        pickupLocation: detail.pickupLocation,
        dropoffLocation: detail.dropoffLocation,
        startDate: detail.startDate,
        endDate: detail.endDate,
        totalPrice: detail.totalPrice,
        bookingStatus: status,
      );
    }
  }

  static void updateCarAvailability(int carId, bool isAvailable) {
    for (var i = 0; i < _employeeBookings.length; i++) {
      final booking = _employeeBookings[i];
      if (booking.carId == carId) {
        _employeeBookings[i] = PendingBooking(
          bookingId: booking.bookingId,
          userId: booking.userId,
          carId: booking.carId,
          imageUrl: booking.imageUrl,
          pickupLocation: booking.pickupLocation,
          dropoffLocation: booking.dropoffLocation,
          startDate: booking.startDate,
          endDate: booking.endDate,
          totalPrice: booking.totalPrice,
          bookingStatus: booking.bookingStatus,
          createdAt: booking.createdAt,
        );
      }
    }

    _detailsById.updateAll((key, detail) {
      if (detail.carId != carId) return detail;
      return BookingDetails(
        bookingId: detail.bookingId,
        carId: detail.carId,
        customer: detail.customer,
        car: CarInfo(
          brand: detail.car.brand,
          model: detail.car.model,
          category: detail.car.category,
          year: detail.car.year,
          carStatus: isAvailable,
          imageUrl: detail.car.imageUrl,
        ),
        pickupLocation: detail.pickupLocation,
        dropoffLocation: detail.dropoffLocation,
        startDate: detail.startDate,
        endDate: detail.endDate,
        totalPrice: detail.totalPrice,
        bookingStatus: detail.bookingStatus,
      );
    });
  }
}
