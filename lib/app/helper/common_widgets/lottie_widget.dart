import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieWidget extends StatelessWidget {
  final String? url;
  final double? height;
  final EdgeInsets padding;

  const LottieWidget({
    super.key,
    required this.url,
    this.height,
    this.padding = EdgeInsets.zero
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Lottie.network(
        url!,
        height: height ?? 200,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => SizedBox(),
      ),
    );
  }
}
