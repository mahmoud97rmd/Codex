import 'package:flutter/material.dart';

import '../core/models/trade.dart';

class TradesMarkers extends StatelessWidget {
  final List<Trade> trades;

  const TradesMarkers({super.key, required this.trades});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: trades
          .map(
            (t) => Chip(
              avatar: Icon(t.direction == TradeDirection.buy ? Icons.arrow_upward : Icons.arrow_downward,
                  color: t.direction == TradeDirection.buy ? Colors.green : Colors.red),
              label: Text('${t.direction.name.toUpperCase()} @ ${t.entry.toStringAsFixed(2)}'),
            ),
          )
          .toList(),
    );
  }
}
