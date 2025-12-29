import 'package:flutter/material.dart';
import 'package:gold_trading_simulator/services/backtest_service.dart';
import 'package:gold_trading_simulator/services/indicator_service.dart';
import 'package:gold_trading_simulator/services/price_feed_service.dart';
import 'package:gold_trading_simulator/services/strategy_service.dart';
import 'package:provider/provider.dart';

class BacktestScreen extends StatefulWidget {
  const BacktestScreen({super.key});
  static const routeName = '/backtest';

  @override
  State<BacktestScreen> createState() => _BacktestScreenState();
}

class _BacktestScreenState extends State<BacktestScreen> {
  DateTimeRange? range;
  String report = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backtest')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final now = DateTime.now();
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: now.subtract(const Duration(days: 365)),
                  lastDate: now,
                );
                if (picked != null) {
                  setState(() => range = picked);
                }
              },
              child: const Text('Select Date Range'),
            ),
            ElevatedButton(
              onPressed: () {
                final priceFeed = context.read<PriceFeedService>();
                final indicators = context.read<IndicatorService>();
                final strategy = context.read<StrategyService>();
                final backtester = context.read<BacktestService>();
                final result = backtester.run(
                  candles: priceFeed.candles,
                  indicators: indicators,
                  strategy: strategy,
                  startingBalance: 10000,
                  lot: 1,
                  tp: 5,
                  sl: -5,
                );
                setState(() {
                  report = '''Total trades: ${result.totalTrades}
Wins: ${result.winningTrades}
Losses: ${result.losingTrades}
Max win: ${result.maxWin.toStringAsFixed(2)}
Max loss: ${result.maxLoss.toStringAsFixed(2)}
Net profit: ${result.netProfit.toStringAsFixed(2)}
Final balance: ${result.finalBalance.toStringAsFixed(2)}''';
                });
              },
              child: const Text('Run Backtest'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(report),
              ),
            )
          ],
        ),
      ),
    );
  }
}
