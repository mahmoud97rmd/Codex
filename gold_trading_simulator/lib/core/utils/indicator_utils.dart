import 'dart:math';

import 'package:gold_trading_simulator/core/models/candle.dart';

class IndicatorUtils {
  static List<double> ema(List<Candle> candles, int period) {
    if (candles.isEmpty) return [];
    final k = 2 / (period + 1);
    final values = <double>[];
    double? emaPrev;
    for (final candle in candles) {
      final price = candle.close;
      if (emaPrev == null) {
        emaPrev = price;
      } else {
        emaPrev = price * k + emaPrev * (1 - k);
      }
      values.add(emaPrev);
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
    for (int i = 0; i < candles.length; i++) {
      final start = max(0, i - kPeriod + 1);
      final slice = candles.sublist(start, i + 1);
      final high = slice.map((c) => c.high).reduce(max);
      final low = slice.map((c) => c.low).reduce(min);
      final currentClose = candles[i].close;
      final range = high - low == 0 ? 1 : high - low;
      final kVal = ((currentClose - low) / range) * 100;
      kValues.add(kVal);
    }

    List<double> simpleSmooth(List<double> input, int length) {
      final out = <double>[];
      for (int i = 0; i < input.length; i++) {
        final start = max(0, i - length + 1);
        final slice = input.sublist(start, i + 1);
        out.add(slice.reduce((a, b) => a + b) / slice.length);
      }
      return out;
    }

    final dValues = simpleSmooth(kValues, dPeriod);
    final slowValues = simpleSmooth(dValues, slowPeriod);
    return (k: kValues, d: dValues, slow: slowValues);
  }
}
