import 'package:flutter/material.dart';
import '../../../api/cars_api.dart';
import '../../../model/car_model.dart';
import 'EditCar.dart';
import 'car_prices_screen.dart';
import 'AddCar.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key});

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  List<Car> _allCars = [];
  List<Car> _filteredCars = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  // ================================
  // Load cars from API
  // ================================
  Future<void> _loadCars() async {
    try {
      debugPrint("CALLING CARS API...");

      final data = await CarsApi.getCars();

      debugPrint("CARS COUNT: ${data.length}");

      if (!mounted) return;

      setState(() {
        _allCars = List<Car>.from(data);
        _filteredCars = List<Car>.from(data);
        _loading = false;
      });
    } catch (e) {
      debugPrint("ERROR LOADING CARS: $e");
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // ================================
  // Search filter
  // ================================
  void _onSearch(String value) {
    setState(() {
      _filteredCars = _allCars.where((c) {
        final q = value.toLowerCase();
        return c.brand.toLowerCase().contains(q) ||
            c.model.toLowerCase().contains(q);
      }).toList();
    });
  }

  // ================================
  // Confirm delete
  // ================================
  void _confirmDelete(Car car) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Car"),
        content: Text(
          "Are you sure you want to delete ${car.brand} ${car.model}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _deleteCar(car.id);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ================================
  // Delete car
  // ================================
  Future<void> _deleteCar(int id) async {
    try {
      await CarsApi.deleteCar(id);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Car deleted successfully")));

      _loadCars(); // 🔄 refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // 🔍 Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: "Search car by brand or model",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ================================
          // Cars List
          // ================================
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCars.isEmpty
                ? const Center(child: Text("No cars found"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredCars.length,
                    itemBuilder: (context, index) {
                      return _carCard(_filteredCars[index]);
                    },
                  ),
          ),
        ],
      ),

      // ➕ Add Car
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey.shade300,
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCarScreen()),
          );

          if (added == true && mounted) {
            _loadCars();
          }
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  // ================================
  // Car Card
  // ================================
  Widget _carCard(Car car) {
    return InkWell(
      onTap: () async {
        final updated = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditCarScreen(car: car)),
        );

        if (updated == true && mounted) {
          _loadCars();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade200,
                image: car.image.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(
                          "http://10.0.2.2:8000/${car.image}",
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: car.image.isEmpty
                  ? const Icon(Icons.directions_car, color: Colors.grey)
                  : null,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${car.brand} ${car.model}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "${car.category} • ${car.year}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    car.status ? "Available" : "Not Available",
                    style: TextStyle(
                      color: car.status ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_money, color: Colors.green),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CarPricesScreen(car: car),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(car),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
