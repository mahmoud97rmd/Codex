import 'package:flutter/foundation.dart';
import 'package:gold_trading_simulator/core/models/trade.dart';

class AccountSimulator extends ChangeNotifier {
  double balance;
  double lotSize;
  double takeProfit;
  double stopLoss;
  final List<Trade> trades = [];

  AccountSimulator({
    this.balance = 10000,
    this.lotSize = 1,
    this.takeProfit = 5,
    this.stopLoss = -5,
  });

  void update({
    required double newBalance,
    required double newLot,
    required double newTp,
    required double newSl,
  }) {
    balance = newBalance;
    lotSize = newLot;
    takeProfit = newTp;
    stopLoss = newSl;
    notifyListeners();
  }

  Trade openTrade(Trade trade) {
    trades.add(trade);
    notifyListeners();
    return trade;
  }

  void evaluateOpenTrades(double price, DateTime time) {
    for (final trade in trades.where((t) => t.isOpen)) {
      final pnl = trade.currentPnl(price);
      if (pnl >= trade.takeProfit || pnl <= trade.stopLoss) {
        _closeTrade(trade, price, time);
      }
    }
  }

  void _closeTrade(Trade trade, double price, DateTime time) {
    trade.close(price, time);
    balance += trade.realizedPnl();
    notifyListeners();
  }

  List<EquityPoint> equityCurve() {
    double runningBalance = balance;
    final points = <EquityPoint>[];
    for (final trade in trades) {
      runningBalance += trade.realizedPnl();
      points.add(EquityPoint(trade.exitTime ?? trade.entryCandle.time, runningBalance));
    }
    return points;
  }
}
