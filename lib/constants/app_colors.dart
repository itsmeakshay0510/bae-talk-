import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF9D4EDD);       // Rich purple
  static const Color primaryDark = Color(0xFF5A189A);
  static const Color primaryLight = Color(0xFFC77DFF);
  static const Color accent = Color(0xFFFF9E00);         // Gold-orange for deals
  static const Color accentGold = Color(0xFFFFD700);     // Gold for premium

  // Gradient Colors
  static const Color gradientStart = Color(0xFF9D4EDD);
  static const Color gradientEnd = Color(0xFF5A189A);
  static const Color gradientAccent = Color(0xFFFF6B35);

  // Background
  static const Color backgroundLight = Color(0xFFF8F7FC);
  static const Color backgroundDark = Color(0xFF0F081D);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1D1438);
  static const Color cardDark = Color(0xFF241A45);

  // Text
  static const Color textDark = Color(0xFF1D1438);
  static const Color textLight = Color(0xFFF3E8FF);
  static const Color textGrey = Color(0xFF88829C);
  static const Color textMedium = Color(0xFF88829C);  // alias for textGrey
  static const Color textLightGrey = Color(0xFFB3AECA);
  static const Color secondary = Color(0xFF5A189A);   // alias for gradientEnd

  // Status
  static const Color success = Color(0xFF00C897);
  static const Color error = Color(0xFFFF5B7F);
  static const Color warning = Color(0xFFFF9E00);
  static const Color info = Color(0xFF3B82F6);

  // Discount / Sale
  static const Color saleRed = Color(0xFFFF5B7F);
  static const Color saleBadge = Color(0xFFD81159);

  // Divider / Border
  static const Color divider = Color(0xFFEBE9F5);
  static const Color border = Color(0xFFE2DFEC);
  static const Color borderDark = Color(0xFF322659);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF9D4EDD), Color(0xFF5A189A), Color(0xFF240046)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1D1438), Color(0xFF241A45)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
