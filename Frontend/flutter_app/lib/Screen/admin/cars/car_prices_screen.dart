import 'package:flutter/material.dart';
import '../../../../model/car_model.dart';
import '../../../../model/car_price_model.dart';
import '../../../api/car_prices_api.dart';

class CarPricesScreen extends StatefulWidget {
  final Car car;

  const CarPricesScreen({super.key, required this.car});

  @override
  State<CarPricesScreen> createState() => _CarPricesScreenState();
}

class _CarPricesScreenState extends State<CarPricesScreen> {
  bool _loading = true;
  bool _saving = false;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _errors = {};

  final List<String> _orderedDays = const [
    "sunday",
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadPrices();
  }

  
  void _initializeControllers() {
    for (final day in _orderedDays) {
      _controllers[day] = TextEditingController(text: "0");
      _errors[day] = null;
    }
  }

  Future<void> _loadPrices() async {
    setState(() => _loading = true);

    try {
      final data =
          await CarPricesApi.getCarPrices(widget.car.carId);

      for (final p in data) {
        if (_controllers.containsKey(p.day)) {
          _controllers[p.day]!.text = p.price.toString();
        }
      }

      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  bool _validateAll() {
    bool valid = true;

    for (final day in _orderedDays) {
      final controller = _controllers[day];
      if (controller == null) continue;

      final text = controller.text.trim();
      final value = double.tryParse(text);

      if (value == null) {
        _errors[day] = "Invalid number";
        valid = false;
      } else if (value < 50 || value > 10000) {
        _errors[day] = "Price must be 50 - 10000";
        valid = false;
      } else {
        _errors[day] = null;
      }
    }

    setState(() {});
    return valid;
  }

  Future<void> _saveAll() async {
    if (!_validateAll()) return;

    setState(() => _saving = true);

    try {
      final prices = _orderedDays.map((day) {
        return {
          "day": day,
          "price": double.parse(
              _controllers[day]!.text.trim()),
        };
      }).toList();

      await CarPricesApi.updateAllPrices(
        carId: widget.car.carId,
        prices: prices,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Prices updated successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _dayLabel(String day) {
    return day[0].toUpperCase() + day.substring(1);
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
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orderedDays.length,
                    itemBuilder: (context, index) {
                      final day = _orderedDays[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(
                                _dayLabel(day),
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller:
                                    _controllers[day],
                                keyboardType:
                                    const TextInputType
                                        .numberWithOptions(
                                        decimal: true),
                                decoration: InputDecoration(
                                  hintText: "Enter price",
                                  errorText:
                                      _errors[day],
                                  suffixText: "₪",
                                  border:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          _saving ? null : _saveAll,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  14),
                        ),
                      ),
                      child: _saving
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : const Text(
                              "Save Prices",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
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
