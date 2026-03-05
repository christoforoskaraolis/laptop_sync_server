import 'match.dart';
import 'player.dart';

/// Tournament format.
enum TournamentFormat { singleElimination, roundRobin }

/// A tennis tournament with players and matches.
class Tournament {
  final String id;
  final String name;
  /// First day of the tournament.
  final DateTime startDate;
  /// Last day of the tournament.
  final DateTime endDate;
  final TournamentFormat format;
  final List<Player> players;
  final List<TennisMatch> matches;
  final String? createdByUserId;
  final bool openForRegistration;
  /// Optional logo image path (local file path).
  final String? logoPath;
  /// Venue or address.
  final String? location;
  /// e.g. ["Men's Singles", "Women's Doubles"].
  final List<String> categories;

  const Tournament({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.format = TournamentFormat.singleElimination,
    this.players = const [],
    this.matches = const [],
    this.createdByUserId,
    this.openForRegistration = false,
    this.logoPath,
    this.location,
    this.categories = const [],
  });

  /// Backward compatibility: same as startDate.
  DateTime get date => startDate;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'format': format.index,
        'players': players.map((e) => e.toJson()).toList(),
        'matches': matches.map((e) => e.toJson()).toList(),
        'createdByUserId': createdByUserId,
        'openForRegistration': openForRegistration,
        'logoPath': logoPath,
        'location': location,
        'categories': categories,
      };

  factory Tournament.fromJson(Map<String, dynamic> json) {
    final start = DateTime.tryParse(json['startDate'] as String? ?? '');
    final end = DateTime.tryParse(json['endDate'] as String? ?? '');
    final legacyDate = DateTime.tryParse(json['date'] as String? ?? '');
    final startDate = start ?? legacyDate ?? DateTime.now();
    final endDate = end ?? startDate;
    return Tournament(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      startDate: startDate,
      endDate: endDate,
      format: TournamentFormat.values[(json['format'] as num?)?.toInt() ?? 0],
      players: (json['players'] as List<dynamic>?)
              ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      matches: (json['matches'] as List<dynamic>?)
              ?.map((e) => TennisMatch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdByUserId: json['createdByUserId'] as String?,
      openForRegistration: json['openForRegistration'] as bool? ?? false,
      logoPath: json['logoPath'] as String?,
      location: json['location'] as String?,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Tournament copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    TournamentFormat? format,
    List<Player>? players,
    List<TennisMatch>? matches,
    String? createdByUserId,
    bool? openForRegistration,
    String? logoPath,
    String? location,
    List<String>? categories,
  }) =>
      Tournament(
        id: id ?? this.id,
        name: name ?? this.name,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        format: format ?? this.format,
        players: players ?? this.players,
        matches: matches ?? this.matches,
        createdByUserId: createdByUserId ?? this.createdByUserId,
        openForRegistration: openForRegistration ?? this.openForRegistration,
        logoPath: logoPath ?? this.logoPath,
        location: location ?? this.location,
        categories: categories ?? this.categories,
      );
}
