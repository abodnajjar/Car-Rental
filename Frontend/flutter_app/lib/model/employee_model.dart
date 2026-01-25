class Employee {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final double salary;

  Employee({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.salary,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      uid: json['uid'].toString(),
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      salary: json['salary'] == null
          ? 0.0
          : (json['salary'] as num).toDouble(),
    );
  }
}
