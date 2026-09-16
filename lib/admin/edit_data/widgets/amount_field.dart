import 'package:flutter/material.dart';

import '../../../core/widgets/text_field.dart';

class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: 'Amount',
    );
  }
}