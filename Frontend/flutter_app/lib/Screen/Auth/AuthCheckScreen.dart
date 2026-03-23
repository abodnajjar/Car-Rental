import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginScreen.dart';
import '../Customer/customerScreen.dart';
import '../Admin/AdminLayout.dart';
import '../EmployeeA/employeeScreen.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _redirectUser();
  }

  Future<void> _redirectUser() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getInt("user_id");
    final role = prefs.getString("role");

    await Future.delayed(const Duration(milliseconds: 300)); 

    if (!mounted) return;

    if (userId == null || role == null) {
      _go(const LoginScreen());
      return;
    }

    switch (role) {
      case "customer":
        _go(const CustomerScreen());
        break;

      case "admin":
        _go(const AdminLayout());
        break;

      case "employee":
        _go(const EmployeeScreen());
        break;

      default:
        _go(const LoginScreen());
    }
  }

 void _go(Widget screen) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => screen,
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}