import 'package:flutter/material.dart';
import '../../../api/Signup.dart'; 

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

  final AuthApi _authApi = AuthApi();

  void addEmployee() async {
    try {
      await _authApi.signup(
        fullName: name.text.trim(),
        email: email.text.trim(),
        phone: phone.text.trim(),
        password: password.text,
        role: "employee",
        salary: double.parse(salary.text),
      );

      Navigator.pop(context); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
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
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: phone,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            TextField(
              controller: salary,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Salary"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addEmployee,
              child: const Text("Add Employee"),
            )
          ],
        ),
      ),
    );
  }
}
