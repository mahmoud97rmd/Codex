import 'dart:math';

import '../core/models/trade.dart';

class AccountSimulator {
  double balance;
  double lotSize;
  double takeProfit;
  double stopLoss;
  final List<Trade> history = [];

  AccountSimulator({
    this.balance = 10000,
    this.lotSize = 0.1,
    this.takeProfit = 10,
    this.stopLoss = 10,
  });

  Trade openOrder({required TradeDirection direction, required double price}) {
    final trade = Trade(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      direction: direction,
      time: DateTime.now(),
      entry: price,
      takeProfit: direction == TradeDirection.buy ? price + takeProfit : price - takeProfit,
      stopLoss: direction == TradeDirection.buy ? price - stopLoss : price + stopLoss,
    );
    history.add(trade);
    return trade;
  }

  void executeTrade(Trade trade) {
    // Already added in openOrder; PnL handled on close.
  }

  void onPrice(double price, DateTime time) {
    for (final trade in history.where((t) => t.isOpen)) {
      final hitTp = trade.takeProfit != null &&
          ((trade.direction == TradeDirection.buy && price >= trade.takeProfit!) ||
              (trade.direction == TradeDirection.sell && price <= trade.takeProfit!));
      final hitSl = trade.stopLoss != null &&
          ((trade.direction == TradeDirection.buy && price <= trade.stopLoss!) ||
              (trade.direction == TradeDirection.sell && price >= trade.stopLoss!));
      if (hitTp || hitSl) {
        trade.close(price, time);
        balance += _profitValue(trade);
      }
    }
  }

  double _profitValue(Trade trade) {
    final pips = trade.profit ?? 0;
    return pips * lotSize * 100;
  }

  List<EquityPoint> equityCurve() {
    double running = balance;
    final points = <EquityPoint>[];
    for (final trade in history) {
      final profit = trade.profit ?? 0;
      running += profit * lotSize * 100;
      points.add((time: trade.exitTime ?? trade.time, value: running));
    }
    return points;
  }

  double maxDrawdown() {
    final curve = equityCurve();
    double peak = balance;
    double maxDd = 0;
    for (final point in curve) {
      peak = max(peak, point.value);
      maxDd = max(maxDd, (peak - point.value));
    }
    return maxDd;
  }
}
