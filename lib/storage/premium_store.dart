import 'package:flutter/foundation.dart';
import 'boxes.dart';

class PremiumStore extends ChangeNotifier {
  static const _kIsPro = 'isProCached';

  bool _isPro = false;
  bool get isPro => _isPro;

  PremiumStore() {
    _load();
  }

  Future<void> _load() async {
    final box = Boxes.box(Boxes.settings);
    _isPro = (box.get(_kIsPro, defaultValue: false) as bool);
    notifyListeners();
  }

  Future<void> setPro(bool value) async {
    _isPro = value;
    await Boxes.box(Boxes.settings).put(_kIsPro, value);
    notifyListeners();
  }
}
