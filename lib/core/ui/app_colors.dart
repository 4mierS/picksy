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
    }
  }
}
