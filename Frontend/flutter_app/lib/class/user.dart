class User {
  String uid;
  String fullName;
  String email;
  String phone;
  String role;
  String? drivingLicenseNo;
  double? salary;


  User({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    this.drivingLicenseNo,
    this.salary,
  });


  String getId() => uid;
  String getName() => fullName;
  String getEmail() => email;
  String getPhone() => phone;
  String getRole() => role;
  String? getDrivingLicenseNo() => drivingLicenseNo;
  double? getSalary() => salary;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'].toString(),
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      drivingLicenseNo: json['driving_license_no'],
      salary: json['salary'] == null ? null : (json['salary'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'driving_license_no': drivingLicenseNo,
      'salary': salary,
    };
  }
}
