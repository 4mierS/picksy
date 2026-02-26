import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/custom_list_model.dart';
import 'boxes.dart';

class CustomListsStore extends ChangeNotifier {
  static const _kAllListsKey = 'allLists';
  static const _kSelectedListIdKey = 'selectedListId';

  final _rng = Random();

  List<CustomListModel> _lists = [];
  String? _selectedListId;

  List<CustomListModel> get lists => List.unmodifiable(_lists);
  String? get selectedListId => _selectedListId;

  CustomListModel? get selectedList {
    if (_selectedListId == null) return null;
    return _lists
        .where((l) => l.id == _selectedListId)
        .cast<CustomListModel?>()
        .first;
  }

  CustomListsStore() {
    _load();
  }

  Future<void> _load() async {
    final box = Boxes.box(Boxes.customLists);

    final rawLists =
        (box.get(_kAllListsKey, defaultValue: <dynamic>[]) as List);
    _lists = rawLists
        .map((e) => CustomListModel.fromMap(Map<dynamic, dynamic>.from(e)))
        .toList();

    _selectedListId = box.get(_kSelectedListIdKey) as String?;
    if (_selectedListId == null && _lists.isNotEmpty) {
      _selectedListId = _lists.first.id;
      await box.put(_kSelectedListIdKey, _selectedListId);
    }

    // Ensure there is at least one list for MVP.
    if (_lists.isEmpty) {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      _lists = [CustomListModel.empty(id: id)];
      _selectedListId = id;
      await _persist();
    }

    notifyListeners();
  }

  Future<void> _persist() async {
    final box = Boxes.box(Boxes.customLists);
    await box.put(_kAllListsKey, _lists.map((l) => l.toMap()).toList());
    await box.put(_kSelectedListIdKey, _selectedListId);
  }

  Future<void> createNewList() async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _lists.insert(0, CustomListModel.empty(id: id)..name = 'New List');
    _selectedListId = id;
    await _persist();
    notifyListeners();
  }

  Future<void> deleteList(String id) async {
    if (_lists.length <= 1) return; // keep at least one list (MVP)
    _lists.removeWhere((l) => l.id == id);
    if (_selectedListId == id) {
      _selectedListId = _lists.isNotEmpty ? _lists.first.id : null;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> selectList(String id) async {
    _selectedListId = id;
    await _persist();
    notifyListeners();
  }

  Future<void> renameSelected(String name) async {
    final list = selectedList;
    if (list == null) return;
    list.name = name.trim().isEmpty ? list.name : name.trim();
    await _persist();
    notifyListeners();
  }

  Future<void> addItemToSelected(String item) async {
    final list = selectedList;
    if (list == null) return;

    final normalized = item.trim();
    if (normalized.isEmpty) return;

    list.items.add(normalized);
    await _persist();
    notifyListeners();
  }

  Future<void> removeItemFromSelected(int index) async {
    final list = selectedList;
    if (list == null) return;
    if (index < 0 || index >= list.items.length) return;

    list.items.removeAt(index);
    await _persist();
    notifyListeners();
  }

  /// Reset ALL data inside selected list (clears items + removedItems).
  Future<void> resetAllSelected() async {
    final list = selectedList;
    if (list == null) return;
    list.items.clear();
    list.removedItems.clear();
    await _persist();
    notifyListeners();
  }

  /// Restore removed items back into active items (used after "without replacement" draws).
  Future<void> restoreRemovedSelected() async {
    final list = selectedList;
    if (list == null) return;
    if (list.removedItems.isEmpty) return;

    list.items.addAll(list.removedItems);
    list.removedItems.clear();
    await _persist();
    notifyListeners();
  }

  /// Draw random item.
  /// withReplacement = true -> item stays in items
  /// withReplacement = false -> item moved to removedItems
  ///
  /// Auto-reset behavior (your requirement):
  /// - If withReplacement == false and items becomes empty after draw
  ///   -> automatically restore removed items (so next draw works again)
  Future<String?> drawFromSelected({required bool withReplacement}) async {
    final list = selectedList;
    if (list == null) return null;

    if (list.items.isEmpty) {
      // if empty, auto-restore (only makes sense if we have removed items)
      if (list.removedItems.isNotEmpty) {
        list.items.addAll(list.removedItems);
        list.removedItems.clear();
      } else {
        await _persist();
        notifyListeners();
        return null;
      }
    }

    final idx = _rng.nextInt(list.items.length);
    final picked = list.items[idx];

    if (!withReplacement) {
      list.items.removeAt(idx);
      list.removedItems.add(picked);

      // Auto-reset when empty:
      if (list.items.isEmpty && list.removedItems.isNotEmpty) {
        list.items.addAll(list.removedItems);
        list.removedItems.clear();
      }
    }

    await _persist();
    notifyListeners();
    return picked;
  }
}
