import 'package:flutter/material.dart';

class ShimmerText extends StatelessWidget {
  final double length;
  final double height;

  const ShimmerText({super.key, required this.length, this.height = 16});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Container(
        height: height,
        width: 16 * length,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.grey.shade800,
        ),
      ),
    );
  }
}
