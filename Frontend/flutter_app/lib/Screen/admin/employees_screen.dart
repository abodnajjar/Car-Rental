import 'package:flutter/material.dart';

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // عدد الموظفين (مؤقت)
        itemBuilder: (context, index) {
          return _employeeCard();
        },
      ),

      // زر الإضافة (+)
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey.shade300,
        elevation: 4,
        onPressed: () {
          // TODO: فتح صفحة Add Employee
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  // ================= Employee Card =================
  Widget _employeeCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // صورة الموظف
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                "img",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          
          const Text(
            "Employee",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
