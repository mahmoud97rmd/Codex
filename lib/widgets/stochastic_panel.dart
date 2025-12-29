import 'package:flutter/material.dart';

class StochasticPanel extends StatelessWidget {
  final double k;
  final double d;
  final double slow;
  final int lowLevel;
  final int highLevel;

  const StochasticPanel({
    super.key,
    required this.k,
    required this.d,
    required this.slow,
    this.lowLevel = 20,
    this.highLevel = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Stochastic', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _line('K', k, Colors.blue),
          _line('D', d, Colors.red),
          _line('Slow', slow, Colors.orange),
          const SizedBox(height: 8),
          Text('Levels: $lowLevel / $highLevel'),
        ],
      ),
    );
  }

  Widget _line(String label, double value, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 4, color: color, margin: const EdgeInsets.only(right: 6)),
        Text('$label: ${value.toStringAsFixed(2)}'),
      ],
    );
  }
}
