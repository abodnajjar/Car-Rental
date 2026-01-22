import 'package:flutter/material.dart';
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
  final _imageController = TextEditingController();

  bool _status = true;
  bool _loading = false;

  // ================================
  // Submit
  // ================================
  Future<void> _submit() async {
    if (_brandController.text.isEmpty ||
        _modelController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _yearController.text.isEmpty) {
      _showMessage("Please fill all required fields");
      return;
    }

    setState(() => _loading = true);

    try {
      await CarsApi.addCar({
        "brand": _brandController.text,
        "model": _modelController.text,
        "category": _categoryController.text,
        "year": int.parse(_yearController.text),
        "status": _status,
        "image": _imageController.text.isEmpty
            ? null
            : _imageController.text,
      });

      if (!mounted) return;

      Navigator.pop(context, true); // ✅ notify success
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

  // ================================
  // UI
  // ================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  const Color.fromARGB(255, 71, 113, 241),
        title: const Text("Add Car"),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade100,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _input("Brand", _brandController),
            _input("Model", _modelController),
            _input("Category", _categoryController),
            _input(
              "Year",
              _yearController,
              keyboard: TextInputType.number,
            ),
            _input("Image path (optional)", _imageController),

            const SizedBox(height: 12),

            // Status switch
            SwitchListTile(
              title: const Text("Available"),
              value: _status,
              onChanged: (v) => setState(() => _status = v),
            ),

            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Add Car",
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================
  // Input helper
  // ================================
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
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
