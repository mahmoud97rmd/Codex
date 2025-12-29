import 'package:flutter/material.dart';

import '../core/api/oanda_api.dart';
import '../services/account_simulator.dart';
import '../services/backtest_service.dart';
import '../services/indicator_service.dart';

class BacktestScreen extends StatefulWidget {
  static const routeName = '/backtest';

  const BacktestScreen({super.key});

  @override
  State<BacktestScreen> createState() => _BacktestScreenState();
}

class _BacktestScreenState extends State<BacktestScreen> {
  DateTimeRange? range;
  bool running = false;
  String? report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backtest')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () async {
                final now = DateTime.now();
                final result = await showDateRangePicker(
                  context: context,
                  firstDate: now.subtract(const Duration(days: 365)),
                  lastDate: now,
                  initialDateRange: range,
                );
                if (result != null) setState(() => range = result);
              },
              child: Text(range == null
                  ? 'Choose date range'
                  : '${range!.start.toLocal()} - ${range!.end.toLocal()}'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: running || range == null
                  ? null
                  : () async {
                      setState(() {
                        running = true;
                        report = null;
                      });
                      const token = String.fromEnvironment('OANDA_TOKEN', defaultValue: '');
                      const accountId = String.fromEnvironment('OANDA_ACCOUNT', defaultValue: '');
                      final api = OandaApi(token: token, accountId: accountId);
                      final backtest = BacktestService(api: api);
                      final result = await backtest.run(
                        granularity: CandleGranularity.m5,
                        from: range!.start,
                        to: range!.end,
                        account: AccountSimulator(),
                        indicatorService: IndicatorService(),
                      );
                      setState(() {
                        running = false;
                        report = _format(result);
                      });
                    },
              child: const Text('Run'),
            ),
            const SizedBox(height: 16),
            if (running) const LinearProgressIndicator(),
            if (report != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(report!),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _format(result) {
    return '''Trades: ${result.totalTrades}
Winners: ${result.winners}
Losers: ${result.losers}
Max win: ${result.maxWin}
Max loss: ${result.maxLoss}
Gross profit: ${result.grossProfit}
Gross loss: ${result.grossLoss}
Net: ${result.netProfit}
Final balance: ${result.finalBalance}
''';
  }
}
