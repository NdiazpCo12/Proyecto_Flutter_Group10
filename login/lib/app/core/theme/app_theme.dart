import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const backgroundColor = Color(0xFFF3F3F3);
  static const primaryGreen = Color(0xFF176B22);

  static ThemeData get themeData {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}
