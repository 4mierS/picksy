import 'generator_type.dart';

class HistoryEntry {
  final String id;
  final GeneratorType generatorType;
  final String value;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  HistoryEntry({
    required this.id,
    required this.generatorType,
    required this.value,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'generatorType': generatorType.name,
    'value': value,
    'timestamp': timestamp.toIso8601String(),
    if (metadata != null) 'metadata': metadata,
  };

  factory HistoryEntry.fromMap(Map<dynamic, dynamic> map) {
    final typeName = (map['generatorType'] ?? 'number') as String;
    final type = GeneratorType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => GeneratorType.number,
    );

    Map<String, dynamic>? metadata;
    if (map['metadata'] != null) {
      metadata = Map<String, dynamic>.from(map['metadata'] as Map);
    }

    return HistoryEntry(
      id: (map['id'] ?? '') as String,
      generatorType: type,
      value: (map['value'] ?? '') as String,
      timestamp:
          DateTime.tryParse((map['timestamp'] ?? '') as String) ??
          DateTime.now(),
      metadata: metadata,
    );
  }
}
