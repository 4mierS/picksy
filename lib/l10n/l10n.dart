import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

import '../models/generator_type.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension GeneratorTypeL10n on GeneratorType {
  String localizedTitle(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case GeneratorType.color:
        return l10n.generatorColor;
      case GeneratorType.number:
        return l10n.generatorNumber;
      case GeneratorType.coin:
        return l10n.generatorCoin;
      case GeneratorType.letter:
        return l10n.generatorLetter;
      case GeneratorType.customList:
        return l10n.generatorCustomList;
      case GeneratorType.bottleSpin:
        return l10n.generatorBottleSpin;
      case GeneratorType.time:
        return l10n.generatorTime;
      case GeneratorType.reactionTest:
        return l10n.generatorReactionTest;
      case GeneratorType.hangman:
        return l10n.generatorHangman;
      case GeneratorType.card:
        return l10n.generatorCard;
    }
  }
}
