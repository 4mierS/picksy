import 'package:flutter/material.dart';

import '../../models/generator_type.dart';

// Pages
import '../../features/generators/color/color_page.dart';
import '../../features/generators/number/number_page.dart';
import '../../features/generators/coin/coin_page.dart';
import '../../features/generators/letter/letter_page.dart';
import '../../features/generators/custom_list/custom_list_page.dart';
import '../../features/generators/bottle_spin/bottle_spin_page.dart';

void openGenerator(BuildContext context, GeneratorType type) {
  Widget? page;

  switch (type) {
    case GeneratorType.color:
      page = const ColorPage();
      break;
    case GeneratorType.number:
      page = const NumberPage();
      break;
    case GeneratorType.coin:
      page = const CoinPage();
      break;
    case GeneratorType.letter:
      page = const LetterPage();
      break;
    case GeneratorType.customList:
      page = const CustomListPage();
      break;
    case GeneratorType.bottleSpin:
      page = const BottleSpinPage();
      break;
  }

  if (page == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Coming next: ${type.title}')));
    return;
  }

  Navigator.of(context).push(MaterialPageRoute(builder: (_) => page!));
}
