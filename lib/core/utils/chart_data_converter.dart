import 'dart:convert';

import '../models/candle.dart';

class ChartDataConverter {
  static String candlesToJson(List<Candle> candles) {
    final formatted = candles
        .map((c) => {
              'time': c.time.millisecondsSinceEpoch ~/ 1000,
              'open': c.open,
              'high': c.high,
              'low': c.low,
              'close': c.close,
            })
        .toList();
    return jsonEncode(formatted);
  }
}
