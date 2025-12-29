import 'package:flutter/material.dart';

class RiskSettingsScreen extends StatefulWidget {
  static const routeName = '/risk-settings';

  const RiskSettingsScreen({super.key});

  @override
  State<RiskSettingsScreen> createState() => _RiskSettingsScreenState();
}

class _RiskSettingsScreenState extends State<RiskSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  double balance = 10000;
  double lot = 0.1;
  double tp = 10;
  double sl = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Risk Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field('Balance', balance, (v) => balance = v),
              _field('Lot size', lot, (v) => lot = v),
              _field('Take Profit', tp, (v) => tp = v),
              _field('Stop Loss', sl, (v) => sl = v),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    Navigator.of(context).pop({'balance': balance, 'lot': lot, 'tp': tp, 'sl': sl});
                  }
                },
                child: const Text('Apply'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, double value, void Function(double) onSaved) {
    return TextFormField(
      initialValue: value.toString(),
      decoration: InputDecoration(labelText: label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      onSaved: (v) => onSaved(double.parse(v!)),
    );
  }
}
