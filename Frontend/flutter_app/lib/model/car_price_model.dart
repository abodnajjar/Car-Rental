class CarPrice {
  final int id;
  final String day;
  final double price;

  CarPrice({
    required this.id,
    required this.day,
    required this.price,
  });

  factory CarPrice.fromJson(Map<String, dynamic> json) {
    return CarPrice(
      id: json['id'],
      day: json['day'],
      price: (json['price'] as num).toDouble(),
    );
  }
}
