import 'package:flutter/material.dart';

class BookingDetailsScreen extends StatelessWidget {
  final String carName;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String startDate;
  final String endDate;
  final int totalDays;
  final double pricePerDay;
  final String status;

  const BookingDetailsScreen({
    super.key,
    required this.carName,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.pricePerDay,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final double totalPrice = totalDays * pricePerDay;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Booking Details"),
        backgroundColor: const Color.fromARGB(255, 71, 113, 241),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _section(
              title: "Car Information",
              children: [
                _infoRow("Car Name", carName),
                _infoRow("Price / Day", "\$${pricePerDay.toStringAsFixed(2)}"),
              ],
            ),

            _section(
              title: "Customer Information",
              children: [
                _infoRow("Full Name", customerName),
                _infoRow("Phone", customerPhone),
                _infoRow("Email", customerEmail),
              ],
            ),

            _section(
              title: "Booking Information",
              children: [
                _infoRow("Start Date", startDate),
                _infoRow("End Date", endDate),
                _infoRow("Total Days", "$totalDays days"),
                _infoRow("Total Price", "\$${totalPrice.toStringAsFixed(2)}"),
                _statusRow(status),
              ],
            ),

            const SizedBox(height: 30),
            if (status == "Active") ...[
              _actionButton(
                text: "Mark as Finished",
                color: Colors.green,
                onPressed: () {
                },
              ),
              const SizedBox(height: 12),
            ],

            _actionButton(
              text: "Cancel Booking",
              color: Colors.redAccent,
              onPressed: () {
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
  Widget _statusRow(String status) {
    Color color;
    switch (status) {
      case "Active":
        color = Colors.green;
        break;
      case "Pending":
        color = Colors.orange;
        break;
      case "Finished":
        color = Colors.redAccent;
        break;
      default:
        color = Colors.grey;
    }

    return Row(
      children: [
        const Expanded(
          flex: 4,
          child: Text(
            "Status",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _actionButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
