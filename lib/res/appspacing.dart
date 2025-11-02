import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSpacing {
  // Padding
  static  EdgeInsets paddingAll = EdgeInsets.all(16.r);
  static  EdgeInsets paddingHorizontal = EdgeInsets.symmetric(horizontal: 16.w);
  static  EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: 12.h);

  // Margin
  static  EdgeInsets marginAll = EdgeInsets.all(16.r);
  static  EdgeInsets marginHorizontal = EdgeInsets.symmetric(horizontal: 16.w);
  static  EdgeInsets marginVertical = EdgeInsets.symmetric(vertical: 12.h);

  // Custom sizes
  static  EdgeInsets smallPadding = EdgeInsets.all(8.r);
  static  EdgeInsets largePadding = EdgeInsets.all(24.r);


  static  double xs = 4; //Extra Small
  static  double sm = 8; //Small
  static  double md = 16;//Medium 12–16
  static  double lg = 24;//Large 20–24
  static  double xl = 32; //Extra Large  32+
}
