import 'package:flutter/material.dart';
import '../../../api/employees.dart';
import '../../../model/employee_model.dart';
import 'EmployeeDetails.dart';
import 'AddEmployees.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  // ================================
  // Load employees from API
  // ================================
Future<void> _loadEmployees() async {
  try {
    debugPrint("CALLING API...");

    final data = await EmployeesApi.getEmployees();

    debugPrint("RAW DATA: $data");
    debugPrint("EMPLOYEES COUNT: ${data.length}");

    if (!mounted) return;

    setState(() {
      _allEmployees = List<Employee>.from(data);
      _filteredEmployees = List<Employee>.from(data);
      _loading = false;
    });
  } catch (e) {
    debugPrint("ERROR LOADING EMPLOYEES: $e");
    if (!mounted) return;
    setState(() => _loading = false);
  }
}

  // ================================
  // Live search filter
  // ================================
  void _onSearch(String value) {
    setState(() {
      _filteredEmployees = _allEmployees
          .where(
            (e) => e.fullName
                .toLowerCase()
                .contains(value.toLowerCase()),
          )
          .toList();
    });
  }

  // ================================
  // Confirm delete dialog
  // ================================
  void _confirmDelete(Employee emp) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Employee"),
        content: Text(
          "Are you sure you want to delete ${emp.fullName}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _deleteEmployee(emp.uid);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ================================
  // Delete employee
  // ================================
  Future<void> _deleteEmployee(String uid) async {
    try {
      await EmployeesApi.deleteEmployee(uid);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Employee deleted")),
      );

      _loadEmployees(); // 🔄 refresh
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: Column(
        children: [
          // 🔍 Search Box
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: "Search employee by name",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ================================
          // Employees List
          // ================================
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEmployees.isEmpty
                    ? const Center(child: Text("No employees found"))
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredEmployees.length,
                        itemBuilder: (context, index) {
                          return _employeeCard(
                            _filteredEmployees[index],
                          );
                        },
                      ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey.shade300,
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEmployeeScreen(),
            ),
          );

          if (added == true && mounted) {
            _loadEmployees();
          }
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  // ================================
  // Employee Card
  // ================================
  Widget _employeeCard(Employee emp) {
    return InkWell(
      onTap: () async {
        final updated = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmployeeDetailsScreen(employee: emp),
          ),
        );

        if (updated == true && mounted) {
          _loadEmployees();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.person),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emp.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    emp.email,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    emp.phone,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(emp),
            ),
          ],
        ),
      ),
    );
  }
}
