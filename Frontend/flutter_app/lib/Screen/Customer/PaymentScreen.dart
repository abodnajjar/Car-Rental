import 'package:flutter/material.dart';
import '../../api/bookings_api.dart';
import '../../model/car_model.dart';
import 'customerScreen.dart';

class PaymentScreen extends StatefulWidget {
  final Car car;
  final int userId;
  final String pickupLocation;
  final String dropoffLocation;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;

  const PaymentScreen({
    super.key,
    required this.car,
    required this.userId,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _loading = false;

  Future<void> _payNow() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await BookingsApi.confirmBooking(
        userId: widget.userId,
        carId: widget.car.carId,
        pickupLocation: widget.pickupLocation,
        dropoffLocation: widget.dropoffLocation,
        startDate: widget.startDate,
        endDate: widget.endDate,
        paymentMethod: "visa",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment successful")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const CustomerScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment failed")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Online Payment"),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total: ${widget.totalPrice.toStringAsFixed(0)} NIS",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              TextFormField(
                controller: _cardController,
                keyboardType: TextInputType.number,
                maxLength: 16,
                decoration: const InputDecoration(
                  labelText: "Card Number",
                  hintText: "16 digits",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Card number is required";
                  }
                  if (!RegExp(r'^\d{16}$').hasMatch(value)) {
                    return "Card number must be 16 digits";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _expiryController,
                decoration: const InputDecoration(
                  labelText: "Expiry Date",
                  hintText: "MM/YY",
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Expiry date is required";
                  }
                  if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$')
                      .hasMatch(value)) {
                    return "Expiry date must be MM/YY";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                maxLength: 3,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "CVV",
                  hintText: "3 digits",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "CVV is required";
                  }
                  if (!RegExp(r'^\d{3}$').hasMatch(value)) {
                    return "CVV must be 3 digits";
                  }
                  return null;
                },
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _payNow,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Pay Now"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
