import 'package:flutter/material.dart';
import '../../../model/admin_booking_model.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pickup: ${booking.pickupLocation ?? ''}"),
                const SizedBox(height: 10),

                Text("Dropoff: ${booking.dropoffLocation ?? ''}"),
                const SizedBox(height: 10),

                Text("Start Date: ${booking.startDate}"),
                const SizedBox(height: 10),

                Text("End Date: ${booking.endDate}"),
                const SizedBox(height: 10),

                Text("Total Price: ${booking.totalPrice ?? 0} \$"),
                const SizedBox(height: 10),

                Text("Status: ${booking.status}"),
                const SizedBox(height: 10),

                Text("Created At: ${booking.createdAt}"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
