import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:io';

import '../../../api/cars_api.dart';
import '../../../model/car_model.dart';

class EditCarScreen extends StatefulWidget {
  final Car car;

  const EditCarScreen({super.key, required this.car});

  @override
  State<EditCarScreen> createState() => _EditCarScreenState();
}

class _EditCarScreenState extends State<EditCarScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _categoryController;
  late TextEditingController _yearController;

  bool _status = true;
  bool _loading = false;

  final ImagePicker _picker = ImagePicker();

  Uint8List? _webImageBytes;
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();

    _brandController = TextEditingController(text: widget.car.brand);
    _modelController = TextEditingController(text: widget.car.model);
    _categoryController = TextEditingController(text: widget.car.category);
    _yearController =
        TextEditingController(text: widget.car.year.toString());

    _status = widget.car.status;
  }

  // ===============================
  // PICK IMAGE
  // ===============================
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (picked == null) return;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _webImageBytes = bytes;
        _pickedImage = picked;
      });
    } else {
      setState(() {
        _pickedImage = picked;
      });
    }
  }

  // ===============================
  // UPDATE CAR
  // ===============================
  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final year = int.parse(_yearController.text.trim());

      // 1️⃣ Update car data
      await CarsApi.updateCar(
        widget.car.carId,
        {
          "brand": _brandController.text.trim(),
          "model": _modelController.text.trim(),
          "category": _categoryController.text.trim(),
          "year": year,
          "status": _status,
        },
      );

      // 2️⃣ Upload image if selected
      if (_pickedImage != null) {
        await CarsApi.uploadCarImage(
          widget.car.carId,
          fileName: _pickedImage!.name,
          bytes: kIsWeb ? _webImageBytes : null,
          filePath: !kIsWeb ? _pickedImage!.path : null,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Car updated successfully"),
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

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _categoryController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  // ===============================
  // BUILD IMAGE
  // ===============================
  Widget _buildImage() {
    // web preview
    if (kIsWeb && _webImageBytes != null) {
      return Image.memory(_webImageBytes!, fit: BoxFit.cover);
    }

    // mobile preview
    if (!kIsWeb && _pickedImage != null) {
      return Image.file(
        File(_pickedImage!.path),
        fit: BoxFit.cover,
      );
    }

    // current saved image
    if (widget.car.fullImageUrl.isNotEmpty) {
      return Image.network(
        widget.car.fullImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image)),
      );
    }

    return const Center(
      child: Text("Tap to select image"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 71, 113, 241),
        title: const Text("Edit Car"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _input("Brand", _brandController),
              _input("Model", _modelController),
              _input("Category", _categoryController),
              _input(
                "Year",
                _yearController,
                keyboard: TextInputType.number,
                isYear: true,
              ),
              const SizedBox(height: 16),

              // IMAGE BOX
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildImage(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text("Available"),
                value: _status,
                onChanged: (v) => setState(() => _status = v),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _loading ? null : _update,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color.fromARGB(255, 71, 113, 241),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : const Text(
                          "Save Changes",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
    bool isYear = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "$label is required";
          }

          if (isYear) {
            final year = int.tryParse(value);
            if (year == null) return "Invalid year";
            if (year < 1990 || year > DateTime.now().year + 1) {
              return "Invalid year";
            }
          }

          return null;
        },
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
