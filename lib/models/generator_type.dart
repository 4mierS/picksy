enum GeneratorType { color, number, coin, letter, customList, bottleSpin }

extension GeneratorTypeX on GeneratorType {
  String get title {
    switch (this) {
      case GeneratorType.color:
        return 'Color';
      case GeneratorType.number:
        return 'Number';
      case GeneratorType.coin:
        return 'Coin';
      case GeneratorType.letter:
        return 'Letter';
      case GeneratorType.customList:
        return 'Custom List';
      case GeneratorType.bottleSpin:
        return 'Bottle Spin';
    }
  }
}
