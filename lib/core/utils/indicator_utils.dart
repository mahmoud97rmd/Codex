import 'dart:math';

import '../models/candle.dart';

class IndicatorUtils {
  static List<double> ema(List<Candle> candles, int period) {
    if (candles.isEmpty) return [];
    final k = 2 / (period + 1);
    final values = <double>[];
    double emaValue = candles.first.close;
    for (final candle in candles) {
      emaValue = candle.close * k + emaValue * (1 - k);
      values.add(emaValue);
    }
    return values;
  }

  static ({List<double> k, List<double> d, List<double> slow}) stochastic(
    List<Candle> candles, {
    int kPeriod = 14,
    int dPeriod = 3,
    int slowPeriod = 3,
  }) {
    final kValues = <double>[];
    for (var i = 0; i < candles.length; i++) {
      final start = max(0, i - kPeriod + 1);
      final slice = candles.sublist(start, i + 1);
      final high = slice.map((c) => c.high).reduce(max);
      final low = slice.map((c) => c.low).reduce(min);
      final current = candles[i].close;
      final value = low == high ? 50.0 : ((current - low) / (high - low)) * 100;
      kValues.add(value);
    }
    final dValues = _simpleMA(kValues, dPeriod);
    final slowValues = _simpleMA(dValues, slowPeriod);
    return (k: kValues, d: dValues, slow: slowValues);
  }

  static List<double> _simpleMA(List<double> values, int period) {
    final ma = <double>[];
    for (var i = 0; i < values.length; i++) {
      final start = max(0, i - period + 1);
      final slice = values.sublist(start, i + 1);
      final avg = slice.reduce((a, b) => a + b) / slice.length;
      ma.add(avg);
    }
    return ma;
  }
}
