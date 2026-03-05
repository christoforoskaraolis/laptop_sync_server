import 'package:flutter/material.dart';
import '../models/player_profile.dart';
import '../models/tournament.dart';
import '../models/user.dart';
import '../storage.dart';
import '../widgets/tournament_logo.dart';
import 'create_tournament_screen.dart';
import 'tournament_detail_screen.dart';
import 'player_profile_screen.dart';

class TennisHomeScreen extends StatefulWidget {
  final AppUser currentUser;
  final Future<void> Function() onUserUpdated;

  const TennisHomeScreen({
    super.key,
    required this.currentUser,
    required this.onUserUpdated,
  });

  @override
  State<TennisHomeScreen> createState() => _TennisHomeScreenState();
}

class _TennisHomeScreenState extends State<TennisHomeScreen> {
  List<Tournament> _tournaments = [];
  bool _loading = true;

  AppUser get _user => widget.currentUser;
  bool get _isPremium => _user.isPremium;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await loadTournaments();
    if (mounted) setState(() {
      _tournaments = list;
      _loading = false;
    });
  }

  String _dateRangeText(Tournament t) {
    final s = t.startDate;
    final e = t.endDate;
    if (s.year == e.year && s.month == e.month && s.day == e.day) {
      return '${s.day}/${s.month}/${s.year}';
    }
    return '${s.day}/${s.month}/${s.year} – ${e.day}/${e.month}/${e.year}';
  }

  List<Tournament> get _visibleTournaments {
    if (_isPremium) return _tournaments;
    final profileId = _user.playerProfileId;
    if (profileId == null) return _tournaments;
    return _tournaments.where((t) {
      final isParticipant = t.players.any((p) => p.profileId == profileId);
      return isParticipant || t.openForRegistration;
    }).toList();
  }

  Future<void> _createTournament() async {
    final created = await Navigator.of(context).push<Tournament>(
      MaterialPageRoute(
        builder: (context) => CreateTournamentScreen(creatorUserId: _user.id),
      ),
    );
    if (created != null && mounted) {
      _tournaments = await loadTournaments();
      setState(() {});
    }
  }

  Future<void> _openTournament(Tournament t) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TournamentDetailScreen(
          tournament: t,
          currentUser: _user,
        ),
      ),
    );
    if (mounted) {
      _tournaments = await loadTournaments();
      setState(() {});
    }
  }

  Future<void> _openMyProfile() async {
    if (_user.playerProfileId == null) return;
    final profiles = await loadPlayerProfiles();
    final profile = profiles.cast<PlayerProfile?>().firstWhere(
          (p) => p?.id == _user.playerProfileId,
          orElse: () => null,
        );
    if (profile == null || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlayerProfileScreen(profile: profile),
      ),
    );
  }

  Future<void> _deleteTournament(Tournament t) async {
    if (!_isPremium) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete tournament?'),
        content: Text('Remove "${t.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true && mounted) {
      _tournaments = _tournaments.where((x) => x.id != t.id).toList();
      await saveTournaments(_tournaments);
      setState(() {});
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to choose your role again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log out')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await saveCurrentUser(null);
      await widget.onUserUpdated();
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleTournaments;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tennis Tournaments'),
        actions: [
          if (_user.playerProfileId != null)
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: _openMyProfile,
              tooltip: 'My profile',
            ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loading ? null : _load),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'logout') _logout();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout),
                  title: const Text('Log out'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : visible.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events_outlined, size: 72, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _isPremium ? 'No tournaments yet' : 'No tournaments to show',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isPremium
                            ? 'Tap + to create your first tournament'
                            : 'Register for open tournaments or wait for organizers to add you.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: visible.length,
                  itemBuilder: (context, i) {
                    final t = visible[i];
                    final canDelete = _isPremium && t.createdByUserId == _user.id;
                    final dateText = _dateRangeText(t);
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: TournamentLogo(logoPath: t.logoPath, size: 48),
                        title: Text(t.name),
                        subtitle: Text(
                          '${t.players.length} players · $dateText'
                              '${t.location != null && t.location!.isNotEmpty ? " · ${t.location}" : ""}'
                              '${t.openForRegistration ? " · Open for registration" : ""}',
                        ),
                        trailing: canDelete
                            ? PopupMenuButton<String>(
                                onSelected: (v) {
                                  if (v == 'delete') _deleteTournament(t);
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                ],
                              )
                            : null,
                        onTap: () => _openTournament(t),
                      ),
                    );
                  },
                ),
      floatingActionButton: _isPremium
          ? FloatingActionButton.extended(
              onPressed: _createTournament,
              icon: const Icon(Icons.add),
              label: const Text('New tournament'),
            )
          : null,
    );
  }
}
