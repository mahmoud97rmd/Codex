import 'package:flutter/foundation.dart';
import 'package:gold_trading_simulator/core/models/candle.dart';
import 'package:gold_trading_simulator/core/models/trade.dart';

class StrategyService extends ChangeNotifier {
  bool enabled = true;
  String granularity = 'M1';

  TradeDirection? evaluateSignal({
    required List<double> ema50,
    required List<double> ema150,
    required List<double> stochasticK,
    required double lowerLevel,
    required double upperLevel,
  }) {
    if (!enabled) return null;
    if (ema50.length < 2 || ema150.length < 2 || stochasticK.length < 2) {
      return null;
    }
    final idx = ema50.length - 1;
    final emaBias = ema50[idx] > ema150[idx] ? TradeDirection.buy : TradeDirection.sell;
    final prevK = stochasticK[idx - 1];
    final currentK = stochasticK[idx];

    if (emaBias == TradeDirection.buy && prevK < lowerLevel && currentK > lowerLevel) {
      return TradeDirection.buy;
    }
    if (emaBias == TradeDirection.sell && prevK > upperLevel && currentK < upperLevel) {
      return TradeDirection.sell;
    }
    return null;
  }

  void updateSettings({required bool isEnabled, required String selectedGranularity}) {
    enabled = isEnabled;
    granularity = selectedGranularity;
    notifyListeners();
  }

  Trade createTrade(Candle candle, TradeDirection direction, double lot, double tp, double sl) {
    return Trade(
      direction: direction,
      entryCandle: candle,
      lotSize: lot,
      takeProfit: tp,
      stopLoss: sl,
    );
  }
}
