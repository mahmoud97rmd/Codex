import 'package:flutter/material.dart';
import 'package:gold_trading_simulator/screens/indicator_settings_screen.dart';
import 'package:gold_trading_simulator/screens/risk_settings_screen.dart';
import 'package:gold_trading_simulator/screens/strategy_settings_screen.dart';
import 'package:gold_trading_simulator/services/account_simulator.dart';
import 'package:gold_trading_simulator/services/indicator_service.dart';
import 'package:gold_trading_simulator/services/price_feed_service.dart';
import 'package:gold_trading_simulator/services/strategy_service.dart';
import 'package:gold_trading_simulator/widgets/countdown_timer.dart';
import 'package:gold_trading_simulator/widgets/stochastic_panel.dart';
import 'package:gold_trading_simulator/widgets/trades_markers.dart';
import 'package:gold_trading_simulator/widgets/web_chart_view.dart';
import 'package:provider/provider.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  String _granularity = 'M1';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final priceFeed = context.read<PriceFeedService>();
      await priceFeed.loadHistory(granularity: _granularity);
      priceFeed.startStreaming();
      context.read<IndicatorService>().recalc(priceFeed.candles);
    });
  }

  void _changeGranularity(String value) async {
    setState(() => _granularity = value);
    final priceFeed = context.read<PriceFeedService>();
    await priceFeed.loadHistory(granularity: value);
    context.read<IndicatorService>().recalc(priceFeed.candles);
    context.read<StrategyService>().granularity = value;
  }

  void _evaluateStrategy() {
    final indicators = context.read<IndicatorService>();
    final strategy = context.read<StrategyService>();
    final priceFeed = context.read<PriceFeedService>();
    final account = context.read<AccountSimulator>();
    if (priceFeed.candles.isEmpty) return;
    final signal = strategy.evaluateSignal(
      ema50: indicators.ema50,
      ema150: indicators.ema150,
      stochasticK: indicators.stochasticK,
      lowerLevel: indicators.lowerLevel,
      upperLevel: indicators.upperLevel,
    );
    if (signal != null) {
      final trade = strategy.createTrade(
        priceFeed.candles.last,
        signal,
        account.lotSize,
        account.takeProfit,
        account.stopLoss,
      );
      account.openTrade(trade);
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceFeed = context.watch<PriceFeedService>();
    final indicators = context.watch<IndicatorService>();
    final account = context.watch<AccountSimulator>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gold Trading Simulator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_suggest),
            onPressed: () => Navigator.pushNamed(context, StrategySettingsScreen.routeName),
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => Navigator.pushNamed(context, IndicatorSettingsScreen.routeName),
          ),
          IconButton(
            icon: const Icon(Icons.shield),
            onPressed: () => Navigator.pushNamed(context, RiskSettingsScreen.routeName),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Text('Timeframe:'),
                const SizedBox(width: 8),
                for (final g in const ['M1', 'M5', 'M15'])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(g),
                      selected: _granularity == g,
                      onSelected: (_) => _changeGranularity(g),
                    ),
                  ),
                const Spacer(),
                CountdownTimerView(duration: priceFeed.timeLeft),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                WebChartView(
                  candles: priceFeed.candles,
                  ema50: indicators.ema50,
                  ema150: indicators.ema150,
                  trades: account.trades,
                ),
                const TradesMarkers(),
              ],
            ),
          ),
          StochasticPanel(
            k: indicators.stochasticK,
            d: indicators.stochasticD,
            slow: indicators.stochasticSlow,
            lower: indicators.lowerLevel,
            upper: indicators.upperLevel,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _evaluateStrategy,
                  child: const Text('Run Strategy'),
                ),
                const SizedBox(width: 12),
                Text('Balance: ${account.balance.toStringAsFixed(2)}'),
                const Spacer(),
                Text('Trades: ${account.trades.length}'),
              ],
            ),
          )
        ],
      ),
    );
  }
}
