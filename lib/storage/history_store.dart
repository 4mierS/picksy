import 'package:flutter/foundation.dart';

import '../models/generator_type.dart';
import '../models/history_entry.dart';
import 'boxes.dart';

class HistoryStore extends ChangeNotifier {
  static const _kKey = 'entries';

  List<HistoryEntry> _entries = [];

  List<HistoryEntry> get entries => List.unmodifiable(_entries);

  HistoryStore() {
    _load();
  }

  Future<void> _load() async {
    final box = Boxes.box(Boxes.history);
    final raw = (box.get(_kKey, defaultValue: <dynamic>[]) as List);

    _entries =
        raw
            .map((e) => HistoryEntry.fromMap(Map<dynamic, dynamic>.from(e)))
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    notifyListeners();
  }

  List<HistoryEntry> forGenerator(GeneratorType type) {
    return _entries.where((e) => e.generatorType == type).toList();
  }

  Future<void> add({
    required GeneratorType type,
    required String value,
    required int maxEntries,
    Map<String, dynamic>? metadata,
  }) async {
    final entry = HistoryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      generatorType: type,
      value: value,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    _entries.insert(0, entry);

    if (_entries.length > maxEntries) {
      _entries = _entries.take(maxEntries).toList();
    }

    await _persist();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _entries.clear();
    await _persist();
    notifyListeners();
  }

  Future<void> clearGenerator(GeneratorType type) async {
    _entries.removeWhere((e) => e.generatorType == type);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final box = Boxes.box(Boxes.history);
    await box.put(_kKey, _entries.map((e) => e.toMap()).toList());
  }
}
