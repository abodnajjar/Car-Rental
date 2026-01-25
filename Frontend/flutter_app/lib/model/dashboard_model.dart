class DashboardData {
  final int totalCars;
  final int totalBookings;
  final int totalCustomers;
  final double totalRevenue;
  final List<double> monthlyProfit;

  DashboardData({
    required this.totalCars,
    required this.totalBookings,
    required this.totalCustomers,
    required this.totalRevenue,
    required this.monthlyProfit,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalCars: json['total_cars'] ?? 0,
      totalBookings: json['total_bookings'] ?? 0,
      totalCustomers: json['total_customers'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      monthlyProfit: List<double>.from(
        (json['monthly_profit'] ?? [])
            .map((e) => (e as num).toDouble()),
      ),
    );
  }
}
