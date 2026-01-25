import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/bookings_api.dart';
import '../../model/booking_history_model.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  bool _loading = true;
  List<BookingHistoryItem> _bookings = [];
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserAndBookings();
  }

  // =========================
  // Load user id + bookings
  // =========================
  Future<void> _loadUserAndBookings() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt("user_id");

    if (_userId == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final data = await BookingsApi.getBookingHistory(_userId!);
      setState(() {
        _bookings = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking History"),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.grey[100],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(child: Text("No bookings found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    return _bookingCard(_bookings[index]);
                  },
                ),
    );
  }

  // =========================
  // Booking Card
  // =========================
  Widget _bookingCard(BookingHistoryItem booking) {
    Color statusColor;

    switch (booking.bookingStatus.toLowerCase()) {
      case "pending":
        statusColor = Colors.orange;
        break;
      case "approved":
        statusColor = Colors.blue;
        break;
      case "completed":
        statusColor = Colors.green;
        break;
      case "cancelled":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          // ================= Image =================
          Container(
            width: 90,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade200,
              image: booking.imageUrl != null &&
                      booking.imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(
                        Uri.parse(ApiConfig.baseUrl)
                            .resolve(booking.imageUrl!)
                            .toString(),
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: booking.imageUrl == null
                ? const Icon(Icons.directions_car, color: Colors.grey)
                : null,
          ),

          const SizedBox(width: 12),

          // ================= Info =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${booking.brand} ${booking.model}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  booking.category,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  "${booking.totalPrice.toStringAsFixed(0)} NIS",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  "${booking.startDate.toLocal().toString().split(' ').first} → "
                  "${booking.endDate.toLocal().toString().split(' ').first}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          // ================= Status =================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              booking.bookingStatus.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
