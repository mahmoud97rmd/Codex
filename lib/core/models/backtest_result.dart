import 'trade.dart';

class BacktestResult {
  final int totalTrades;
  final int winners;
  final int losers;
  final double maxWin;
  final double maxLoss;
  final double grossProfit;
  final double grossLoss;
  final double netProfit;
  final double finalBalance;
  final List<EquityPoint> equityCurve;

  const BacktestResult({
    required this.totalTrades,
    required this.winners,
    required this.losers,
    required this.maxWin,
    required this.maxLoss,
    required this.grossProfit,
    required this.grossLoss,
    required this.netProfit,
    required this.finalBalance,
    required this.equityCurve,
  });
}
