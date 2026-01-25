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
      id: json["id"] ?? 0,
      day: json["day"] ?? "",
      price: json["price"] is num
          ? (json["price"] as num).toDouble()
          : double.tryParse(json["price"]?.toString() ?? "0") ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "day": day,
      "price": price,
    };
  }
}
