import 'models/player.dart';
import 'models/player_profile.dart';
import 'models/tournament.dart';
import 'storage.dart';

/// Updates both players' profiles when a match is completed.
/// Call after saving the tournament with the new match result.
Future<void> recordMatchResult({
  required Tournament tournament,
  required String player1Id,
  required String player2Id,
  required String winnerId,
  required String? score,
}) async {
  final profiles = await loadPlayerProfiles();
  final p1List = tournament.players.where((p) => p.id == player1Id).toList();
  final p2List = tournament.players.where((p) => p.id == player2Id).toList();
  final p1 = p1List.isEmpty ? null : p1List.first;
  final p2 = p2List.isEmpty ? null : p2List.first;
  final opponent1Name = p2?.name ?? '?';
  final opponent2Name = p1?.name ?? '?';

  final record = MatchRecord(
    tournamentId: tournament.id,
    tournamentName: tournament.name,
    opponentName: '',
    won: false,
    score: score,
    date: tournament.date,
  );

  bool updated = false;
  final updatedProfiles = profiles.map((profile) {
    if (profile.id == p1?.profileId) {
      updated = true;
      final won = winnerId == player1Id;
      final newRecord = MatchRecord(
        tournamentId: record.tournamentId,
        tournamentName: record.tournamentName,
        opponentName: opponent1Name,
        won: won,
        score: record.score,
        date: record.date,
      );
      return profile.copyWith(
        wins: profile.wins + (won ? 1 : 0),
        losses: profile.losses + (won ? 0 : 1),
        matchHistory: [...profile.matchHistory, newRecord],
        tournamentIds: profile.tournamentIds.contains(tournament.id)
            ? profile.tournamentIds
            : [...profile.tournamentIds, tournament.id],
      );
    }
    if (profile.id == p2?.profileId) {
      updated = true;
      final won = winnerId == player2Id;
      final newRecord = MatchRecord(
        tournamentId: record.tournamentId,
        tournamentName: record.tournamentName,
        opponentName: opponent2Name,
        won: won,
        score: record.score,
        date: record.date,
      );
      return profile.copyWith(
        wins: profile.wins + (won ? 1 : 0),
        losses: profile.losses + (won ? 0 : 1),
        matchHistory: [...profile.matchHistory, newRecord],
        tournamentIds: profile.tournamentIds.contains(tournament.id)
            ? profile.tournamentIds
            : [...profile.tournamentIds, tournament.id],
      );
    }
    return profile;
  }).toList();

  if (updated) await savePlayerProfiles(updatedProfiles);
}
