import 'package:gold_trading_simulator/core/models/backtest_result.dart';
import 'package:gold_trading_simulator/core/models/candle.dart';
import 'package:gold_trading_simulator/core/models/trade.dart';
import 'package:gold_trading_simulator/services/indicator_service.dart';
import 'package:gold_trading_simulator/services/strategy_service.dart';

class BacktestService {
  BacktestResult run({
    required List<Candle> candles,
    required IndicatorService indicators,
    required StrategyService strategy,
    required double startingBalance,
    required double lot,
    required double tp,
    required double sl,
  }) {
    double balance = startingBalance;
    final trades = <Trade>[];
    indicators.recalc(candles);

    for (int i = 1; i < candles.length; i++) {
      final signal = strategy.evaluateSignal(
        ema50: indicators.ema50.sublist(0, i + 1),
        ema150: indicators.ema150.sublist(0, i + 1),
        stochasticK: indicators.stochasticK.sublist(0, i + 1),
        lowerLevel: indicators.lowerLevel,
        upperLevel: indicators.upperLevel,
      );
      final candle = candles[i];
      if (signal != null) {
        final trade = Trade(
          direction: signal,
          entryCandle: candle,
          lotSize: lot,
          takeProfit: tp,
          stopLoss: sl,
        );
        // Exit at next candle close for simulation simplicity.
        if (i + 1 < candles.length) {
          final exitPrice = candles[i + 1].close;
          trade.close(exitPrice, candles[i + 1].time);
        } else {
          trade.close(candle.close, candle.time);
        }
        balance += trade.realizedPnl();
        trades.add(trade);
      }
    }

    final wins = trades.where((t) => t.realizedPnl() > 0).length;
    final losses = trades.length - wins;
    final profits = trades.where((t) => t.realizedPnl() > 0).map((t) => t.realizedPnl());
    final lossesPnl = trades.where((t) => t.realizedPnl() <= 0).map((t) => t.realizedPnl());
    final maxWin = profits.isEmpty ? 0 : profits.reduce((a, b) => a > b ? a : b);
    final maxLoss = lossesPnl.isEmpty ? 0 : lossesPnl.reduce((a, b) => a < b ? a : b);

    double totalProfit = 0;
    for (final p in profits) {
      totalProfit += p;
    }
    double totalLoss = 0;
    for (final l in lossesPnl) {
      totalLoss += l;
    }

    final equityCurve = <EquityPoint>[];
    double runningBalance = startingBalance;
    for (final trade in trades) {
      runningBalance += trade.realizedPnl();
      equityCurve.add(EquityPoint(trade.exitTime ?? trade.entryCandle.time, runningBalance));
    }

    return BacktestResult(
      totalTrades: trades.length,
      winningTrades: wins,
      losingTrades: losses,
      maxWin: maxWin,
      maxLoss: maxLoss,
      totalProfit: totalProfit,
      totalLoss: totalLoss,
      netProfit: totalProfit + totalLoss,
      finalBalance: balance,
      equityCurve: equityCurve,
    );
  }
}
