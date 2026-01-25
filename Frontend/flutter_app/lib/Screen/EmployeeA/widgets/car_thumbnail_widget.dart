import 'package:flutter/material.dart';

class CarThumbnailWidget extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;

  const CarThumbnailWidget({
    super.key,
    required this.imageUrl,
    this.width = 110,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    final imgUrl = imageUrl ?? '';
    final useNetwork = imgUrl.startsWith('http');
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade300,
        image: imgUrl.isNotEmpty
            ? DecorationImage(
                image: useNetwork 
                    ? NetworkImage(imgUrl) as ImageProvider
                    : AssetImage('assets/car_images/$imgUrl'),
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
              color: Colors.white,
            )
          : null,
    );
  }
}
