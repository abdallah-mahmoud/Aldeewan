import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class IconHelper {
  static const Map<String, IconData> _iconMap = {
    'home': LucideIcons.home,
    'utensils': LucideIcons.utensils,
    'car': LucideIcons.car,
    'heartPulse': LucideIcons.heartPulse,
    'clapperboard': LucideIcons.clapperboard,
    'shoppingBag': LucideIcons.shoppingBag,
    'lightbulb': LucideIcons.lightbulb,
    'wallet': LucideIcons.wallet,
    'briefcase': LucideIcons.briefcase,
    'graduationCap': LucideIcons.graduationCap,
    'plane': LucideIcons.plane,
    'gift': LucideIcons.gift,
    'dumbbell': LucideIcons.dumbbell,
    'wifi': LucideIcons.wifi,
    'phone': LucideIcons.phone,
    'shield': LucideIcons.shield,
    'creditCard': LucideIcons.creditCard,
    'banknote': LucideIcons.banknote,
    'piggyBank': LucideIcons.piggyBank,
    'trendingUp': LucideIcons.trendingUp,
    'trendingDown': LucideIcons.trendingDown,
    'helpCircle': LucideIcons.helpCircle,
  };

  static IconData getIcon(String name) {
    return _iconMap[name] ?? LucideIcons.helpCircle;
  }

  static String getName(IconData icon) {
    return _iconMap.entries
        .firstWhere((element) => element.value == icon, orElse: () => const MapEntry('helpCircle', LucideIcons.helpCircle))
        .key;
  }

  static List<String> get allIconNames => _iconMap.keys.toList();
}
