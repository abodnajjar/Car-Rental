import 'car_price_model.dart';
class Car {
  final int carId;
  final String brand;
  final String model;
  final String category;
  final int year;
  final bool status;
  final String imageUrl;
  final List<CarPrice> prices;

  Car({
    required this.carId,
    required this.brand,
    required this.model,
    required this.category,
    required this.year,
    required this.status,
    required this.imageUrl,
    required this.prices,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
       carId: (json["car_id"] as num?)?.toInt()
        ?? (json["id"] as num?)?.toInt()
        ?? 0,
      brand: json["brand"] ?? "",
      model: json["model"] ?? "",
      category: json["category"] ?? "",
      year: json["year"] ?? 0,
      status: json["status"] == true,
      imageUrl: (json["image_url"] ?? "").toString(),
      prices: ((json["prices"] ?? []) as List)
          .map((e) => CarPrice.fromJson(e))
          .toList(),
    );
  }
}
