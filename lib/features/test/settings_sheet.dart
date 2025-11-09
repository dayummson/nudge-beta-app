import 'package:flutter/material.dart';
import 'package:nudge_1/constants/currency.dart'; // your AppCurrency list

class SettingsSheetContent extends StatelessWidget {
  final AppCurrency selectedCurrency;
  final ValueChanged<AppCurrency> onCurrencyChanged;

  const SettingsSheetContent({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<AppCurrency>(
          value: selectedCurrency,
          decoration: const InputDecoration(labelText: 'Currency'),
          onChanged: (value) {
            if (value != null) onCurrencyChanged(value);
          },
          items: currencies.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text('${c.symbol} ${c.name} (${c.code})'),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Dark Mode'),
          value: Theme.of(context).brightness == Brightness.dark,
          onChanged: (val) {},
        ),
      ],
    );
  }
}
