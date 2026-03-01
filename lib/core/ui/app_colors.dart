import 'package:flutter/material.dart';

import '../../models/generator_type.dart';

class AppColors {
  static const Color proPurple = Color(0xFF6C5CE7);
}

extension GeneratorTypeColorX on GeneratorType {
  Color get accentColor {
    switch (this) {
      case GeneratorType.color:
        return Colors.pinkAccent;
      case GeneratorType.number:
        return Colors.blueAccent;
      case GeneratorType.coin:
        return Colors.amber;
      case GeneratorType.letter:
        return Colors.teal;
      case GeneratorType.customList:
        return Colors.deepPurple;
      case GeneratorType.bottleSpin:
        return Colors.orange;
      case GeneratorType.time:
        return Colors.green;
      case GeneratorType.reactionTest:
        return Colors.redAccent;
      case GeneratorType.hangman:
        return Colors.indigoAccent;
      case GeneratorType.colorReflex:
        return Colors.cyanAccent;
    }
  }
}

extension GeneratorTypeIconX on GeneratorType {
  IconData get homeIcon {
    switch (this) {
      case GeneratorType.color:
        return Icons.palette_outlined;
      case GeneratorType.number:
        return Icons.numbers;
      case GeneratorType.coin:
        return Icons.sync_alt;
      case GeneratorType.letter:
        return Icons.text_fields;
      case GeneratorType.customList:
        return Icons.list_alt;
      case GeneratorType.bottleSpin:
        return Icons.explore_outlined;
      case GeneratorType.time:
        return Icons.access_time;
      case GeneratorType.reactionTest:
        return Icons.flash_on;
      case GeneratorType.hangman:
        return Icons.sports_esports_outlined;
      case GeneratorType.colorReflex:
        return Icons.psychology_outlined;
    }
  }
}
