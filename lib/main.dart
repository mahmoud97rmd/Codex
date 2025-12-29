import 'package:flutter/material.dart';
import 'screens/chart_screen.dart';
import 'screens/indicator_settings_screen.dart';
import 'screens/strategy_settings_screen.dart';
import 'screens/risk_settings_screen.dart';
import 'screens/backtest_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GoldTradingSimulatorApp());
}

class GoldTradingSimulatorApp extends StatelessWidget {
  const GoldTradingSimulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gold Trading Simulator',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
      ),
      initialRoute: ChartScreen.routeName,
      routes: {
        ChartScreen.routeName: (_) => const ChartScreen(),
        IndicatorSettingsScreen.routeName: (_) => const IndicatorSettingsScreen(),
        StrategySettingsScreen.routeName: (_) => const StrategySettingsScreen(),
        RiskSettingsScreen.routeName: (_) => const RiskSettingsScreen(),
        BacktestScreen.routeName: (_) => const BacktestScreen(),
      },
    );
  }
}
