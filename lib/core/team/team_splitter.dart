import 'dart:math';

List<List<String>> splitIntoTeams({
  required List<String> people,
  required int teamCount,
  int? seed,
}) {
  if (teamCount <= 0) return [];
  if (people.isEmpty) return List.generate(teamCount, (_) => []);

  final rng = Random(seed);
  final shuffled = List<String>.from(people)..shuffle(rng);

  final teams = List.generate(teamCount, (_) => <String>[]);

  for (var i = 0; i < shuffled.length; i++) {
    teams[i % teamCount].add(shuffled[i]);
  }

  return teams;
}