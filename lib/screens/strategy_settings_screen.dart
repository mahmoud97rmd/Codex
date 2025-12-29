import 'package:flutter/material.dart';
import 'package:gold_trading_simulator/services/strategy_service.dart';
import 'package:provider/provider.dart';

class StrategySettingsScreen extends StatefulWidget {
  const StrategySettingsScreen({super.key});
  static const routeName = '/strategy';

  @override
  State<StrategySettingsScreen> createState() => _StrategySettingsScreenState();
}

class _StrategySettingsScreenState extends State<StrategySettingsScreen> {
  late bool enabled;
  late String granularity;

  @override
  void initState() {
    super.initState();
    final strategy = context.read<StrategyService>();
    enabled = strategy.enabled;
    granularity = strategy.granularity;
  }

  void _save() {
    context.read<StrategyService>().updateSettings(
          isEnabled: enabled,
          selectedGranularity: granularity,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Strategy Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Enable Strategy'),
              value: enabled,
              onChanged: (v) => setState(() => enabled = v),
            ),
            DropdownButtonFormField<String>(
              initialValue: granularity,
              decoration: const InputDecoration(labelText: 'Timeframe'),
              items: const [
                DropdownMenuItem(value: 'M1', child: Text('1 Minute')),
                DropdownMenuItem(value: 'M5', child: Text('5 Minutes')),
                DropdownMenuItem(value: 'M15', child: Text('15 Minutes')),
              ],
              onChanged: (v) => setState(() => granularity = v ?? 'M1'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
