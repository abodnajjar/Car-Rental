class CarPrice {
  final String day;    
  final double price;

  CarPrice({
    required this.day,
    required this.price,
  });

factory CarPrice.fromJson(Map<String, dynamic> json) {
  return CarPrice(
    day: json['day'],
    price: json['price'],
  );
}

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'price': price,
    };
  }
}
