import 'package:flutter/material.dart';
import 'lottie_widget.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? lottieUrl;
  final double? lottieHeight;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.lottieUrl,
    this.lottieHeight,
    this.icon,
    this.iconSize = 64,
    this.iconColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: iconSize,
              color: iconColor,
            ),
          if (lottieUrl != null)
            LottieWidget(
              url: lottieUrl,
              height: lottieHeight,
              padding: const EdgeInsets.only(bottom: 16),
            ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
