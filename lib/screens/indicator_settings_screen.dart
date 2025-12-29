import 'package:flutter/material.dart';

class IndicatorSettingsScreen extends StatefulWidget {
  static const routeName = '/indicator-settings';

  const IndicatorSettingsScreen({super.key});

  @override
  State<IndicatorSettingsScreen> createState() => _IndicatorSettingsScreenState();
}

class _IndicatorSettingsScreenState extends State<IndicatorSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  int k = 14;
  int d = 3;
  int slow = 3;
  int lowLevel = 20;
  int highLevel = 80;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Indicator Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _numberField('K Period', k, (v) => k = v),
              _numberField('D Period', d, (v) => d = v),
              _numberField('Slow Period', slow, (v) => slow = v),
              _numberField('Low Level', lowLevel, (v) => lowLevel = v),
              _numberField('High Level', highLevel, (v) => highLevel = v),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    Navigator.of(context).pop({'k': k, 'd': d, 'slow': slow, 'low': lowLevel, 'high': highLevel});
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

  Widget _numberField(String label, int value, void Function(int) onSaved) {
    return TextFormField(
      initialValue: value.toString(),
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      onSaved: (v) => onSaved(int.parse(v!)),
    );
  }
}
