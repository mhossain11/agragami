import 'package:flutter/material.dart';

class BuildInfoRow extends StatelessWidget {
   BuildInfoRow(this.label, this.value,{super.key});

  String label;
  String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
