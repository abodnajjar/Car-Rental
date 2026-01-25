import 'package:flutter/material.dart';
import '../../../config/api_config.dart';

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

  String _buildImageUrl(String? img) {
    if (img == null) return "";

    var v = img.trim();
    if (v.isEmpty) return "";

    if (v.startsWith("http")) return v;

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
    final imgUrl = _buildImageUrl(imageUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imgUrl.isNotEmpty
          ? Image.network(
              imgUrl,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: width,
                  height: height,
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.broken_image,
                    size: 40,
                    color: Colors.white,
                  ),
                );
              },
            )
          : Container(
              width: width,
              height: height,
              color: Colors.grey.shade300,
              child: const Icon(
                Icons.directions_car,
                size: 40,
                color: Colors.white,
              ),
            ),
    );
  }
}
