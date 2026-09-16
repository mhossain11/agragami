import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeField extends StatelessWidget {
  const DateTimeField({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  final DateTime? selectedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = selectedDate == null
        ? 'Select Date & Time'
        : DateFormat(
      'dd-MMM-yyyy hh:mm a',
    ).format(selectedDate!);

    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(8),

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),

        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius:
          BorderRadius.circular(8),
        ),

        child: Row(
          children: [
            const Icon(
              Icons.calendar_month,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(text),
            ),

            const Icon(
              Icons.edit,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}