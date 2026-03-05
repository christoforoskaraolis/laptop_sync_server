/// One match record in a player's history (for stats and profile).
class MatchRecord {
  final String tournamentId;
  final String tournamentName;
  final String opponentName;
  final bool won;
  final String? score;
  final DateTime date;

  const MatchRecord({
    required this.tournamentId,
    required this.tournamentName,
    required this.opponentName,
    required this.won,
    this.score,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'tournamentId': tournamentId,
        'tournamentName': tournamentName,
        'opponentName': opponentName,
        'won': won,
        'score': score,
        'date': date.toIso8601String(),
      };

  factory MatchRecord.fromJson(Map<String, dynamic> json) => MatchRecord(
        tournamentId: json['tournamentId'] as String? ?? '',
        tournamentName: json['tournamentName'] as String? ?? '',
        opponentName: json['opponentName'] as String? ?? '',
        won: json['won'] as bool? ?? false,
        score: json['score'] as String?,
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      );
}

/// Persistent player profile with stats and match history.
class PlayerProfile {
  final String id;
  final String name;
  final int wins;
  final int losses;
  final List<MatchRecord> matchHistory;
  final List<String> tournamentIds;

  const PlayerProfile({
    required this.id,
    required this.name,
    this.wins = 0,
    this.losses = 0,
    this.matchHistory = const [],
    this.tournamentIds = const [],
  });

  int get totalMatches => wins + losses;
  double get winRate => totalMatches > 0 ? wins / totalMatches : 0.0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'wins': wins,
        'losses': losses,
        'matchHistory': matchHistory.map((e) => e.toJson()).toList(),
        'tournamentIds': tournamentIds,
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) => PlayerProfile(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        wins: (json['wins'] as num?)?.toInt() ?? 0,
        losses: (json['losses'] as num?)?.toInt() ?? 0,
        matchHistory: (json['matchHistory'] as List<dynamic>?)
                ?.map((e) => MatchRecord.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        tournamentIds: (json['tournamentIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );

  PlayerProfile copyWith({
    String? id,
    String? name,
    int? wins,
    int? losses,
    List<MatchRecord>? matchHistory,
    List<String>? tournamentIds,
  }) =>
      PlayerProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        wins: wins ?? this.wins,
        losses: losses ?? this.losses,
        matchHistory: matchHistory ?? this.matchHistory,
        tournamentIds: tournamentIds ?? this.tournamentIds,
      );
}
