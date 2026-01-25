import 'package:flutter/material.dart';
import '../../../api/admin_rentals_api.dart';
import '../../../model/admin_booking_model.dart';
import 'booking_details_screen.dart';

class BookAdminScreen extends StatefulWidget {
  const BookAdminScreen({super.key});

  @override
  State<BookAdminScreen> createState() => _BookAdminScreenState();
}

class _BookAdminScreenState extends State<BookAdminScreen>
    with SingleTickerProviderStateMixin {

  List<Booking> upcoming = [];
  List<Booking> active = [];
  List<Booking> completed = [];

  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadBookings();
  }

  Future<void> loadBookings() async {
    try {
      final List<Booking> data =
          await BookingsApi.getAllBookings();

      final now = DateTime.now();

      List<Booking> up = [];
      List<Booking> act = [];
      List<Booking> comp = [];

      for (final booking in data) {
        final start = booking.startDate;
        final end = booking.endDate;

        if (start == null || end == null) continue;

        if (start.isAfter(now)) {
          up.add(booking);
        } else if ((start.isBefore(now) ||
                start.isAtSameMomentAs(now)) &&
            end.isAfter(now)) {
          act.add(booking);
        } else if (end.isBefore(now)) {
          comp.add(booking);
        }
      }

      setState(() {
        upcoming = up;
        active = act;
        completed = comp;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading bookings: $e");
      setState(() => isLoading = false);
    }
  }

  Widget buildList(List<Booking> list) {
    if (list.isEmpty) {
      return const Center(child: Text("No bookings found"));
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final booking = list[index];

        return Card(
          margin: const EdgeInsets.all(12),
          elevation: 3,
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BookingDetailsScreen(booking: booking),
                ),
              );
            },
            title: Text(
              "${booking.pickupLocation ?? ''} → ${booking.dropoffLocation ?? ''}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text("Start: ${booking.startDate}"),
                Text("End: ${booking.endDate}"),
                Text("Price: ${booking.totalPrice ?? 0} \$"),
              ],
            ),
            trailing:
                const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookings"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Upcoming"),
            Tab(text: "Active"),
            Tab(text: "Completed"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                buildList(upcoming),
                buildList(active),
                buildList(completed),
              ],
            ),
    );
  }
}
