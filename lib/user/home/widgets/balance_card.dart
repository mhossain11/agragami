import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final int amount;

  const BalanceCard({
    super.key,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: SizedBox(
        height: 100,
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$amount Tk",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const Text("Balance"),
          ],
        ),
      ),
    );
  }
}