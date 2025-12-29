import 'dart:convert';

import 'package:gold_trading_simulator/core/models/candle.dart';

class ChartDataConverter {
  static String candlesToJson(List<Candle> candles) {
    final mapped = candles
        .map((c) => {
              'time': c.time.millisecondsSinceEpoch ~/ 1000,
              'open': c.open,
              'high': c.high,
              'low': c.low,
              'close': c.close,
            })
        .toList();
    return jsonEncode(mapped);
  }

  static String lineSeries(List<double> values, List<Candle> candles) {
    final output = <Map<String, dynamic>>[];
    for (int i = 0; i < values.length && i < candles.length; i++) {
      output.add({
        'time': candles[i].time.millisecondsSinceEpoch ~/ 1000,
        'value': values[i],
      });
    }
    return jsonEncode(output);
  }
}
