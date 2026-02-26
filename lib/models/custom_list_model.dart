class CustomListModel {
  final String id;
  String name;
  List<String> items; // active items
  List<String> removedItems; // only used when "without replacement"

  CustomListModel({
    required this.id,
    required this.name,
    required this.items,
    required this.removedItems,
  });

  factory CustomListModel.empty({required String id}) =>
      CustomListModel(id: id, name: 'My List', items: [], removedItems: []);

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'items': items,
    'removedItems': removedItems,
  };

  factory CustomListModel.fromMap(Map<dynamic, dynamic> map) => CustomListModel(
    id: (map['id'] ?? '') as String,
    name: (map['name'] ?? 'My List') as String,
    items: ((map['items'] ?? const []) as List).cast<String>(),
    removedItems: ((map['removedItems'] ?? const []) as List).cast<String>(),
  );
}
