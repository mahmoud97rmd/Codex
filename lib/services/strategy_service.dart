import 'dart:async';

import '../core/models/candle.dart';
import '../core/models/trade.dart';
import 'account_simulator.dart';
import 'indicator_service.dart';

class StrategyService {
  final IndicatorService indicators;
  final AccountSimulator account;
  bool enabled;
  int stochasticLow;
  int stochasticHigh;

  StrategyService({
    required this.indicators,
    required this.account,
    this.enabled = true,
    this.stochasticLow = 20,
    this.stochasticHigh = 80,
  });

  final StreamController<Trade> _trades = StreamController.broadcast();
  Stream<Trade> get trades => _trades.stream;

  void onCandles(List<Candle> candles) {
    if (!enabled || candles.length < 2) return;
    final signal = _evaluate(candles);
    if (signal != null) {
      account.executeTrade(signal);
      _trades.add(signal);
    }
  }

  Trade? _evaluate(List<Candle> candles) {
    final computed = indicators.calculate(candles);
    final k = computed.k;
    if (k.length < 2) return null;
    final last = k[k.length - 1];
    final previous = k[k.length - 2];
    final ema50 = computed.ema50.last;
    final ema150 = computed.ema150.last;
    final lastCandle = candles.last;
    if (ema50 > ema150 && previous < stochasticLow && last > stochasticLow) {
      return account.openOrder(direction: TradeDirection.buy, price: lastCandle.close);
    }
    if (ema150 > ema50 && previous > stochasticHigh && last < stochasticHigh) {
      return account.openOrder(direction: TradeDirection.sell, price: lastCandle.close);
    }
    return null;
  }

  void dispose() {
    _trades.close();
  }
}
