import 'generator_type.dart';

class HistoryEntry {
  final String id;
  final GeneratorType generatorType;
  final String value;
  final DateTime timestamp;

  HistoryEntry({
    required this.id,
    required this.generatorType,
    required this.value,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'generatorType': generatorType.name,
    'value': value,
    'timestamp': timestamp.toIso8601String(),
  };

  factory HistoryEntry.fromMap(Map<dynamic, dynamic> map) {
    final typeName = (map['generatorType'] ?? 'number') as String;
    final type = GeneratorType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => GeneratorType.number,
    );

    return HistoryEntry(
      id: (map['id'] ?? '') as String,
      generatorType: type,
      value: (map['value'] ?? '') as String,
      timestamp:
          DateTime.tryParse((map['timestamp'] ?? '') as String) ??
          DateTime.now(),
    );
  }
}
