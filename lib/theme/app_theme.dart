import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF1A3C8F);
  static const primaryLight = Color(0xFF3A6FF7);
  static const success = Color(0xFF00A86B);
  static const danger = Color(0xFFE53935);
  static const background = Color(0xFFF4F6FB);
  static const textMuted = Color(0xFF6B7280);

  static const cardGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
      );

  static InputDecoration input(
    String label, {
    IconData? icon,
    Widget? suffix,
    String? hint,
    String? prefixText,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefixText,
      prefixIcon: icon == null ? null : Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: danger),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: danger, width: 1.5),
      ),
    );
  }

  static final BoxDecoration card =BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
