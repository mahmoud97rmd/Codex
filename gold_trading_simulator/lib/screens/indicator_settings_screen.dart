import 'package:flutter/material.dart';
import 'package:gold_trading_simulator/services/indicator_service.dart';
import 'package:gold_trading_simulator/services/price_feed_service.dart';
import 'package:provider/provider.dart';

class IndicatorSettingsScreen extends StatefulWidget {
  const IndicatorSettingsScreen({super.key});
  static const routeName = '/indicators';

  @override
  State<IndicatorSettingsScreen> createState() => _IndicatorSettingsScreenState();
}

class _IndicatorSettingsScreenState extends State<IndicatorSettingsScreen> {
  late int k;
  late int d;
  late int slow;
  late double lower;
  late double upper;

  @override
  void initState() {
    super.initState();
    final indicators = context.read<IndicatorService>();
    k = indicators.kPeriod;
    d = indicators.dPeriod;
    slow = indicators.slowPeriod;
    lower = indicators.lowerLevel;
    upper = indicators.upperLevel;
  }

  void _apply() {
    final indicators = context.read<IndicatorService>();
    indicators.updateSettings(
      newK: k,
      newD: d,
      newSlow: slow,
      lower: lower,
      upper: upper,
      candles: context.read<PriceFeedService>().candles,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Indicator Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _numberField('K Period', k.toDouble(), (v) => setState(() => k = v.toInt())),
            _numberField('D Period', d.toDouble(), (v) => setState(() => d = v.toInt())),
            _numberField('Slow Period', slow.toDouble(), (v) => setState(() => slow = v.toInt())),
            _numberField('Lower Level', lower, (v) => setState(() => lower = v)),
            _numberField('Upper Level', upper, (v) => setState(() => upper = v)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _apply();
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            )
          ],
        ),
      ),
    );
  }

  Widget _numberField(String label, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          SizedBox(
            width: 100,
            child: TextFormField(
              initialValue: value.toStringAsFixed(0),
              keyboardType: TextInputType.number,
              onChanged: (v) => onChanged(double.tryParse(v) ?? value),
            ),
          ),
        ],
      ),
    );
  }
}
