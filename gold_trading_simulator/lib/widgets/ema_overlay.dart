import 'package:flutter/material.dart';

class EmaOverlay extends StatelessWidget {
  const EmaOverlay({super.key, required this.ema50, required this.ema150});

  final double? ema50;
  final double? ema150;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('EMA 50: ${ema50?.toStringAsFixed(2) ?? '--'}', style: const TextStyle(color: Colors.blue)),
          Text('EMA 150: ${ema150?.toStringAsFixed(2) ?? '--'}', style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
