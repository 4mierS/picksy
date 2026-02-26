import 'package:hive_flutter/hive_flutter.dart';

class Boxes {
  static const settings = 'settings';
  static const favorites = 'favorites';
  static const history = 'history';
  static const customLists = 'customLists';

  static Future<void> init() async {
    await Hive.openBox(settings);
    await Hive.openBox(favorites);
    await Hive.openBox(history);
    await Hive.openBox(customLists);
  }

  static Box box(String name) => Hive.box(name);
}
