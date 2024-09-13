import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF673AB7),
        primary: const Color(0xFF673AB7),
        onPrimary: const Color(0xFFFFFFFF),
        primaryContainer: const Color(0xFFD1C4E9),
        onPrimaryContainer: const Color(0xFF512DA8),
        secondary: const Color(0xFFCDDC39),
        onSecondary: const Color(0xFF212121),
        secondaryContainer: const Color(0xFFBDBDBD),
        onSecondaryContainer: const Color(0xFF757575),
        surface: const Color(0xFFFFFFFF),
        onSurface: const Color(0xFF212121),
        outline: const Color(0xFFBDBDBD),
      ),
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF673AB7),
        iconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
        titleTextStyle: TextStyle(color: Color(0xFFFFFFFF), fontSize: 20.0),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xFF673AB7),
        textTheme: ButtonTextTheme.primary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFCDDC39),
        foregroundColor: Color(0xFF212121),
        elevation: 10.0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF212121)),
        bodyMedium: TextStyle(color: Color(0xFF757575)),
        bodySmall: TextStyle(color: Color(0xFFD1C4E9)),
        titleLarge: TextStyle(color: Color(0xFFFFFFFF)),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFFCDDC39),
        contentTextStyle: TextStyle(
          color: Color(0xFF212121),
          fontSize: 16.0,
        ),
      ),
    );
  }
}
