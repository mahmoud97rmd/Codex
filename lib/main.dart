import 'package:flutter/material.dart';
import 'package:gold_trading_simulator/screens/backtest_screen.dart';
import 'package:gold_trading_simulator/screens/chart_screen.dart';
import 'package:gold_trading_simulator/screens/indicator_settings_screen.dart';
import 'package:gold_trading_simulator/screens/risk_settings_screen.dart';
import 'package:gold_trading_simulator/screens/strategy_settings_screen.dart';
import 'package:gold_trading_simulator/services/account_simulator.dart';
import 'package:gold_trading_simulator/services/backtest_service.dart';
import 'package:gold_trading_simulator/services/indicator_service.dart';
import 'package:gold_trading_simulator/services/price_feed_service.dart';
import 'package:gold_trading_simulator/services/strategy_service.dart';
import 'package:gold_trading_simulator/core/api/oanda_api.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const GoldTradingSimulatorApp());
}

class GoldTradingSimulatorApp extends StatelessWidget {
  const GoldTradingSimulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final oanda = OandaApi(apiToken: 'YOUR_TOKEN', accountId: 'YOUR_ACCOUNT_ID');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PriceFeedService(api: oanda)),
        ChangeNotifierProvider(create: (_) => IndicatorService()),
        ChangeNotifierProvider(create: (_) => StrategyService()),
        ChangeNotifierProvider(create: (_) => AccountSimulator()),
        Provider(create: (_) => BacktestService()),
      ],
      child: MaterialApp(
        title: 'Gold Trading Simulator',
        theme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.amber),
        ),
        routes: {
          '/': (_) => const ChartScreen(),
          IndicatorSettingsScreen.routeName: (_) => const IndicatorSettingsScreen(),
          StrategySettingsScreen.routeName: (_) => const StrategySettingsScreen(),
          RiskSettingsScreen.routeName: (_) => const RiskSettingsScreen(),
          BacktestScreen.routeName: (_) => const BacktestScreen(),
        },
      ),
    );
  }
}
