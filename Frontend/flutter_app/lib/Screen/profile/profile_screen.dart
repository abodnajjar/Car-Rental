import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ================= AppBar =================
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 71, 113, 241),
        title: const Text("My Profile"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ================= Avatar =================
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue,
                  width: 3,
                ),
              ),
              child: const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ================= Name =================
            const Text(
              "Admin User",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "admin@carrental.com",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // ================= Info Card =================
            _infoCard(
              icon: Icons.phone,
              title: "Phone",
              value: "059-123-4567",
            ),

            _infoCard(
              icon: Icons.badge,
              title: "Role",
              value: "Administrator",
            ),

            _infoCard(
              icon: Icons.calendar_today,
              title: "Joined",
              value: "January 2026",
            ),

            const SizedBox(height: 30),

            // ================= Buttons =================
            _actionButton(
              text: "Edit Profile",
              icon: Icons.edit,
              color: Colors.blue,
              onPressed: () {
                // TODO: Open Edit Profile Screen
              },
            ),

            const SizedBox(height: 12),

            _actionButton(
              text: "Logout",
              icon: Icons.logout,
              color: Colors.redAccent,
              onPressed: () {
                // TODO: Logout logic
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= Info Card =================
  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= Action Button =================
  Widget _actionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
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
