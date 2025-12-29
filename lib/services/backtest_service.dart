import 'package:collection/collection.dart';

import '../core/api/oanda_api.dart';
import '../core/models/backtest_result.dart';
import '../core/models/candle.dart';
import '../core/models/trade.dart';
import 'account_simulator.dart';
import 'indicator_service.dart';
import 'strategy_service.dart';

class BacktestService {
  final OandaApi api;

  BacktestService({required this.api});

  Future<BacktestResult> run({
    required CandleGranularity granularity,
    required DateTime from,
    required DateTime to,
    required AccountSimulator account,
    required IndicatorService indicatorService,
  }) async {
    final candles = await api.fetchCandles(
      granularity: granularity,
      from: from,
      to: to,
      count: 500,
    );
    final strategy = StrategyService(indicators: indicatorService, account: account);
    for (final candle in candles) {
      account.onPrice(candle.close, candle.time);
      strategy.onCandles(candles.sublist(0, candles.indexOf(candle) + 1));
    }
    final closed = account.history.whereNot((t) => t.isOpen).toList();
    final winners = closed.where((t) => (t.profit ?? 0) > 0).length;
    final losers = closed.length - winners;
    final profits = closed.map((t) => t.profit ?? 0).toList();
    final maxWin = profits.isEmpty ? 0 : profits.reduce((a, b) => a > b ? a : b);
    final maxLoss = profits.isEmpty ? 0 : profits.reduce((a, b) => a < b ? a : b);
    final grossProfit = profits.where((p) => p > 0).fold(0.0, (a, b) => a + b);
    final grossLoss = profits.where((p) => p < 0).fold(0.0, (a, b) => a + b);
    final net = grossProfit + grossLoss;
    final finalBalance = account.balance + (net * account.lotSize * 100);
    return BacktestResult(
      totalTrades: closed.length,
      winners: winners,
      losers: losers,
      maxWin: maxWin,
      maxLoss: maxLoss,
      grossProfit: grossProfit,
      grossLoss: grossLoss,
      netProfit: net,
      finalBalance: finalBalance,
      equityCurve: account.equityCurve(),
    );
  }
}
