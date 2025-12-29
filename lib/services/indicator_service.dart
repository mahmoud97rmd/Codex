import 'package:flutter/foundation.dart';
import 'package:gold_trading_simulator/core/models/candle.dart';
import 'package:gold_trading_simulator/core/utils/indicator_utils.dart';

class IndicatorService extends ChangeNotifier {
  List<double> ema50 = [];
  List<double> ema150 = [];
  List<double> stochasticK = [];
  List<double> stochasticD = [];
  List<double> stochasticSlow = [];

  int kPeriod = 14;
  int dPeriod = 3;
  int slowPeriod = 3;
  double lowerLevel = 20;
  double upperLevel = 80;

  void recalc(List<Candle> candles) {
    ema50 = IndicatorUtils.ema(candles, 50);
    ema150 = IndicatorUtils.ema(candles, 150);
    final result = IndicatorUtils.stochastic(
      candles,
      kPeriod: kPeriod,
      dPeriod: dPeriod,
      slowPeriod: slowPeriod,
    );
    stochasticK = result.k;
    stochasticD = result.d;
    stochasticSlow = result.slow;
    notifyListeners();
  }

  void updateSettings({
    required int newK,
    required int newD,
    required int newSlow,
    required double lower,
    required double upper,
    required List<Candle> candles,
  }) {
    kPeriod = newK;
    dPeriod = newD;
    slowPeriod = newSlow;
    lowerLevel = lower;
    upperLevel = upper;
    recalc(candles);
  }
}
