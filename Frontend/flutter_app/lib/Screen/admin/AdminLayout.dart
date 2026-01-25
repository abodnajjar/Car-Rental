import 'package:flutter/material.dart';

// Admin Screens
import 'dashboard_screen.dart';
import './employees/employees_screen.dart';
import './cars/CarsScreen.dart';
import 'bookings/bookAdminScreen.dart.dart';

// Profile
import '../profileScreen.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _currentIndex = 0;

  // ================= Titles =================
  final List<String> _titles = [
    "Dashboard",
    "Employees",
    "Cars",
    "Bookings",
  ];

  // ================= Screens =================
  final List<Widget> _screens = [
    DashboardScreen(),
    EmployeesScreen(),
    CarsScreen(),
    BookAdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ================= AppBar =================
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 71, 113, 241),
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              "assets/carRental.png",
              height: 28,
            ),
            const SizedBox(width: 10),
            Text(
              _titles[_currentIndex],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Colors.blue,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),

      // ================= Body =================
      body: _screens[_currentIndex],

      // ================= Bottom Navigation =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Employees",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: "Cars",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: "Bookings",
          ),
        ],
      ),
    );
  }
}
