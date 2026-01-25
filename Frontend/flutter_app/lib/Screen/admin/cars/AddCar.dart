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

  String _dayLabel(String day) => day[0].toUpperCase() + day.substring(1);

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

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

  bool _validateForm() {
    if (_brandController.text.trim().isEmpty ||
        _modelController.text.trim().isEmpty ||
        _categoryController.text.trim().isEmpty ||
        _yearController.text.trim().isEmpty) {
      _showMessage("Please fill all required fields");
      return false;
    }

    final year = int.tryParse(_yearController.text.trim());
    if (year == null || year < 1950 || year > 2100) {
      _showMessage("Please enter a valid year");
      return false;
    }

    if (_imageName == null ||
        (kIsWeb ? _imageBytes == null : _imagePath == null)) {
      _showMessage("Please choose an image");
      return false;
    }

    for (final entry in _priceControllers.entries) {
      final p = double.tryParse(entry.value.text.trim());
      if (p == null || p <= 0) {
        _showMessage("Invalid price for ${_dayLabel(entry.key)}");
        return false;
      }
    }
    return true;
  }
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

      final created = await CarsApi.addCar({
        "brand": _brandController.text.trim(),
        "model": _modelController.text.trim(),
        "category": _categoryController.text.trim(),
        "year": year,
        "status": _status,
        "image_url": "",
        "prices": prices,
      });

    final carId = created.carId;

      await CarsApi.uploadCarImage(
        carId,
        fileName: _imageName!,
        bytes: _imageBytes,
        filePath: _imagePath,
      );

      await CarsApi.updateCar(carId, {
        "image_url": "/uploads/cars/$carId.jpg",
      });

    if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 71, 113, 241),
        title: const Text("Add Car"),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _sectionCard(
              title: "Car Info",
              child: Column(
                children: [
                  _rowField("Brand", _brandController, border: border),
                  _rowField("Model", _modelController, border: border),
                  _rowField("Category", _categoryController, border: border),
                  _rowField(
                    "Year",
                    _yearController,
                    border: border,
                    keyboard: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            _sectionCard(
              title: "Image",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: _imageName == null
                          ? Center(
                              child: Text(
                                "No image selected",
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            )
                          : (kIsWeb
                              ? Image.memory(
                                  _imageBytes!,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_imagePath!),
                                  fit: BoxFit.cover,
                                )),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _imageName == null ? "No image selected" : _imageName!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _loading ? null : _pickImage,
                        icon: const Icon(Icons.image_outlined),
                        label: const Text("Choose"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _sectionCard(
              title: "Rental Prices (Sunday → Saturday)",
              child: Column(
                children: _priceControllers.entries.map((e) {
                  return _rowField(
                    _dayLabel(e.key),
                    e.value,
                    border: border,
                    keyboard: TextInputType.number,
                    suffixText: "₪",
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 14),

            _sectionCard(
              title: "Status",
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Available"),
                value: _status,
                onChanged: (v) => setState(() => _status = v),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 71, 113, 241),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Add Car", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _rowField(
    String label,
    TextEditingController controller, {
    required OutlineInputBorder border,
    TextInputType keyboard = TextInputType.text,
    String? suffixText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboard,
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                enabledBorder: border,
                focusedBorder: border.copyWith(
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 71, 113, 241),
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixText: suffixText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
