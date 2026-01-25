import 'package:flutter/material.dart';
import '../../../model/booking_model.dart';
import 'car_thumbnail_widget.dart';

class BookingCardWidget extends StatelessWidget {
  final PendingBooking booking;
  final VoidCallback onTap;
  final String Function(DateTime) formatDate;

  const BookingCardWidget({
    super.key,
    required this.booking,
    required this.onTap,
    required this.formatDate,
  });

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

  @override
  Widget build(BuildContext context) {
    final days = booking.endDate.difference(booking.startDate).inDays;
    final statusLabel = _statusLabel(booking.bookingStatus);
    final statusColor = _statusColor(booking.bookingStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CarThumbnailWidget(imageUrl: booking.imageUrl),
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
                              horizontal: 10, vertical: 5),
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
                    _infoRow(Icons.calendar_today, 'Start',
                        formatDate(booking.startDate)),
                    _infoRow(Icons.event_available, 'End',
                        formatDate(booking.endDate)),
                    _infoRow(Icons.access_time, 'Duration', '$days days'),
                    _infoRow(Icons.attach_money, 'Total',
                        '\$${booking.totalPrice.toStringAsFixed(2)}'),
                    if (booking.pickupLocation != null)
                      _infoRow(Icons.location_on, 'Pickup',
                          booking.pickupLocation!),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: onTap,
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
}
