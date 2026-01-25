import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/notification_model.dart';

class NotificationsApi {
  static const String baseUrl = "http://127.0.0.1:8000";

  static Future<List<NotificationModel>> getUserNotifications(int userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/notifications?user_id=$userId"),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load notifications");
    }
  }

  static Future<void> markAsRead(int notificationId) async {
    await http.patch(
      Uri.parse("$baseUrl/notifications/$notificationId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"is_read": true}),
    );
  }
}
