class Car {
  final int id;
  final String brand;
  final String model;
  final String category;
  final int year;
  final bool status;
  final String image;

  Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.category,
    required this.year,
    required this.status,
    required this.image,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      brand: json['brand'],
      model: json['model'],
      category: json['category'],
      year: json['year'],
      status: json['status'],
      image: json['image'] ?? '',
    );
  }
}
