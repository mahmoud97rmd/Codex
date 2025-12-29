import 'package:flutter/material.dart';

class CountdownTimerView extends StatelessWidget {
  const CountdownTimerView({super.key, required this.duration});

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Chip(
      label: Text('Candle: $minutes:$seconds'),
      avatar: const Icon(Icons.timer, size: 16),
    );
  }
}
