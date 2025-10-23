

import 'package:flutter/material.dart';

class themeData{

  final ThemeData somitiTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF2E7D32), // সবুজ (main brand color)
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF2E7D32), // সবুজ
      onPrimary: Colors.white,
      secondary: Color(0xFFE53935), // লাল (accent)
      onSecondary: Colors.white,
      error: Color(0xFFD32F2F),
      onError: Colors.white,
      background: Color(0xFFF5F5F5), // হালকা ধূসর ব্যাকগ্রাউন্ড
      onBackground: Color(0xFF212121),
      surface: Colors.white, // card color
      onSurface: Color(0xFF212121),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2E7D32),
      foregroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50), // Primary green button
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFE53935), // Red border button
        side: const BorderSide(color: Color(0xFFE53935)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF212121)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF424242)),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

}