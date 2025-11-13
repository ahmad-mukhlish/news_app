import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/categories/domain/enums/news_category_enum.dart';

void main() {
  group('NewsCategoryEnum', () {
    test('should have all 7 category values', () {
      expect(NewsCategoryEnum.values.length, 7);
      expect(NewsCategoryEnum.values, contains(NewsCategoryEnum.business));
      expect(NewsCategoryEnum.values, contains(NewsCategoryEnum.entertainment));
      expect(NewsCategoryEnum.values, contains(NewsCategoryEnum.general));
      expect(NewsCategoryEnum.values, contains(NewsCategoryEnum.health));
      expect(NewsCategoryEnum.values, contains(NewsCategoryEnum.science));
      expect(NewsCategoryEnum.values, contains(NewsCategoryEnum.sports));
      expect(NewsCategoryEnum.values, contains(NewsCategoryEnum.technology));
    });

    group('toDto', () {
      test('should return correct API string for business', () {
        expect(NewsCategoryEnum.business.toDto, 'business');
      });

      test('should return correct API string for entertainment', () {
        expect(NewsCategoryEnum.entertainment.toDto, 'entertainment');
      });

      test('should return correct API string for general', () {
        expect(NewsCategoryEnum.general.toDto, 'general');
      });

      test('should return correct API string for health', () {
        expect(NewsCategoryEnum.health.toDto, 'health');
      });

      test('should return correct API string for science', () {
        expect(NewsCategoryEnum.science.toDto, 'science');
      });

      test('should return correct API string for sports', () {
        expect(NewsCategoryEnum.sports.toDto, 'sports');
      });

      test('should return correct API string for technology', () {
        expect(NewsCategoryEnum.technology.toDto, 'technology');
      });
    });

    group('displayName', () {
      test('should return correct display name for business', () {
        expect(NewsCategoryEnum.business.displayName, 'Business');
      });

      test('should return correct display name for entertainment', () {
        expect(NewsCategoryEnum.entertainment.displayName, 'Entertainment');
      });

      test('should return correct display name for general', () {
        expect(NewsCategoryEnum.general.displayName, 'General');
      });

      test('should return correct display name for health', () {
        expect(NewsCategoryEnum.health.displayName, 'Health');
      });

      test('should return correct display name for science', () {
        expect(NewsCategoryEnum.science.displayName, 'Science');
      });

      test('should return correct display name for sports', () {
        expect(NewsCategoryEnum.sports.displayName, 'Sports');
      });

      test('should return correct display name for technology', () {
        expect(NewsCategoryEnum.technology.displayName, 'Technology');
      });
    });

    group('icon', () {
      test('should return IconData for business', () {
        expect(NewsCategoryEnum.business.icon, Icons.bar_chart);
      });

      test('should return IconData for entertainment', () {
        expect(NewsCategoryEnum.entertainment.icon, Icons.confirmation_number);
      });

      test('should return IconData for general', () {
        expect(NewsCategoryEnum.general.icon, Icons.public);
      });

      test('should return IconData for health', () {
        expect(NewsCategoryEnum.health.icon, Icons.favorite);
      });

      test('should return IconData for science', () {
        expect(NewsCategoryEnum.science.icon, Icons.biotech);
      });

      test('should return IconData for sports', () {
        expect(NewsCategoryEnum.sports.icon, Icons.sports_baseball);
      });

      test('should return IconData for technology', () {
        expect(NewsCategoryEnum.technology.icon, Icons.lightbulb);
      });

      test('all icons should be valid IconData instances', () {
        for (final category in NewsCategoryEnum.values) {
          expect(category.icon, isA<IconData>());
        }
      });
    });

    group('colorCode', () {
      test('should return correct color for business', () {
        expect(NewsCategoryEnum.business.colorCode, const Color(0xFF4CAF50));
      });

      test('should return correct color for entertainment', () {
        expect(NewsCategoryEnum.entertainment.colorCode, const Color(0xFF9C27B0));
      });

      test('should return correct color for general', () {
        expect(NewsCategoryEnum.general.colorCode, const Color(0xFF4CAF50));
      });

      test('should return correct color for health', () {
        expect(NewsCategoryEnum.health.colorCode, const Color(0xFFE91E63));
      });

      test('should return correct color for science', () {
        expect(NewsCategoryEnum.science.colorCode, const Color(0xFF2196F3));
      });

      test('should return correct color for sports', () {
        expect(NewsCategoryEnum.sports.colorCode, const Color(0xFFFF9800));
      });

      test('should return correct color for technology', () {
        expect(NewsCategoryEnum.technology.colorCode, const Color(0xFF00BCD4));
      });

      test('all colors should be valid Color instances', () {
        for (final category in NewsCategoryEnum.values) {
          expect(category.colorCode, isA<Color>());
        }
      });
    });
  });
}
