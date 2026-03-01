import 'package:flutter/material.dart';

import '../../models/generator_type.dart';

import '../../features/generators/color/color_page.dart';
import '../../features/generators/number/number_page.dart';
import '../../features/generators/coin/coin_page.dart';
import '../../features/generators/letter/letter_page.dart';
import '../../features/generators/custom_list/custom_list_page.dart';
import '../../features/generators/bottle_spin/bottle_spin_page.dart';
import '../../features/generators/time/time_page.dart';
import '../../features/generators/reaction_test/reaction_test_page.dart';
import '../../features/generators/hangman/hangman_page.dart';

void openGenerator(BuildContext context, GeneratorType type) {
  final Widget page = switch (type) {
    GeneratorType.color => const ColorPage(),
    GeneratorType.number => const NumberPage(),
    GeneratorType.coin => const CoinPage(),
    GeneratorType.letter => const LetterPage(),
    GeneratorType.customList => const CustomListPage(),
    GeneratorType.bottleSpin => const BottleSpinPage(),
    GeneratorType.time => const TimePage(),
    GeneratorType.reactionTest => const ReactionTestPage(),
    GeneratorType.hangman => const HangmanPage(),
  };

  Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}
