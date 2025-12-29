import 'package:flutter/material.dart';

import '../core/api/oanda_api.dart';
import '../core/api/oanda_stream.dart';
import '../core/models/trade.dart';
import '../services/account_simulator.dart';
import '../services/indicator_service.dart';
import '../services/price_feed_service.dart';
import '../services/strategy_service.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/drawing_tools_layer.dart';
import '../widgets/ema_overlay.dart';
import '../widgets/stochastic_panel.dart';
import '../widgets/trades_markers.dart';
import '../widgets/web_chart_view.dart';
import 'indicator_settings_screen.dart';
import 'risk_settings_screen.dart';
import 'strategy_settings_screen.dart';
import 'backtest_screen.dart';

class ChartScreen extends StatefulWidget {
  static const routeName = '/';

  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  late final PriceFeedService _prices;
  late final IndicatorService _indicators;
  late final StrategyService _strategy;
  late final AccountSimulator _account;
  DrawingTool? _tool;
  List<CandleGranularity> frames = [CandleGranularity.m1, CandleGranularity.m5, CandleGranularity.m15];
  CandleGranularity _selected = CandleGranularity.m1;
  DateTime _candleEnd = DateTime.now().add(const Duration(minutes: 1));
  List<Trade> _trades = [];

  @override
  void initState() {
    super.initState();
    const token = String.fromEnvironment('OANDA_TOKEN', defaultValue: '');
    const accountId = String.fromEnvironment('OANDA_ACCOUNT', defaultValue: '');
    final api = OandaApi(token: token, accountId: accountId);
    final stream = OandaStream(token: token, accountId: accountId);
    _indicators = IndicatorService();
    _account = AccountSimulator();
    _strategy = StrategyService(indicators: _indicators, account: _account);
    _prices = PriceFeedService(api: api, stream: stream, granularity: _selected);
    _prices.initialize();
    _prices.prices.listen((candles) {
      if (candles.isEmpty) return;
      setState(() {
        final end = _prices.granularity == CandleGranularity.m1
            ? Duration(minutes: 1)
            : _prices.granularity == CandleGranularity.m5
                ? const Duration(minutes: 5)
                : const Duration(minutes: 15);
        _candleEnd = DateTime.now().add(end);
        _strategy.onCandles(candles);
        _account.onPrice(candles.last.close, candles.last.time);
        _trades = List.from(_account.history);
      });
    });
  }

  @override
  void dispose() {
    _prices.dispose();
    _strategy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gold Trading Simulator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: () => Navigator.of(context).pushNamed(IndicatorSettingsScreen.routeName),
          ),
          IconButton(
            icon: const Icon(Icons.manage_accounts),
            onPressed: () => Navigator.of(context).pushNamed(StrategySettingsScreen.routeName),
          ),
          IconButton(
            icon: const Icon(Icons.shield),
            onPressed: () => Navigator.of(context).pushNamed(RiskSettingsScreen.routeName),
          ),
          IconButton(
            icon: const Icon(Icons.history_toggle_off),
            onPressed: () => Navigator.of(context).pushNamed(BacktestScreen.routeName),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _prices.prices,
        builder: (context, snapshot) {
          final candles = snapshot.data ?? [];
          final indicatorValues = _indicators.calculate(candles);
          final ema50 = indicatorValues.ema50;
          final ema150 = indicatorValues.ema150;
          final k = indicatorValues.k.isNotEmpty ? indicatorValues.k.last : 50.0;
          final d = indicatorValues.d.isNotEmpty ? indicatorValues.d.last : 50.0;
          final slow = indicatorValues.slow.isNotEmpty ? indicatorValues.slow.last : 50.0;
          return Column(
            children: [
              _frameSelector(),
              if (candles.isNotEmpty)
                Expanded(
                  child: Stack(
                    children: [
                      WebChartView(candles: candles, ema50: ema50, ema150: ema150),
                      Positioned(top: 12, left: 12, child: EmaOverlay(ema50: ema50.isNotEmpty ? ema50.last : 0, ema150: ema150.isNotEmpty ? ema150.last : 0)),
                      Positioned(top: 12, right: 12, child: CountdownTimer(endTime: _candleEnd)),
                      Positioned(bottom: 12, left: 12, child: StochasticPanel(k: k, d: d, slow: slow)),
                      DrawingToolsLayer(activeTool: _tool),
                    ],
                  ),
                )
              else
                const Expanded(child: Center(child: CircularProgressIndicator())),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TradesMarkers(trades: _trades),
              ),
              _toolPicker(),
            ],
          );
        },
      ),
    );
  }

  Widget _frameSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: frames
          .map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(f.apiValue),
                selected: _selected == f,
                onSelected: (_) {
                  setState(() => _selected = f);
                  _prices.changeGranularity(f);
                },
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _toolPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _toolButton(DrawingTool.trendline, Icons.show_chart),
        _toolButton(DrawingTool.horizontal, Icons.horizontal_rule),
        _toolButton(DrawingTool.rectangle, Icons.crop_square),
      ],
    );
  }

  Widget _toolButton(DrawingTool tool, IconData icon) {
    final active = _tool == tool;
    return IconButton(
      icon: Icon(icon, color: active ? Colors.amber : Colors.white),
      onPressed: () => setState(() => _tool = active ? null : tool),
    );
  }
}
