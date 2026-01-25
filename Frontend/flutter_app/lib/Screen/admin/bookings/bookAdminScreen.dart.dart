import 'package:flutter/material.dart';
import '../../../api/bookAdmin.dart';
import '../../../model/admin_booking_model.dart';

class BookAdminScreen extends StatefulWidget {
  const BookAdminScreen({super.key});

  @override
  State<BookAdminScreen> createState() => _BookAdminScreenState();
}

class _BookAdminScreenState extends State<BookAdminScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  bool _loading = true;
  List<AdminBooking> _allBookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final data = await BookAdminApi.getAllBookings();
      setState(() {
        _allBookings = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  List<AdminBooking> _upcoming() {
    final now = DateTime.now();
    return _allBookings
        .where((b) => b.startDate.isAfter(now))
        .toList();
  }

  List<AdminBooking> _active() {
    final now = DateTime.now();
    return _allBookings
        .where((b) =>
            b.startDate.isBefore(now) &&
            b.endDate.isAfter(now))
        .toList();
  }

  List<AdminBooking> _completed() {
    final now = DateTime.now();
    return _allBookings
        .where((b) => b.endDate.isBefore(now))
        .toList();
  }

  Widget _bookingCard(AdminBooking booking) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4)
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200,
              image: booking.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(
                          "http://127.0.0.1:8000${booking.imageUrl}"),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: booking.imageUrl == null
                ? const Icon(Icons.directions_car,
                    size: 35, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "${booking.carBrand} ${booking.carModel}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text("Customer: ${booking.customerName}"),
                const SizedBox(height: 4),
                Text(
                    "${booking.startDate.toLocal().toString().split(' ')[0]} → ${booking.endDate.toLocal().toString().split(' ')[0]}"),
                const SizedBox(height: 4),
                Text(
                  "₪ ${booking.totalPrice}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<AdminBooking> list) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator());
    }

    if (list.isEmpty) {
      return const Center(
          child: Text("No bookings found"));
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return _bookingCard(list[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Bookings"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Upcoming"),
            Tab(text: "Active"),
            Tab(text: "Completed"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_upcoming()),
          _buildList(_active()),
          _buildList(_completed()),
        ],
      ),
    );
  }
}
