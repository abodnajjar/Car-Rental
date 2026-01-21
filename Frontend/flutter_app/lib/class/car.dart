import 'car_price.dart';

class Car {
  final int carId;
  String brand;
  String model;
  String category;
  int year;
  String status;
  String? imageUrl;             
  List<CarPrice> prices;       

  Car({
    required this.carId,
    required this.brand,
    required this.model,
    required this.category,
    required this.year,
    required this.status,
    this.imageUrl,
    List<CarPrice>? prices,
  }) : prices = prices ?? [];


  String getBrand() => brand;
  void setBrand(String v) => brand = v;

  String getModel() => model;
  void setModel(String v) => model = v;

  String getCategory() => category;
  void setCategory(String v) => category = v;

  int getYear() => year;
  void setYear(int v) => year = v;

  String getStatus() => status;
  void setStatus(String v) => status = v;

  String? getImageUrl() => imageUrl;
  void setImageUrl(String? v) => imageUrl = v;

  void addPrice(CarPrice p) => prices.add(p);

  double? getPriceForDay(String day) {
    for (final p in prices) {
      if (p.day == day) return p.price;
    }
    return null;
  }

  List<double> getPricesOnly() => prices.map((p) => p.price).toList();


factory Car.fromJson(Map<String, dynamic> json) {
  return Car(
    carId: json['car_id'],
    brand: json['brand'],
    model: json['model'],
    category: json['category'],
    year: json['year'],
    status: json['status'],
    imageUrl: json['image_url'],
    prices: json['prices']
        .map((p) => CarPrice.fromJson(p))
        .toList(),
  );
}

  Map<String, dynamic> toJson() {
    return {
      'car_id': carId,
      'brand': brand,
      'model': model,
      'category': category,
      'year': year,
      'status': status,
      'image_url': imageUrl,
      'prices': prices.map((p) => p.toJson()).toList(),
    };
  }
}
