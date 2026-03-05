/// Type of app user: organizer (premium) or player.
enum UserType { premium, player }

/// App user: premium organizer or normal player.
class AppUser {
  final String id;
  final String name;
  final UserType type;
  /// For premium: expiry of subscription. Null if not premium or expired.
  final DateTime? subscriptionExpiry;
  /// For player: their profile id (so we can find their stats).
  final String? playerProfileId;

  const AppUser({
    required this.id,
    required this.name,
    required this.type,
    this.subscriptionExpiry,
    this.playerProfileId,
  });

  bool get isPremium =>
      type == UserType.premium &&
      subscriptionExpiry != null &&
      subscriptionExpiry!.isAfter(DateTime.now());

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.index,
        'subscriptionExpiry': subscriptionExpiry?.toIso8601String(),
        'playerProfileId': playerProfileId,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        type: UserType.values[(json['type'] as num?)?.toInt() ?? 0],
        subscriptionExpiry: json['subscriptionExpiry'] != null
            ? DateTime.tryParse(json['subscriptionExpiry'] as String)
            : null,
        playerProfileId: json['playerProfileId'] as String?,
      );

  AppUser copyWith({
    String? id,
    String? name,
    UserType? type,
    DateTime? subscriptionExpiry,
    String? playerProfileId,
  }) =>
      AppUser(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
        playerProfileId: playerProfileId ?? this.playerProfileId,
      );
}

/// Premium subscription price per year (EUR).
const premiumPricePerYear = 49.99;
