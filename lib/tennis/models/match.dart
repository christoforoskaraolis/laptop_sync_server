/// Status of a match in the tournament.
enum MatchStatus { scheduled, inProgress, completed }

/// A single match between two players.
class TennisMatch {
  final String id;
  final String player1Id;
  final String player2Id;
  final int round; // 0 = final, 1 = semi, 2 = quarter, etc.
  final MatchStatus status;
  final String? score; // e.g. "6-4, 6-3" or "7-6(5), 6-2"
  final String? winnerId;

  const TennisMatch({
    required this.id,
    required this.player1Id,
    required this.player2Id,
    required this.round,
    this.status = MatchStatus.scheduled,
    this.score,
    this.winnerId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'player1Id': player1Id,
        'player2Id': player2Id,
        'round': round,
        'status': status.index,
        'score': score,
        'winnerId': winnerId,
      };

  factory TennisMatch.fromJson(Map<String, dynamic> json) => TennisMatch(
        id: json['id'] as String? ?? '',
        player1Id: json['player1Id'] as String? ?? '',
        player2Id: json['player2Id'] as String? ?? '',
        round: (json['round'] as num?)?.toInt() ?? 0,
        status: MatchStatus.values[(json['status'] as num?)?.toInt() ?? 0],
        score: json['score'] as String?,
        winnerId: json['winnerId'] as String?,
      );

  TennisMatch copyWith({
    String? id,
    String? player1Id,
    String? player2Id,
    int? round,
    MatchStatus? status,
    String? score,
    String? winnerId,
  }) =>
      TennisMatch(
        id: id ?? this.id,
        player1Id: player1Id ?? this.player1Id,
        player2Id: player2Id ?? this.player2Id,
        round: round ?? this.round,
        status: status ?? this.status,
        score: score ?? this.score,
        winnerId: winnerId ?? this.winnerId,
      );
}
