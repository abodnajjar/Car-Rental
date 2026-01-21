import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
              _statCard("Total Cars", "150", Icons.car_rental),
              _statCard("Bookings", "480", Icons.book_online),
            ],
          ),
          Row(
            children: [
              _statCard("Customers", "1,200", Icons.people),
              _statCard("Revenue", "\$45,000", Icons.attach_money),
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
            Text(value,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  LineChartData _chartData() {
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
            getTitlesWidget: (value, meta) =>
                Text("${(value / 1000).toInt()}K"),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const months = [
                "Jan","Feb","Mar","Apr","May","Jun",
                "Jul","Aug","Sep","Oct","Nov","Dec"
              ];
              return Text(months[value.toInt()]);
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 800), FlSpot(1, 1200), FlSpot(2, 1000),
            FlSpot(3, 1600), FlSpot(4, 2000), FlSpot(5, 2400),
            FlSpot(6, 2200), FlSpot(7, 3000), FlSpot(8, 3500),
            FlSpot(9, 3200), FlSpot(10, 3900), FlSpot(11, 4500),
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
