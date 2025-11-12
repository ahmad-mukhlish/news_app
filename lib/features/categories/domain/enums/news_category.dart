import 'package:flutter/material.dart';

enum NewsCategoryEnum {
  business,
  entertainment,
  general,
  health,
  science,
  sports,
  technology;

  String get toDto => name;

  String get displayName {
    switch (this) {
      case NewsCategoryEnum.business:
        return 'Business';
      case NewsCategoryEnum.entertainment:
        return 'Entertainment';
      case NewsCategoryEnum.general:
        return 'General';
      case NewsCategoryEnum.health:
        return 'Health';
      case NewsCategoryEnum.science:
        return 'Science';
      case NewsCategoryEnum.sports:
        return 'Sports';
      case NewsCategoryEnum.technology:
        return 'Technology';
    }
  }

  IconData get icon {
    switch (this) {
      case NewsCategoryEnum.business:
        return Icons.bar_chart;
      case NewsCategoryEnum.entertainment:
        return Icons.confirmation_number;
      case NewsCategoryEnum.general:
        return Icons.public;
      case NewsCategoryEnum.health:
        return Icons.favorite;
      case NewsCategoryEnum.science:
        return Icons.biotech;
      case NewsCategoryEnum.sports:
        return Icons.sports_baseball;
      case NewsCategoryEnum.technology:
        return Icons.lightbulb;
    }
  }

  Color get colorCode {
    switch (this) {
      case NewsCategoryEnum.business:
        return const Color(0xFF4CAF50);
      case NewsCategoryEnum.entertainment:
        return const Color(0xFF9C27B0);
      case NewsCategoryEnum.general:
        return const Color(0xFF4CAF50);
      case NewsCategoryEnum.health:
        return const Color(0xFFE91E63);
      case NewsCategoryEnum.science:
        return const Color(0xFF2196F3);
      case NewsCategoryEnum.sports:
        return const Color(0xFFFF9800);
      case NewsCategoryEnum.technology:
        return const Color(0xFF00BCD4);
    }
  }
}
