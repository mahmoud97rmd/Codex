import 'package:gold_trading_simulator/core/models/trade.dart';

class BacktestResult {
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double maxWin;
  final double maxLoss;
  final double totalProfit;
  final double totalLoss;
  final double netProfit;
  final double finalBalance;
  final List<EquityPoint> equityCurve;

  BacktestResult({
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.maxWin,
    required this.maxLoss,
    required this.totalProfit,
    required this.totalLoss,
    required this.netProfit,
    required this.finalBalance,
    required this.equityCurve,
  });
}
