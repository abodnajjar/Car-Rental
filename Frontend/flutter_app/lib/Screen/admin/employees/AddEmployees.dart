import 'package:flutter/material.dart';
import '../../../api/SignUp.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final salary = TextEditingController();

  final AuthApi api = AuthApi();
  bool loading = false;

  Future<void> addEmployee() async {
    setState(() => loading = true);
    try {
      await api.signup(
        fullName: name.text,
        email: email.text,
        phone: phone.text,
        password: password.text,
        role: "employee",
        salary: double.parse(salary.text),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Employee")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: "Full Name")),
            TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: phone, decoration: const InputDecoration(labelText: "Phone")),
            TextField(controller: password, decoration: const InputDecoration(labelText: "Password")),
            TextField(
              controller: salary,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Salary"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: loading ? null : addEmployee,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Add Employee"),
            ),
          ],
        ),
      ),
    );
  }
}
