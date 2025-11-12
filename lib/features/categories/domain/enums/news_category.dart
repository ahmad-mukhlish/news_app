import 'package:flutter/material.dart';

enum NewsCategory {
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
      case NewsCategory.business:
        return 'Business';
      case NewsCategory.entertainment:
        return 'Entertainment';
      case NewsCategory.general:
        return 'General';
      case NewsCategory.health:
        return 'Health';
      case NewsCategory.science:
        return 'Science';
      case NewsCategory.sports:
        return 'Sports';
      case NewsCategory.technology:
        return 'Technology';
    }
  }

  IconData get icon {
    switch (this) {
      case NewsCategory.business:
        return Icons.business;
      case NewsCategory.entertainment:
        return Icons.movie;
      case NewsCategory.general:
        return Icons.public;
      case NewsCategory.health:
        return Icons.health_and_safety;
      case NewsCategory.science:
        return Icons.science;
      case NewsCategory.sports:
        return Icons.sports_baseball;
      case NewsCategory.technology:
        return Icons.computer;
    }
  }
}
