import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/player_profile.dart';
import 'models/tournament.dart';
import 'models/user.dart';

const _tournamentsKey = 'tennis_tournaments';
const _currentUserKey = 'tennis_current_user';
const _profilesKey = 'tennis_player_profiles';

Future<List<Tournament>> loadTournaments() async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString(_tournamentsKey);
  if (json == null) return [];
  try {
    final list = jsonDecode(json) as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => Tournament.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}

Future<void> saveTournaments(List<Tournament> tournaments) async {
  final prefs = await SharedPreferences.getInstance();
  final list = tournaments.map((e) => e.toJson()).toList();
  await prefs.setString(_tournamentsKey, jsonEncode(list));
}

Future<AppUser?> loadCurrentUser() async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString(_currentUserKey);
  if (json == null) return null;
  try {
    return AppUser.fromJson(jsonDecode(json) as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
}

Future<void> saveCurrentUser(AppUser? user) async {
  final prefs = await SharedPreferences.getInstance();
  if (user == null) {
    await prefs.remove(_currentUserKey);
  } else {
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
  }
}

Future<List<PlayerProfile>> loadPlayerProfiles() async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString(_profilesKey);
  if (json == null) return [];
  try {
    final list = jsonDecode(json) as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => PlayerProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}

Future<void> savePlayerProfiles(List<PlayerProfile> profiles) async {
  final prefs = await SharedPreferences.getInstance();
  final list = profiles.map((e) => e.toJson()).toList();
  await prefs.setString(_profilesKey, jsonEncode(list));
}
