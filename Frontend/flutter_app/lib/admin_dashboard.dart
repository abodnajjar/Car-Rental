import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardApp extends StatefulWidget {
  const AdminDashboardApp({super.key});

  @override
  State<AdminDashboardApp> createState() => _AdminDashboardAppState();
}

class _AdminDashboardAppState extends State<AdminDashboardApp> {
  int _currentIndex = 1;

  final List<String> _titles = [
    "Home",
    "Dashboard",
    "Cars",
    "Employees",
    "Bookings",
    "Reports",
  ];

  final List<String> _headerImages = [
    "assets/home.png",
    "assets/dashboard.png",
    "assets/cars.png",
    "assets/employees.png",
    "assets/bookings.png",
    "assets/reports.png",
  ];

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      HomeScreen(),
      DashboardScreen(),
      CarsScreen(),
      EmployeesScreen(),
      BookingsScreen(),
      ReportsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // ================= AppBar =================
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 71, 113, 241),
        title: Row(
          children: [
            Image.asset("assets/carRental.png", height: 30),
            const SizedBox(width: 10),
            Text(_titles[_currentIndex]),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue),
              ),
            ),
          ),
        ],
      ),

      // ================= Body =================
      body: Column(
        children: [
          // ===== Header Image =====
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_headerImages[_currentIndex]),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ===== Screen Content =====
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),

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
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_rental),
            label: "Cars",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Employees",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: "Bookings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Reports",
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// DASHBOARD SCREEN
//////////////////////////////////////////////////////////////

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              statCard("Total Cars", "150", Icons.car_rental),
              statCard("Bookings", "480", Icons.book_online),
            ],
          ),
          Row(
            children: [
              statCard("Customers", "1,200", Icons.people),
              statCard("Revenue", "\$45,000", Icons.attach_money),
            ],
          ),
          const SizedBox(height: 30),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Monthly Profit",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8),
              ],
            ),
            child: LineChart(_chartData()),
          ),
        ],
      ),
    );
  }

  static Widget statCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blue, size: 30),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static LineChartData _chartData() {
    return LineChartData(
      minY: 0,
      maxY: 5000,
      gridData: FlGridData(show: true),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1000,
            getTitlesWidget: (value, meta) {
              return Text("${(value / 1000).toInt()}K");
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const months = [
                "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
              ];
              return Text(months[value.toInt()]);
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 800),
            FlSpot(1, 1200),
            FlSpot(2, 1000),
            FlSpot(3, 1600),
            FlSpot(4, 2000),
            FlSpot(5, 2400),
            FlSpot(6, 2200),
            FlSpot(7, 3000),
            FlSpot(8, 3500),
            FlSpot(9, 3200),
            FlSpot(10, 3900),
            FlSpot(11, 4500),
          ],
          isCurved: true,
          color: Colors.blue,
          barWidth: 4,
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withOpacity(0.15),
          ),
        ),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////
// OTHER SCREENS
//////////////////////////////////////////////////////////////

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Home Screen"));
  }
}

class CarsScreen extends StatelessWidget {
  const CarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Cars Screen"));
  }
}


class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6, 
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // صورة الموظف (Placeholder)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 32,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(width: 16),

                
                const Text(
                  "Employee",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),

      // ================= Floating Button =================
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey.shade300,
        onPressed: () {
          
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Bookings Screen"));
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Reports Screen"));
  }
}

//////////////////////////////////////////////////////////////
// PROFILE SCREEN
//////////////////////////////////////////////////////////////

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              "Admin User",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("admin@carrental.com"),
          ],
        ),
      ),
    );
  }
}
