import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.green,
    scaffoldBackgroundColor: Colors.green.shade50,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.green.shade700,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green.shade700, width: 2),
      ),
    ),
    iconTheme: IconThemeData(color: Colors.green.shade900),

    /// 👇 Text colors & styles
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: Colors.green.shade900,
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
      headlineSmall: TextStyle(
        color: Colors.green.shade900,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),


      bodyLarge: TextStyle(color: Colors.green.shade900, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.green.shade800, fontSize: 14),
      titleLarge: TextStyle(
        color: Colors.green.shade700,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      labelLarge: TextStyle(color: Colors.green.shade900), // for buttons
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.green,
      accentColor: Colors.green.shade700,
      errorColor: Colors.red.shade700,
      backgroundColor: Colors.green.shade50,
    ),
  );
}
