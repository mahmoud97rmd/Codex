import '../core/models/candle.dart';
import '../core/utils/indicator_utils.dart';

class IndicatorService {
  int kPeriod;
  int dPeriod;
  int slowPeriod;

  IndicatorService({this.kPeriod = 14, this.dPeriod = 3, this.slowPeriod = 3});

  ({List<double> ema50, List<double> ema150, List<double> k, List<double> d, List<double> slow})
      calculate(List<Candle> candles) {
    final ema50 = IndicatorUtils.ema(candles, 50);
    final ema150 = IndicatorUtils.ema(candles, 150);
    final stochastic = IndicatorUtils.stochastic(candles, kPeriod: kPeriod, dPeriod: dPeriod, slowPeriod: slowPeriod);
    return (
      ema50: ema50,
      ema150: ema150,
      k: stochastic.k,
      d: stochastic.d,
      slow: stochastic.slow,
    );
  }

  void updateSettings({required int k, required int d, required int slow}) {
    kPeriod = k;
    dPeriod = d;
    slowPeriod = slow;
  }
}
