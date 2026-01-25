import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRefresh;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final content = [
      const SizedBox(height: 60),
      Icon(
        icon,
        color: Colors.grey.shade400,
        size: 72,
      ),
      const SizedBox(height: 16),
      Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(height: 8),
      Center(
        child: Text(
          subtitle,
          textAlign: TextAlign.center,
        ),
      ),
    ];

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: () async => onRefresh!(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: content,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: content,
    );
  }
}
