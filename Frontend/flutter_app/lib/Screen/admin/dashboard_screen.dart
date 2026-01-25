import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../api/dashboard_api.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;

  int totalCars = 0;
  int bookings = 0;
  int customers = 0;
  double revenue = 0;
  List<double> monthlyProfit = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final data = await DashboardApi.getDashboardStats();

      if (!mounted) return;

      setState(() {
        totalCars = data["total_cars"] ?? 0;
        bookings = data["bookings"] ?? 0;
        customers = data["customers"] ?? 0;
        revenue = (data["revenue"] ?? 0).toDouble();

        monthlyProfit = (data["monthly_profit"] as List)
            .map((e) => (e as num).toDouble())
            .toList();

        _loading = false;
      });
    } catch (e) {
      debugPrint("Dashboard error: $e");
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _statCard("Total Cars", totalCars.toString(), Icons.car_rental),
              _statCard("Bookings", bookings.toString(), Icons.book_online),
            ],
          ),
          Row(
            children: [
              _statCard("Customers", customers.toString(), Icons.people),
              _statCard("Revenue", "\$${revenue.toStringAsFixed(0)}",
                  Icons.attach_money),
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

  Widget _statCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
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
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _chartData() {
    if (monthlyProfit.isEmpty) {
      return LineChartData();
    }

    final double maxY = monthlyProfit.isEmpty
        ? 5000
        : (monthlyProfit.reduce((a, b) => a > b ? a : b) + 500)
            .toDouble();

    return LineChartData(
      minY: 0,
      maxY: maxY,
      gridData: FlGridData(show: true),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxY / 5,
            getTitlesWidget: (value, meta) =>
                Text("${(value / 1000).toInt()}K"),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const months = [
                "Jan",
                "Feb",
                "Mar",
                "Apr",
                "May",
                "Jun",
                "Jul",
                "Aug",
                "Sep",
                "Oct",
                "Nov",
                "Dec"
              ];
              if (value.toInt() < 0 || value.toInt() > 11) {
                return const Text("");
              }
              return Text(months[value.toInt()]);
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            monthlyProfit.length,
            (index) => FlSpot(
              index.toDouble(),
              monthlyProfit[index],
            ),
          ),
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
