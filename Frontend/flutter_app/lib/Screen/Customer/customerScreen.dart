import 'package:flutter/material.dart';
import '../profileScreen.dart';
import '../../api/cars_api.dart';
import '../../model/car_model.dart';
import '../../model/car_price_model.dart';
import 'CarDetailsCustomer.dart';
import 'BookingHistoryScreen.dart';
import 'NotificationScreenCustomer.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  int _currentIndex = 0;
  bool _loading = true;
  List<Car> _cars = [];

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    try {
      final data = await CarsApi.getCars();
      if (!mounted) return;
      setState(() {
        _cars = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // ================================
  // Get today price from DB
  // ================================
  double _getTodayPriceFromDb(Car car) {
    final today = DateTime.now().weekday;

    const days = {
      1: "monday",
      2: "tuesday",
      3: "wednesday",
      4: "thursday",
      5: "friday",
      6: "saturday",
      7: "sunday",
    };

    final todayName = days[today]!;

    final todayPrice = car.prices.firstWhere(
      (p) => p.day.toLowerCase() == todayName,
      orElse: () => CarPrice(id: 0, day: todayName, price: 0),
    );

    return todayPrice.price;
  }

  // ================================
  // Build body
  // ================================
  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cars.isEmpty) {
      return const Center(child: Text("No cars available"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cars.length,
      itemBuilder: (context, index) {
        return _carCard(_cars[index]);
      },
    );
  }

  // ================================
  // Car Card
  // ================================
  Widget _carCard(Car car) {
    final price = _getTodayPriceFromDb(car);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          // ================= Image =================
          Container(
            width: 110,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200,
              image: car.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(
                        "http://127.0.0.1:8000/${car.imageUrl}",
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: car.imageUrl.isEmpty
                ? const Icon(Icons.directions_car, size: 40, color: Colors.grey)
                : null,
          ),

          const SizedBox(width: 12),

          // ================= Info =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${car.brand} ${car.model}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(car.category, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 6),
                Text(
                  "${price.toStringAsFixed(0)} NIS / day",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: car.status ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      car.status ? "Available" : "Not Available",
                      style: TextStyle(
                        color: car.status ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ================= Button =================
          ElevatedButton(
            onPressed: car.status
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CarDetailsCustomer(car: car),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: car.status ? Colors.blue : Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "View Details",
              style: TextStyle(
                color: car.status ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================
  // Main build
  // ================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      // ================= AppBar =================
      appBar: AppBar(
        leading: Image.asset("assets/carRental.png", height: 100),
        title: const Text(
          'CarRental',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
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

      // ================= Body =================
      body: _buildBody(),

      // ================= Bottom Navigation =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BookingHistoryScreen(),
              ),
            );
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationScreenCustomer()),
            );
          }

          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'My Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
            label: 'Notifications',
          ),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
