import 'package:flutter/material.dart';

class EmaOverlay extends StatelessWidget {
  final double ema50;
  final double ema150;

  const EmaOverlay({super.key, required this.ema50, required this.ema150});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Container(width: 12, height: 3, color: Colors.blue), const SizedBox(width: 6), Text('EMA50: ${ema50.toStringAsFixed(2)}')]),
          const SizedBox(height: 4),
          Row(children: [Container(width: 12, height: 3, color: Colors.red), const SizedBox(width: 6), Text('EMA150: ${ema150.toStringAsFixed(2)}')]),
        ],
      ),
    );
  }
}
