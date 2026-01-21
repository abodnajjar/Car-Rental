import 'package:flutter/material.dart';

class BookedCarsScreen extends StatelessWidget {
  const BookedCarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, 
        itemBuilder: (context, index) {
          return _bookedCarCard(
            carName: "Toyota Camry",
            customerName: "Ahmed Ali",
            days: 3,
            status: "Active", // Active | Pending | Finished
          );
        },
      ),
    );
  }

  // ================= Booked Car Card =================
  Widget _bookedCarCard({
    required String carName,
    required String customerName,
    required int days,
    required String status,
  }) {
    Color statusColor;
    switch (status) {
      case "Active":
        statusColor = Colors.green;
        break;
      case "Pending":
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // صورة السيارة
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.car_rental,
              size: 36,
              color: Colors.grey,
            ),
          ),

          const SizedBox(width: 16),

          // معلومات الحجز
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  carName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  "Client: $customerName",
                  style: const TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 4),

                Text(
                  "Duration: $days days",
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),

          
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}
