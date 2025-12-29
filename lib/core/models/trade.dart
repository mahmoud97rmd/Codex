import 'package:gold_trading_simulator/core/models/candle.dart';

enum TradeDirection { buy, sell }

typedef EquityPoint = MapEntry<DateTime, double>;

class Trade {
  final TradeDirection direction;
  final Candle entryCandle;
  final double lotSize;
  final double takeProfit;
  final double stopLoss;
  double? exitPrice;
  DateTime? exitTime;

  Trade({
    required this.direction,
    required this.entryCandle,
    required this.lotSize,
    required this.takeProfit,
    required this.stopLoss,
  });

  bool get isOpen => exitPrice == null;

  double currentPnl(double price) {
    final delta = direction == TradeDirection.buy
        ? price - entryCandle.close
        : entryCandle.close - price;
    return delta * lotSize;
  }

  double realizedPnl() {
    if (exitPrice == null) return 0;
    final delta = direction == TradeDirection.buy
        ? (exitPrice! - entryCandle.close)
        : (entryCandle.close - exitPrice!);
    return delta * lotSize;
  }

  void close(double price, DateTime time) {
    exitPrice = price;
    exitTime = time;
  }
}
