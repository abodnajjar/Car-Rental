import 'package:flutter/material.dart';
import '../../../model/employee_model.dart';
import '../../../api/employees.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  final Employee employee;

  const EmployeeDetailsScreen({
    super.key,
    required this.employee,
  });

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  late TextEditingController salaryController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    salaryController =
        TextEditingController(text: widget.employee.salary.toString());
  }

  // ================================
  // Update salary
  // ================================
  Future<void> _saveSalary() async {
    final newSalary = double.tryParse(salaryController.text);

    if (newSalary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid salary value")),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await EmployeesApi.updateEmployeeSalary(
        uid: widget.employee.uid,
        salary: newSalary,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Salary updated successfully")),
      );

      Navigator.pop(context, true); // 👈 return success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final emp = widget.employee;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoTile("Full Name", emp.fullName),
            _infoTile("Email", emp.email),
            _infoTile("Phone", emp.phone),

            const SizedBox(height: 20),
            
            const Text(
              "Salary",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: salaryController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter salary",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveSalary,
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
