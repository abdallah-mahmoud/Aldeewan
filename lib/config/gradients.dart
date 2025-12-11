import 'package:flutter/material.dart';

class AppGradients {
  static const LinearGradient primaryCard = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)], // Indigo to Violet
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accountCard1 = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)], // Sky to Blue
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accountCard2 = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEA580C)], // Amber to Orange
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accountCard3 = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)], // Emerald to Green
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient budgetSafe = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF059669)],
  );

  static const LinearGradient budgetWarning = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
  );

  static const LinearGradient budgetDanger = LinearGradient(
    colors: [Color(0xFFF87171), Color(0xFFDC2626)],
  );

  static LinearGradient getAccountGradient(int index) {
    final gradients = [accountCard1, accountCard2, accountCard3];
    return gradients[index % gradients.length];
  }
}
