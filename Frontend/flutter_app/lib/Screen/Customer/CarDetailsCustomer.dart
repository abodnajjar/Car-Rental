import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../../model/car_model.dart';
import 'BookingScreen.dart';

class CarDetailsCustomer extends StatelessWidget {
  final Car car;

  const CarDetailsCustomer({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${car.brand} ${car.model}"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= Image =================
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: car.imageUrl.isNotEmpty
                  ? Image.network(
                    Uri.parse(ApiConfig.baseUrl)
                      .resolve(car.imageUrl)
                      .toString(),
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 220,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.directions_car, size: 80),
                    ),
            ),

            const SizedBox(height: 20),

            // ================= Info =================
            Text(
              "${car.brand} ${car.model}",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${car.category} • ${car.year}",
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // ================= Availability =================
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 12,
                  color: car.status ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  car.status ? "Available" : "Not Available",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: car.status ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ================= Prices =================
            const Text(
              "Prices per Day",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ...car.prices.map(
              (p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      p.day.toUpperCase(),
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "${p.price.toStringAsFixed(0)} NIS",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ================= Book Button =================
           SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    onPressed: car.status
        ? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingScreen(car: car),
              ),
            );
          }
        : null,
    style: ElevatedButton.styleFrom(
      backgroundColor: car.status ? Colors.blue : Colors.grey.shade400,
    ),
    child: const Text(
      "Book Now",
      style: TextStyle(fontSize: 18, color: Colors.white),
    ),
  ),
),

          ],
        ),
      ),
    );
  }
}
