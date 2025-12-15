import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';

class CategoryHelper {
  static String getLocalizedCategory(String dbName, AppLocalizations l10n) {
    switch (dbName) {
      case 'Housing':
        return l10n.catHousing;
      case 'Food & Dining':
        return l10n.catFood;
      case 'Transportation':
        return l10n.catTransportation;
      case 'Health':
        return l10n.catHealth;
      case 'Entertainment':
        return l10n.catEntertainment;
      case 'Shopping':
        return l10n.catShopping;
      case 'Utilities':
        return l10n.catUtilities;
      case 'Income':
        return l10n.catIncome;
      case 'Savings':
        return l10n.catSavings;
      case 'Other':
        return l10n.catOther;
      default:
        return dbName;
    }
  }

  static IconData getIcon(String? categoryName) {
    switch (categoryName) {
      case 'Housing':
        return LucideIcons.home;
      case 'Food & Dining':
        return LucideIcons.utensils;
      case 'Transportation':
        return LucideIcons.car;
      case 'Health':
        return LucideIcons.heartPulse;
      case 'Entertainment':
        return LucideIcons.clapperboard;
      case 'Shopping':
        return LucideIcons.shoppingBag;
      case 'Utilities':
        return LucideIcons.lightbulb;
      case 'Income':
        return LucideIcons.wallet;
      case 'Savings':
        return LucideIcons.piggyBank;
      case 'Other':
        return LucideIcons.helpCircle;
      default:
        return LucideIcons.helpCircle;
    }
  }

  static Color getColor(String? categoryName) {
    switch (categoryName) {
      case 'Housing':
        return Colors.blue;
      case 'Food & Dining':
        return Colors.orange;
      case 'Transportation':
        return Colors.teal;
      case 'Health':
        return Colors.red;
      case 'Entertainment':
        return Colors.purple;
      case 'Shopping':
        return Colors.pink;
      case 'Utilities':
        return Colors.yellow;
      case 'Income':
        return Colors.green;
      case 'Savings':
        return Colors.cyan;
      case 'Other':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
