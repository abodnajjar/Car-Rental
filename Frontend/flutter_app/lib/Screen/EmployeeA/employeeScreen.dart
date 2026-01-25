import 'package:flutter/material.dart';
import '../profileScreen.dart';
import '../../api/bookings_api.dart';
import '../../api/cars_api.dart';
import '../../config/api_config.dart';
import '../../model/booking_model.dart';
import '../../model/car_model.dart';
import 'employee_booking_details_screen.dart';
import '../../mock/mock_booking_data.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  int _currentIndex = 0;
  bool _isLoading = false;
  String? _error;
  List<PendingBooking> _bookings = [];

  bool _carsLoading = false;
  String? _carsError;
  List<Car> _cars = [];
  List<Car> _filteredCars = [];
  String _carSearch = '';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  bool get _isBookingTab => _currentIndex <= 2;

  String get _currentStatus {
    if (!_isBookingTab) return 'pending';
    switch (_currentIndex) {
      case 1:
        return 'accepted';
      case 2:
        return 'rejected';
      default:
        return 'pending';
    }
  }

  Future<void> _loadBookings() async {
    if (!_isBookingTab) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (kUseMockData) {
        final bookings = MockBookingData.employeeBookings();
        final filtered = _filterBookings(bookings, _currentStatus);
        setState(() {
          _bookings = filtered;
          _isLoading = false;
        });
        return;
      }

      final bookings = await BookingsApi.getBookingsByStatus(_currentStatus);
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCars() async {
    setState(() {
      _carsLoading = true;
      _carsError = null;
    });

    try {
      final cars = await CarsApi.getCars();
      setState(() {
        _cars = List<Car>.from(cars);
        _filteredCars = _applyCarFilter(_carSearch, cars);
        _carsLoading = false;
      });
    } catch (e) {
      setState(() {
        _carsError = e.toString();
        _carsLoading = false;
      });
    }
  }

  List<Car> _applyCarFilter(String query, List<Car> source) {
    if (query.trim().isEmpty) return List<Car>.from(source);

    final q = query.toLowerCase();
    return source.where((c) {
      return c.brand.toLowerCase().contains(q) ||
          c.model.toLowerCase().contains(q) ||
          c.category.toLowerCase().contains(q);
    }).toList();
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
  }

  Future<void> _navigateToDetails(int bookingId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EmployeeBookingDetailsScreen(bookingId: bookingId),
      ),
    );

    if (mounted) {
      if (result is Map) {
        final status = result['status']?.toString().toLowerCase();
        final targetIndex = _indexForStatus(status);
        if (targetIndex != null && targetIndex != _currentIndex) {
          setState(() {
            _currentIndex = targetIndex;
          });
        }
      }
      _loadBookings();
    }
  }

  int? _indexForStatus(String? status) {
    if (status == null) return null;
    switch (status) {
      case 'approved':
      case 'accepted':
      case 'active':
      case 'completed':
        return 1;
      case 'cancelled':
      case 'canceled':
      case 'rejected':
        return 2;
      case 'pending':
        return 0;
      default:
        return null;
    }
  }

  void _onNavTap(int index) {
    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
      return;
    }

    setState(() {
      _currentIndex = index;
    });
    if (_isBookingTab) {
      _loadBookings();
    } else {
      _loadCars();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/carRental.png", height: 100),
        title: const Text(
          'CarRental',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[350],
              child: IconButton(
                icon: const Icon(Icons.person),
                color: Colors.white,
                iconSize: 28,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
        toolbarHeight: 100,
        backgroundColor: Colors.white,
      ),
      body: Container(color: Colors.grey[200], child: _buildBody()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'Pending',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Accepted',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.cancel), label: 'Rejected'),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Cars',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (!_isBookingTab) {
      return _buildCarsBody();
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBookings,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _employeeHeader(),
        _statusHeader(),
        Expanded(child: _buildBookingsList()),
      ],
    );
  }

  Widget _employeeHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.badge, color: Colors.blue.shade700, size: 28),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Employee Dashboard',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Review bookings and keep customers updated',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusHeader() {
    final label = _currentStatus[0].toUpperCase() + _currentStatus.substring(1);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Icon(
            _currentStatus == 'pending'
                ? Icons.pending_actions
                : _currentStatus == 'accepted'
                ? Icons.check_circle
                : Icons.cancel,
            color: _currentStatus == 'pending'
                ? Colors.orange
                : _currentStatus == 'accepted'
                ? Colors.green
                : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            '$label bookings',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            '${_bookings.length} items',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList() {
    if (_bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadBookings,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 60),
            Icon(Icons.inbox_outlined, color: Colors.grey.shade400, size: 72),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'No $_currentStatus bookings',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _currentStatus == 'pending'
                    ? 'All bookings have been processed.'
                    : 'New updates will appear here.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          return _buildBookingCard(_bookings[index]);
        },
      ),
    );
  }

  Widget _buildCarsBody() {
    return Column(
      children: [
        _employeeHeader(),
        _carsHeader(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadCars,
            child: _carsLoading
                ? const Center(child: CircularProgressIndicator())
                : _carsError != null
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 40),
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(_carsError!, textAlign: TextAlign.center),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadCars,
                        child: const Text('Retry'),
                      ),
                    ],
                  )
                : _filteredCars.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    children: const [
                      SizedBox(height: 40),
                      Icon(Icons.directions_car, color: Colors.grey, size: 64),
                      SizedBox(height: 12),
                      Center(
                        child: Text(
                          'No cars found for this search.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredCars.length,
                    itemBuilder: (context, index) {
                      return _buildCarCard(_filteredCars[index]);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  List<PendingBooking> _filterBookings(
    List<PendingBooking> bookings,
    String status,
  ) {
    final normalized = status.toLowerCase();
    return bookings.where((booking) {
      final bStatus = booking.bookingStatus.toLowerCase().trim();
      if (normalized == 'accepted') {
        return bStatus == 'approved' ||
            bStatus == 'accepted' ||
            bStatus == 'active' ||
            bStatus == 'completed';
      }
      if (normalized == 'rejected') {
        return bStatus == 'cancelled' || bStatus == 'rejected';
      }
      return bStatus == 'pending';
    }).toList();
  }

  Widget _carsHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_car, color: Colors.blue),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'All Cars',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${_filteredCars.length} items',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by brand, model, or category',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (v) {
              setState(() {
                _carSearch = v;
                _filteredCars = _applyCarFilter(v, _cars);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCarCard(Car car) {
    final price = _minPrice(car);
    final isAvailable = car.status;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 110,
                height: 80,
                child: car.imageUrl.isNotEmpty
                    ? Image.network(
                        _buildImageUrl(car.imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.directions_car,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${car.brand} ${car.model}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? Colors.green.withOpacity(0.12)
                              : Colors.red.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isAvailable ? 'Available' : 'Unavailable',
                          style: TextStyle(
                            color: isAvailable ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${car.category} • ${car.year}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  if (price != null)
                    Text(
                      '${price.toStringAsFixed(0)} NIS / day',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  if (price == null)
                    const Text(
                      'Price not set',
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double? _minPrice(Car car) {
    if (car.prices.isEmpty) return null;
    double minPrice = car.prices.first.price;
    for (final p in car.prices) {
      if (p.price < minPrice) minPrice = p.price;
    }
    return minPrice;
  }

  String _buildImageUrl(String img) {
    var v = img.trim();
    if (v.isEmpty) return "";

    if (v.startsWith("http")) return v;

    if (v.startsWith("/uploads")) {
      return "${ApiConfig.baseUrl}$v";
    }

    return "${ApiConfig.baseUrl}/uploads/cars/$v";
  }

  Widget _buildBookingCard(PendingBooking booking) {
    final days = booking.endDate.difference(booking.startDate).inDays;
    final statusLabel = _statusLabel(booking.bookingStatus);
    final statusColor = _statusColor(booking.bookingStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _navigateToDetails(booking.bookingId),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _carThumbnail(booking.imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Booking #${booking.bookingId}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 18),
                    _infoRow(
                      Icons.calendar_today,
                      'Start',
                      _formatDate(booking.startDate),
                    ),
                    _infoRow(
                      Icons.event_available,
                      'End',
                      _formatDate(booking.endDate),
                    ),
                    _infoRow(Icons.access_time, 'Duration', '$days days'),
                    _infoRow(
                      Icons.attach_money,
                      'Total',
                      '\$${booking.totalPrice.toStringAsFixed(2)}',
                    ),
                    if (booking.pickupLocation != null)
                      _infoRow(
                        Icons.location_on,
                        'Pickup',
                        booking.pickupLocation!,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () =>
                              _navigateToDetails(booking.bookingId),
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('View Details'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _carThumbnail(String? imageUrl) {
    final borderRadius = BorderRadius.circular(12);

    String buildImageUrl(String img) {
      var v = img.trim();
      if (v.isEmpty) return "";

      if (v.startsWith("http")) return v;

      if (v.startsWith("/uploads")) {
        return "${ApiConfig.baseUrl}$v";
      }

      return "${ApiConfig.baseUrl}/uploads/cars/$v";
    }

    final imgUrl = (imageUrl == null || imageUrl.isEmpty)
        ? ""
        : buildImageUrl(imageUrl);

    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: 110,
        height: 90,
        color: Colors.grey.shade300,
        child: imgUrl.isNotEmpty
            ? Image.network(
                imgUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.directions_car,
                      size: 40,
                      color: Colors.white,
                    ),
                  );
                },
              )
            : const Center(
                child: Icon(
                  Icons.directions_car,
                  size: 40,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase().trim()) {
      case 'approved':
      case 'accepted':
      case 'active':
      case 'completed':
        return 'Accepted';
      case 'cancelled':
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'approved':
      case 'accepted':
      case 'active':
      case 'completed':
        return Colors.green;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
