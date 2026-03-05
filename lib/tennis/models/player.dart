/// Represents a player in a tennis tournament (participant).
/// [profileId] links to [PlayerProfile] for stats/history when set.
class Player {
  final String id;
  final String name;
  final String? profileId;

  const Player({required this.id, required this.name, this.profileId});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (profileId != null) 'profileId': profileId,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        profileId: json['profileId'] as String?,
      );

  Player copyWith({String? id, String? name, String? profileId}) =>
      Player(
        id: id ?? this.id,
        name: name ?? this.name,
        profileId: profileId ?? this.profileId,
      );
}
