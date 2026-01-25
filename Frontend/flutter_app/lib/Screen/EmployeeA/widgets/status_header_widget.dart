import 'package:flutter/material.dart';

class StatusHeaderWidget extends StatelessWidget {
  final String currentStatus;
  final int itemCount;

  const StatusHeaderWidget({
    super.key,
    required this.currentStatus,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    final label = currentStatus[0].toUpperCase() + currentStatus.substring(1);

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
            currentStatus == 'pending'
                ? Icons.pending_actions
                : currentStatus == 'accepted'
                    ? Icons.check_circle
                    : Icons.cancel,
            color: currentStatus == 'pending'
                ? Colors.orange
                : currentStatus == 'accepted'
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
            '$itemCount items',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
