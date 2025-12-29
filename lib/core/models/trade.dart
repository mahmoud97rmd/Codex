enum TradeDirection { buy, sell }

typedef EquityPoint = ({DateTime time, double value});

class Trade {
  final String id;
  final TradeDirection direction;
  final DateTime time;
  final double entry;
  final double? takeProfit;
  final double? stopLoss;
  double? exit;
  DateTime? exitTime;
  double? profit;

  Trade({
    required this.id,
    required this.direction,
    required this.time,
    required this.entry,
    this.takeProfit,
    this.stopLoss,
  });

  bool get isOpen => exit == null;

  void close(double exitPrice, DateTime time) {
    exit = exitPrice;
    exitTime = time;
    profit = (direction == TradeDirection.buy ? exitPrice - entry : entry - exitPrice);
  }
}
