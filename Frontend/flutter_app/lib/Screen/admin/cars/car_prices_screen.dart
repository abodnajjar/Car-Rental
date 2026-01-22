import 'package:flutter/material.dart';
import '../../../../api/car_prices_api.dart';
import '../../../../model/car_model.dart';
import '../../../../model/car_price_model.dart';

class CarPricesScreen extends StatefulWidget {
  final Car car;

  const CarPricesScreen({super.key, required this.car});

  @override
  State<CarPricesScreen> createState() => _CarPricesScreenState();
}

class _CarPricesScreenState extends State<CarPricesScreen> {
  bool _loading = true;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _errors = {};
  List<CarPrice> _prices = [];

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    try {
      final data = await CarPricesApi.getCarPrices(widget.car.id);

      for (final p in data) {
        _controllers[p.day] =
            TextEditingController(text: p.price.toString());
        _errors[p.day] = null;
      }

      setState(() {
        _prices = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  bool _validateAll() {
    bool valid = true;

    for (final p in _prices) {
      final text = _controllers[p.day]!.text.trim();
      final value = double.tryParse(text);

      if (value == null) {
        _errors[p.day] = "Invalid number";
        valid = false;
      } else if (value < 50 || value > 10000) {
        _errors[p.day] = "Price must be 50 - 10000";
        valid = false;
      } else {
        _errors[p.day] = null;
      }
    }

    setState(() {});
    return valid;
  }

  Future<void> _saveAll() async {
    if (!_validateAll()) return;

    for (final p in _prices) {
      await CarPricesApi.updateCarPrice(
        carId: widget.car.id,
        day: p.day,
        price: double.parse(_controllers[p.day]!.text),
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Prices updated successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "${widget.car.brand} ${widget.car.model} - Prices",
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(3),
                      },
                      border: TableBorder.all(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 230, 230, 230),
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                "Day",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                "Price",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ..._prices.map(
                          (p) => TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(p.day),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: TextField(
                                  controller: _controllers[p.day],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "Enter price",
                                    errorText: _errors[p.day],
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Save Prices",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
