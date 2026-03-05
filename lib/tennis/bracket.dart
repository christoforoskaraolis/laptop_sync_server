import 'dart:math';
import 'models/match.dart';
import 'models/player.dart';

/// Generates first-round single-elimination matches. Next-round matches
/// are created when winners are recorded (both feeder matches complete).
/// Supports 2, 4, 8, 16 players (byes for non-power-of-2).
List<TennisMatch> generateSingleEliminationMatches(List<Player> players) {
  if (players.isEmpty) return [];
  final count = players.length;
  int bracketSize = 2;
  while (bracketSize < count) bracketSize *= 2;
  final shuffled = List<Player>.from(players)..shuffle(Random());
  while (shuffled.length < bracketSize) {
    shuffled.add(Player(id: 'bye_${shuffled.length}', name: 'BYE'));
  }
  final firstRoundCount = bracketSize ~/ 2;
  final matches = <TennisMatch>[];
  for (int i = 0; i < firstRoundCount; i++) {
    matches.add(TennisMatch(
      id: 'm_$i',
      player1Id: shuffled[i * 2].id,
      player2Id: shuffled[i * 2 + 1].id,
      round: 0,
    ));
  }
  return matches;
}

/// Returns the round name for display (round 0 = first round, then semi, final).
String roundName(int round) {
  const names = ['First round', 'Semi-final', 'Final'];
  if (round < names.length) return names[round];
  return 'Round ${round + 1}';
}
