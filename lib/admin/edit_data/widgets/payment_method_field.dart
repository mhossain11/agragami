import 'package:flutter/material.dart';

class PaymentMethodField extends StatelessWidget {
  const PaymentMethodField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final Function(String) onChanged;

  static const List<String> methods = [
    'Nogod',
    'Bkash',
    'Cash Money',
    'cheque',
    'Upay',
    'Bank',
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,

      decoration: const InputDecoration(
        labelText: 'Payment Method',
        border: OutlineInputBorder(),
      ),

      items: methods.map(
            (method) {
          return DropdownMenuItem(
            value: method,
            child: Text(method),
          );
        },
      ).toList(),

      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}