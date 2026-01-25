import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/car_model.dart';
import '../../api/bookings_api.dart';
import 'customerScreen.dart';
import 'PaymentScreen.dart';

class BookingScreen extends StatefulWidget {
  final Car car;

  const BookingScreen({super.key, required this.car});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  bool _priceCalculated = false;
  bool _loading = false;

  double _totalPrice = 0;

  int? _userId; // ✅ من SharedPreferences

  // ==============================
  // Load user id
  // ==============================
  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt("user_id");
    });
  }

  // ==============================
  // Pick date helper
  // ==============================
  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // ==============================
  // Calculate Price (API)
  // ==============================
  Future<void> _calculatePrice() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User ID not found. Please login again.")),
      );
      return;
    }

    if (_pickupController.text.isEmpty ||
        _dropoffController.text.isEmpty ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() {
      _loading = true;
      _priceCalculated = false;
    });

    try {
      print("USER ID: $_userId");
      print("CAR ID: ${widget.car.carId}");

      final res = await BookingsApi.calculatePrice(
        userId: _userId!,
        carId: widget.car.carId,
        pickupLocation: _pickupController.text,
        dropoffLocation: _dropoffController.text,
        startDate: _startDate!,
        endDate: _endDate!,
      );

      setState(() {
        _priceCalculated = true;
        _totalPrice = (res["total_price"] as num).toDouble();
      });
    } catch (e) {
      print("CALCULATE PRICE ERROR: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  // ==============================
  // Confirm Booking (API)
  // ==============================
  Future<void> _confirmBooking() async {
    if (_userId == null) return;

    try {
      await BookingsApi.confirmBooking(
        userId: _userId!, // ✅ من SharedPreferences
        carId: widget.car.carId,
        pickupLocation: _pickupController.text,
        dropoffLocation: _dropoffController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        paymentMethod: "cash",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking confirmed successfully")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const CustomerScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to confirm booking")),
      );
    }
  }

  // ==============================
  // UI
  // ==============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details"),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.grey[100],

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= Car Info =================
            Text(
              "${widget.car.brand} ${widget.car.model}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.car.category,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            _inputField("Pickup Location", _pickupController),
            const SizedBox(height: 12),
            _inputField("Dropoff Location", _dropoffController),
            const SizedBox(height: 20),

            // ================= Dates =================
            Row(
              children: [
                Expanded(
                  child: _dateBox(
                    label: "Start Date",
                    value: _startDate,
                    onTap: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateBox(
                    label: "End Date",
                    value: _endDate,
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ================= Calculate Price =================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _calculatePrice,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Calculate Price"),
              ),
            ),

            const SizedBox(height: 20),

            // ================= Price Result =================
            if (_priceCalculated) ...[
              Text(
                "Total Price: $_totalPrice NIS",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),

                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(
                          userId: _userId!,
                          car: widget.car,
                          pickupLocation: _pickupController.text,
                          dropoffLocation: _dropoffController.text,
                          startDate: _startDate!,
                          endDate: _endDate!,
                          totalPrice: _totalPrice,
                        ),
                      ),
                    );
                  },
                  child: const Text("Confirm Booking"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==============================
  // Helpers
  // ==============================
  Widget _inputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _dateBox({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(
              value == null
                  ? "Select date"
                  : "${value.year}-${value.month}-${value.day}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
