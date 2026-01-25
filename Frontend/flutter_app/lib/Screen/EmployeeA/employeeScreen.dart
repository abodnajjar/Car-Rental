import 'package:flutter/material.dart';
import '../profileScreen.dart';
import '../../api/bookings_api.dart';
import '../../api/cars_api.dart';
import '../../model/booking_model.dart';
import '../../model/car_model.dart';
import 'employee_booking_details_screen.dart';
import '../../mock/mock_booking_data.dart';
import 'widgets/employee_header_widget.dart';
import 'widgets/status_header_widget.dart';
import 'widgets/cars_header_widget.dart';
import 'widgets/booking_card_widget.dart';
import 'widgets/car_card_widget.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/error_state_widget.dart';

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
      return ErrorStateWidget(
        error: _error!,
        onRetry: _loadBookings,
      );
    }

    return Column(
      children: [
        const EmployeeHeaderWidget(),
        StatusHeaderWidget(
          currentStatus: _currentStatus,
          itemCount: _bookings.length,
        ),
        Expanded(
          child: _buildBookingsList(),
        ),
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
      return EmptyStateWidget(
        icon: Icons.inbox_outlined,
        title: 'No $_currentStatus bookings',
        subtitle: _currentStatus == 'pending'
            ? 'All bookings have been processed.'
            : 'New updates will appear here.',
        onRefresh: _loadBookings,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          return BookingCardWidget(
            booking: _bookings[index],
            onTap: () => _navigateToDetails(_bookings[index].bookingId),
            formatDate: _formatDate,
          );
        },
      ),
    );
  }

  Widget _buildCarsBody() {
    return Column(
      children: [
        const EmployeeHeaderWidget(),
        CarsHeaderWidget(
          itemCount: _filteredCars.length,
          onSearchChanged: (v) {
            setState(() {
              _carSearch = v;
              _filteredCars = _applyCarFilter(v, _cars);
            });
          },
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadCars,
            child: _carsLoading
                ? const Center(child: CircularProgressIndicator())
                : _carsError != null
                    ? EmptyStateWidget(
                        icon: Icons.error_outline,
                        title: 'Error loading cars',
                        subtitle: _carsError!,
                        onRefresh: _loadCars,
                      )
                    : _filteredCars.isEmpty
                        ? const EmptyStateWidget(
                            icon: Icons.directions_car,
                            title: 'No cars found',
                            subtitle: 'No cars found for this search.',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredCars.length,
                            itemBuilder: (context, index) {
                              return CarCardWidget(car: _filteredCars[index]);
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
}
