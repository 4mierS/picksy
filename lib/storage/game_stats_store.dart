import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'boxes.dart';

/// Tracks cumulative wins per player name, per game key.
/// Player names are stored in normalized (trimmed + uppercased) form.
/// Bot wins are stored under "BOT".
class GameStatsStore extends ChangeNotifier {
  static const _kKeyPrefix = 'gameStats_';

  // In-memory cache: gameKey → { playerName → winCount }
  final Map<String, Map<String, int>> _stats = {};

  GameStatsStore() {
    _load();
  }

  void _load() {
    final box = Boxes.box(Boxes.gameStats);
    for (final key in box.keys) {
      if (key is String && key.startsWith(_kKeyPrefix)) {
        final gameKey = key.substring(_kKeyPrefix.length);
        final raw = box.get(key);
        if (raw is Map) {
          _stats[gameKey] = Map<String, int>.from(
            raw.map((k, v) => MapEntry(k.toString(), (v as num).toInt())),
          );
        }
      }
    }
    notifyListeners();
  }

  /// Returns wins for a given [playerName] in [gameKey].
  /// [playerName] will be normalized before lookup.
  int winsFor(String gameKey, String playerName) {
    final name = _normalize(playerName);
    return _stats[gameKey]?[name] ?? 0;
  }

  /// All stats for a given [gameKey]. Keys are normalized player names.
  Map<String, int> statsForGame(String gameKey) {
    return Map.unmodifiable(_stats[gameKey] ?? {});
  }

  /// Record a win for [playerName] in [gameKey].
  Future<void> recordWin(String gameKey, String playerName) async {
    final name = _normalize(playerName);
    _stats.putIfAbsent(gameKey, () => {});
    _stats[gameKey]![name] = (_stats[gameKey]![name] ?? 0) + 1;
    await _persist(gameKey);
    notifyListeners();
  }

  /// Clear all statistics for a specific game.
  Future<void> clearGame(String gameKey) async {
    _stats.remove(gameKey);
    final box = Boxes.box(Boxes.gameStats);
    await box.delete('$_kKeyPrefix$gameKey');
    notifyListeners();
  }

  /// Clear all game statistics.
  Future<void> clearAll() async {
    _stats.clear();
    final box = Boxes.box(Boxes.gameStats);
    final keysToDelete = box.keys
        .where((k) => k is String && k.startsWith(_kKeyPrefix))
        .toList();
    for (final k in keysToDelete) {
      await box.delete(k);
    }
    notifyListeners();
  }

  Future<void> _persist(String gameKey) async {
    final box = Boxes.box(Boxes.gameStats);
    await box.put('$_kKeyPrefix$gameKey', _stats[gameKey] ?? {});
  }

  String _normalize(String name) => name.trim().toUpperCase();
}
