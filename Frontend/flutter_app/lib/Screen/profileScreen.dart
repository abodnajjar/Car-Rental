import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String fullName = "Mohammad Sroor";
    final String email = "mohammad@example.com";
    final String phone = "+970 599 000 000";
    final String role = "Customer";

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      // ==================== AppBar ===========================================
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 232, 241, 242),
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Profile",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              fullName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              role,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: Navigate to Edit Profile
            },
          ),
        ],
      ),

      // ==================== Body =============================================
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== Card معلومات المستخدم =====
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue),
                        const SizedBox(width: 10),
                        const Text(
                          "Full Name: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            fullName,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Email
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, color: Colors.orange),
                        const SizedBox(width: 10),
                        const Text(
                          "Email: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            email,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Phone
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, color: Colors.green),
                        const SizedBox(width: 10),
                        const Text(
                          "Phone Number: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            phone,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Role
                    Row(
                      children: [
                        const Icon(Icons.badge_outlined, color: Colors.purple),
                        const SizedBox(width: 10),
                        const Text(
                          "Role: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            role,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ===== Card Actions =====
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.edit_outlined,
                      color: Colors.blue,
                    ),
                    title: const Text("Edit Profile"),
                    onTap: () {
                      // TODO: Navigate to Edit Profile
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.lock_outline,
                      color: Colors.orange,
                    ),
                    title: const Text("Change Password"),
                    onTap: () {
                      // TODO: Navigate to Change Password
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Logout"),
                    onTap: () {
                      // TODO: Perform Logout
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.book_online, color: Colors.green),
                    title: const Text("View Booking History"),
                    onTap: () {
                      // TODO: Navigate to Booking History
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
