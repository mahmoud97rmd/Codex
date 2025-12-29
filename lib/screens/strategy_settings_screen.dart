import 'package:flutter/material.dart';

import '../core/api/oanda_api.dart';

class StrategySettingsScreen extends StatefulWidget {
  static const routeName = '/strategy-settings';

  const StrategySettingsScreen({super.key});

  @override
  State<StrategySettingsScreen> createState() => _StrategySettingsScreenState();
}

class _StrategySettingsScreenState extends State<StrategySettingsScreen> {
  bool enabled = true;
  CandleGranularity granularity = CandleGranularity.m1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Strategy Settings')),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Enable strategy'),
            value: enabled,
            onChanged: (v) => setState(() => enabled = v),
          ),
          ListTile(
            title: const Text('Timeframe'),
            trailing: DropdownButton<CandleGranularity>(
              value: granularity,
              onChanged: (v) => setState(() => granularity = v!),
              items: CandleGranularity.values
                  .map((g) => DropdownMenuItem(value: g, child: Text(g.apiValue)))
                  .toList(),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop({'enabled': enabled, 'granularity': granularity}),
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}
