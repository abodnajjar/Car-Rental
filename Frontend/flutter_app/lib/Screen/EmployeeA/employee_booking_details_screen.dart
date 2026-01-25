import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/bookings_api.dart';
import '../../model/booking_model.dart';
import '../../mock/mock_booking_data.dart';

class EmployeeBookingDetailsScreen extends StatefulWidget {
  final int bookingId;

  const EmployeeBookingDetailsScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<EmployeeBookingDetailsScreen> createState() =>
      _EmployeeBookingDetailsScreenState();
}

class _EmployeeBookingDetailsScreenState
    extends State<EmployeeBookingDetailsScreen> {
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _error;
  BookingDetails? _details;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (kUseMockData) {
        final details = MockBookingData.bookingDetailsById(widget.bookingId);
        setState(() {
          _details = details;
          _error = details == null
              ? 'Mock details not found for booking #${widget.bookingId}'
              : null;
          _isLoading = false;
        });
        return;
      }

      final details = await BookingsApi.getBookingDetails(widget.bookingId);
      setState(() {
        _details = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String status, String actionName) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      if (kUseMockData) {
        MockBookingData.updateBookingStatus(widget.bookingId, status);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mock: booking $actionName successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, {
            'bookingId': widget.bookingId,
            'status': status,
          });
        }
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getInt('user_id');
      await BookingsApi.updateBookingStatus(
        widget.bookingId,
        status,
        employeeId: employeeId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking $actionName successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, {
          'bookingId': widget.bookingId,
          'status': status,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

 String _formatDate(DateTime dt) {
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
}

  int _calculateDays() {
    if (_details == null) return 0;
    return _details!.endDate.difference(_details!.startDate).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Booking Details"),
        backgroundColor: const Color.fromARGB(255, 71, 113, 241),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_details == null) return const SizedBox();

    final details = _details!;
    final totalDays = _calculateDays();
    final pricePerDay = totalDays > 0 ? details.totalPrice / totalDays : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _carImage(details.car.imageUrl),

          _section(
            title: "Car Information",
            children: [
              _infoRow("Brand", details.car.brand),
              _infoRow("Model", details.car.model),
              _infoRow("Category", details.car.category),
              _infoRow("Year", details.car.year.toString()),
              _infoRow(
                "Availability",
                details.car.carStatus ? "Available" : "Unavailable",
              ),
              _infoRow("Price / Day", "\$${pricePerDay.toStringAsFixed(2)}"),
            ],
          ),

          _section(
            title: "Customer Information",
            children: [
              _infoRow("Full Name", details.customer.fullName),
              _infoRow("Phone", details.customer.phone),
              _infoRow("Email", details.customer.email),
              if (details.customer.drivingLicenseNo != null)
                _infoRow("License No", details.customer.drivingLicenseNo!),
            ],
          ),

          _section(
            title: "Booking Information",
            children: [
              _infoRow("Pickup", details.pickupLocation ?? "N/A"),
              _infoRow("Dropoff", details.dropoffLocation ?? "N/A"),
              _infoRow("Start Date", _formatDate(details.startDate)),
              _infoRow("End Date", _formatDate(details.endDate)),
              _infoRow("Total Days", "$totalDays days"),
              _infoRow(
                  "Total Price", "\$${details.totalPrice.toStringAsFixed(2)}"),
              _statusRow(details.bookingStatus),
            ],
          ),

          const SizedBox(height: 30),

          if (details.bookingStatus.toLowerCase() == 'pending') ...[
            _actionButton(
              text: _isUpdating ? "Processing..." : "Accept",
              color: Colors.green,
              onPressed: _isUpdating
                  ? null
                  : () => _updateStatus('approved', 'accepted'),
            ),
            const SizedBox(height: 12),
            _actionButton(
              text: _isUpdating ? "Processing..." : "Reject",
              color: Colors.red,
              onPressed: _isUpdating
                  ? null
                  : () => _updateStatus('cancelled', 'rejected'),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'This booking is already ${details.bookingStatus}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          const SizedBox(height: 20),

          _section(
            title: "Employee Actions",
            children: [
              if (details.bookingStatus.toLowerCase() == 'approved')
                _actionTile(
                  icon: Icons.login,
                  title: "Confirm Pickup",
                  subtitle: "Mark the car as picked up by the customer.",
                  onTap: _isUpdating
                      ? null
                      : () => _updateStatus('active', 'pickup confirmed'),
                ),
              if (details.bookingStatus.toLowerCase() == 'active')
                _actionTile(
                  icon: Icons.logout,
                  title: "Confirm Return",
                  subtitle: "Mark the car as returned.",
                  onTap: _isUpdating
                      ? null
                      : () => _updateStatus('completed', 'return confirmed'),
                ),
              _actionTile(
                icon: Icons.directions_car,
                title: details.car.carStatus
                    ? "Mark Unavailable"
                    : "Mark Available",
                subtitle: "Update car availability status.",
                onTap: () => _handleEmployeeAction("availability updated"),
              ),
              _actionTile(
                icon: Icons.report,
                title: "Report Damage",
                subtitle: "Log damages and notes for this car.",
                onTap: () => _handleEmployeeAction("damage reported"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _carImage(String? imageUrl) {
    final borderRadius = BorderRadius.circular(16);

    final imageWidget = (imageUrl != null && imageUrl.isNotEmpty)
        ? (imageUrl.startsWith('http')
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => const Icon(
                  Icons.directions_car,
                  size: 80,
                  color: Colors.grey,
                ),
              )
            : Image.asset(
                'assets/car_images/$imageUrl',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => const Icon(
                  Icons.directions_car,
                  size: 80,
                  color: Colors.grey,
                ),
              ))
        : const Icon(
            Icons.directions_car,
            size: 80,
            color: Colors.grey,
          );

    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.grey[300],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: imageWidget,
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey.shade200 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    isDisabled ? Colors.grey.shade300 : Colors.blue.shade50,
                child: Icon(
                  icon,
                  color: isDisabled ? Colors.grey : Colors.blueGrey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDisabled ? Colors.grey : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDisabled ? Colors.grey.shade500 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDisabled ? Colors.grey.shade400 : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleEmployeeAction(String message) {
    final hint = kUseMockData
        ? 'Mock: $message.'
        : 'This action needs a backend endpoint.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(hint)),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusRow(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case "approved":
      case "active":
        color = Colors.green;
        break;
      case "pending":
        color = Colors.orange;
        break;
      case "cancelled":
      case "completed":
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Row(
      children: [
        const Expanded(
          flex: 4,
          child: Text(
            "Status",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String text,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null ? Colors.grey : color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
