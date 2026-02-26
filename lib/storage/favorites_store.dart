import 'package:flutter/foundation.dart';

import '../models/generator_type.dart';
import 'boxes.dart';

class FavoritesStore extends ChangeNotifier {
  static const _kKey = 'favoriteGenerators';
  final List<GeneratorType> _favorites = [];

  List<GeneratorType> get favorites => List.unmodifiable(_favorites);

  FavoritesStore() {
    _load();
  }

  Future<void> _load() async {
    final box = Boxes.box(Boxes.favorites);
    final raw = (box.get(_kKey, defaultValue: <dynamic>[]) as List)
        .cast<String>();

    _favorites
      ..clear()
      ..addAll(
        raw.map(
          (s) => GeneratorType.values.firstWhere(
            (e) => e.name == s,
            orElse: () => GeneratorType.number,
          ),
        ),
      );

    notifyListeners();
  }

  bool isFavorite(GeneratorType t) => _favorites.contains(t);

  /// Free limit for now (2). Later, replace with premium logic.
  bool canAddMore({required bool isPro}) {
    if (isPro) return true;
    return _favorites.length < 2;
  }

  Future<bool> toggle(GeneratorType t, {required int maxFavorites}) async {
    if (_favorites.contains(t)) {
      _favorites.remove(t);
      await _persist();
      notifyListeners();
      return true;
    }

    if (_favorites.length >= maxFavorites) {
      return false; // blocked
    }

    _favorites.insert(0, t);
    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> _persist() async {
    final box = Boxes.box(Boxes.favorites);
    await box.put(_kKey, _favorites.map((e) => e.name).toList());
  }
}
