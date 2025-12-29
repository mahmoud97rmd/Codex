import 'package:flutter/material.dart';
import 'package:gold_trading_simulator/services/account_simulator.dart';
import 'package:provider/provider.dart';

class RiskSettingsScreen extends StatefulWidget {
  const RiskSettingsScreen({super.key});
  static const routeName = '/risk';

  @override
  State<RiskSettingsScreen> createState() => _RiskSettingsScreenState();
}

class _RiskSettingsScreenState extends State<RiskSettingsScreen> {
  late double balance;
  late double lot;
  late double tp;
  late double sl;

  @override
  void initState() {
    super.initState();
    final account = context.read<AccountSimulator>();
    balance = account.balance;
    lot = account.lotSize;
    tp = account.takeProfit;
    sl = account.stopLoss;
  }

  void _save() {
    context.read<AccountSimulator>().update(
          newBalance: balance,
          newLot: lot,
          newTp: tp,
          newSl: sl,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Risk Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _field('Balance', balance, (v) => setState(() => balance = v)),
            _field('Lot size', lot, (v) => setState(() => lot = v)),
            _field('Take profit', tp, (v) => setState(() => tp = v)),
            _field('Stop loss', sl, (v) => setState(() => sl = v)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          SizedBox(
            width: 120,
            child: TextFormField(
              initialValue: value.toStringAsFixed(2),
              keyboardType: TextInputType.number,
              onChanged: (v) => onChanged(double.tryParse(v) ?? value),
            ),
          ),
        ],
      ),
    );
  }
}
