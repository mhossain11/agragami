
import 'package:flutter/material.dart';

import '../domain/models/homeCardData.dart';
import 'homeCard.dart';

Widget buildCardRow(BuildContext context,
    {required HomeCardData first, required HomeCardData second}) {
  return Row(
    children: [
      Expanded(child: HomeCard(first)),
      const SizedBox(width: 10),
      Expanded(child: HomeCard(second)),
    ],
  );
}