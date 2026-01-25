import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/notifications_api.dart';
import '../../model/notification_model.dart';

class NotificationScreenCustomer extends StatefulWidget {
  const NotificationScreenCustomer({super.key});

  @override
  State<NotificationScreenCustomer> createState() =>
      _NotificationScreenCustomerState();
}

class _NotificationScreenCustomerState
    extends State<NotificationScreenCustomer> {
  List<NotificationModel> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");

    if (userId == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final data = await NotificationsApi.getUserNotifications(userId);

      if (!mounted) return;

      setState(() {
        _notifications = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleTap(NotificationModel notification) async {
    if (!notification.isRead) {
      await NotificationsApi.markAsRead(notification.id);

      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = NotificationModel(
            id: notification.id,
            userId: notification.userId,
            title: notification.title,
            message: notification.message,
            isRead: true,
            createdAt: notification.createdAt,
            rentalId: notification.rentalId,
          );
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  IconData _getIcon(String title) {
    if (title.toLowerCase().contains("approved")) {
      return Icons.check_circle;
    } else if (title.toLowerCase().contains("rejected")) {
      return Icons.cancel;
    }
    return Icons.notifications;
  }

  Color _getIconColor(String title) {
    if (title.toLowerCase().contains("approved")) {
      return Colors.green;
    } else if (title.toLowerCase().contains("rejected")) {
      return Colors.red;
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.blue,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? const Center(
              child: Text(
                "No notifications yet",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];

                return GestureDetector(
                  onTap: () => _handleTap(notification),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: notification.isRead
                          ? const Color.fromARGB(255, 176, 242, 184)
                          : const Color.fromARGB(255, 230, 237, 201),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 5),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _getIcon(notification.title),
                          color: _getIconColor(notification.title),
                          size: 30,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notification.message,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatDate(notification.createdAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
