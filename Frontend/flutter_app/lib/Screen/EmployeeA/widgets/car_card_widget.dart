import 'package:flutter/material.dart';
import '../../../config/api_config.dart';
import '../../../model/car_model.dart';

class CarCardWidget extends StatelessWidget {
  final Car car;

  const CarCardWidget({
    super.key,
    required this.car,
  });

  double? _minPrice(Car car) {
    if (car.prices.isEmpty) return null;

    double? minPrice;
    for (final p in car.prices) {
      final value = p.price; 
      if (value <= 0) continue; 
      minPrice = (minPrice == null) ? value : (value < minPrice ? value : minPrice);
    }
    return minPrice;
  }

  String _buildImageUrl(String img) {
    var v = img.trim();
    if (v.isEmpty) return "";

    if (v.startsWith("http://") || v.startsWith("https://")) return v;

    if (v.startsWith("/uploads")) {
      return "${ApiConfig.baseUrl}$v";
    }

    if (v.startsWith("uploads/")) {
      return "${ApiConfig.baseUrl}/$v";
    }

    return "${ApiConfig.baseUrl}/uploads/cars/$v";
  }

  @override
  Widget build(BuildContext context) {
    final price = _minPrice(car);
    final isAvailable = car.status;

    final imgUrl = _buildImageUrl(car.imageUrl);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 110,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade200,
                image: imgUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imgUrl),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          debugPrint("IMAGE ERROR: $exception");
                        },
                      )
                    : null,
              ),
              child: imgUrl.isEmpty
                  ? const Icon(
                      Icons.directions_car,
                      size: 40,
                      color: Colors.grey,
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${car.brand} ${car.model}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? Colors.green.withOpacity(0.12)
                              : Colors.red.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isAvailable ? 'Available' : 'Unavailable',
                          style: TextStyle(
                            color: isAvailable ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${car.category} • ${car.year}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price != null
                        ? '${price.toStringAsFixed(0)} NIS / day'
                        : 'Price not set',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: price != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
