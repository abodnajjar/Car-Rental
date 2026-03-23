import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../api/cars_api.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _categoryController = TextEditingController();
  final _yearController = TextEditingController();

  final Map<String, TextEditingController> _priceControllers = {
    "sunday": TextEditingController(),
    "monday": TextEditingController(),
    "tuesday": TextEditingController(),
    "wednesday": TextEditingController(),
    "thursday": TextEditingController(),
    "friday": TextEditingController(),
    "saturday": TextEditingController(),
  };

  bool _status = true;
  bool _loading = false;

  Uint8List? _imageBytes;
  String? _imagePath;
  String? _imageName;

  String _dayLabel(String day) =>
      day[0].toUpperCase() + day.substring(1);

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ===============================
  // PICK IMAGE
  // ===============================
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result == null) return;

    final file = result.files.single;

    setState(() {
      _imageName = file.name;
      _imageBytes = kIsWeb ? file.bytes : null;
      _imagePath = !kIsWeb ? file.path : null;
    });
  }

  // ===============================
  // VALIDATION
  // ===============================
  bool _validateForm() {
    if (_brandController.text.trim().isEmpty ||
        _modelController.text.trim().isEmpty ||
        _categoryController.text.trim().isEmpty ||
        _yearController.text.trim().isEmpty) {
      _showMessage("Please fill all required fields");
      return false;
    }

    final year = int.tryParse(_yearController.text.trim());
    if (year == null || year < 1990 || year > DateTime.now().year + 1) {
      _showMessage("Invalid year");
      return false;
    }

    if (_imageName == null ||
        (kIsWeb ? _imageBytes == null : _imagePath == null)) {
      _showMessage("Please choose an image");
      return false;
    }

    for (final entry in _priceControllers.entries) {
      final price = double.tryParse(entry.value.text.trim());
      if (price == null || price <= 0) {
        _showMessage("Invalid price for ${_dayLabel(entry.key)}");
        return false;
      }
    }

    return true;
  }

  // ===============================
  // SUBMIT
  // ===============================
  Future<void> _submit() async {
    if (!_validateForm()) return;

    setState(() => _loading = true);

    try {
      final year = int.parse(_yearController.text.trim());

      final prices = _priceControllers.entries.map((e) {
        return {
          "day": e.key,
          "price": double.parse(e.value.text.trim()),
        };
      }).toList();

      // 1️⃣ Create car without image
      final created = await CarsApi.addCar({
        "brand": _brandController.text.trim(),
        "model": _modelController.text.trim(),
        "category": _categoryController.text.trim(),
        "year": year,
        "status": _status,
        "image_url": "", // مهم جداً
        "prices": prices,
      });

      final carId = created.carId;

      // 2️⃣ Upload image
      await CarsApi.uploadCarImage(
        carId,
        fileName: _imageName!,
        bytes: _imageBytes,
        filePath: _imagePath,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Car added successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _categoryController.dispose();
    _yearController.dispose();
    for (final c in _priceControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 71, 113, 241),
        title: const Text("Add Car"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _input("Brand", _brandController),
            _input("Model", _modelController),
            _input("Category", _categoryController),
            _input("Year", _yearController,
                keyboard: TextInputType.number),

            const SizedBox(height: 16),

            // IMAGE
            GestureDetector(
              onTap: _loading ? null : _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _imageName == null
                      ? const Center(
                          child: Text("Tap to select image"))
                      : (kIsWeb
                          ? Image.memory(_imageBytes!,
                              fit: BoxFit.cover)
                          : Image.file(File(_imagePath!),
                              fit: BoxFit.cover)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // PRICES
            ..._priceControllers.entries.map((e) {
              return _input(
                _dayLabel(e.key),
                e.value,
                keyboard: TextInputType.number,
              );
            }).toList(),

            const SizedBox(height: 20),

            SwitchListTile(
              title: const Text("Available"),
              value: _status,
              onChanged: (v) => setState(() => _status = v),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 71, 113, 241),
                ),
                child: _loading
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : const Text(
                        "Add Car",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
