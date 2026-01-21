class Employee {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String? drivingLicenseNo;
  final double? salary;

  Employee({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.drivingLicenseNo,
    this.salary,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      uid: json['uid'].toString(),
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      drivingLicenseNo: json['driving_license_no'],
      salary: json['salary'] == null
          ? null
          : double.parse(json['salary'].toString()),
    );
  }
}
