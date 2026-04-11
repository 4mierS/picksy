import 'package:flutter/material.dart';
import 'boxes.dart';

/// Tracks how many mini games a free user has opened today.
/// Resets automatically at midnight (checked lazily on each call).
class DailyPlayStore extends ChangeNotifier {
  static const _kDate = 'dailyPlayDate';
  static const _kCount = 'dailyPlayCount';
  static const freeLimit = 5;

  int _count = 0;

  DailyPlayStore() {
    _sync();
  }

  int get playsToday => _count;
  int get playsRemaining => (freeLimit - _count).clamp(0, freeLimit);

  bool canPlay() {
    _sync();
    return _count < freeLimit;
  }

  Future<void> recordPlay() async {
    _sync();
    _count++;
    await Boxes.box(Boxes.settings).put(_kCount, _count);
    notifyListeners();
  }

  void _sync() {
    final b = Boxes.box(Boxes.settings);
    final today = _today();
    final stored = b.get(_kDate, defaultValue: '') as String;
    if (stored != today) {
      b.put(_kDate, today);
      b.put(_kCount, 0);
      _count = 0;
    } else {
      _count = b.get(_kCount, defaultValue: 0) as int;
    }
  }

  static String _today() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }
}
