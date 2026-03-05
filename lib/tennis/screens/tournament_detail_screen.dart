import 'package:flutter/material.dart';
import '../bracket.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../models/player_profile.dart';
import '../models/tournament.dart';
import '../models/user.dart';
import '../profile_service.dart';
import '../storage.dart';
import '../widgets/tournament_logo.dart';

class TournamentDetailScreen extends StatefulWidget {
  final Tournament tournament;
  final AppUser currentUser;

  const TournamentDetailScreen({super.key, required this.tournament, required this.currentUser});

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  late Tournament _tournament;

  @override
  void initState() {
    super.initState();
    _tournament = widget.tournament;
  }

  Player? _playerById(String id) =>
      _tournament.players.cast<Player?>().firstWhere((p) => p?.id == id, orElse: () => null);

  String _playerName(String id) {
    if (id.startsWith('bye_')) return 'BYE';
    return _playerById(id)?.name ?? '?';
  }

  Future<void> _saveTournament() async {
    final list = await loadTournaments();
    final idx = list.indexWhere((t) => t.id == _tournament.id);
    if (idx >= 0) list[idx] = _tournament;
    await saveTournaments(list);
  }

  /// Advance winner to next round (single elimination): create or update next match.
  void _advanceWinner(TennisMatch completedMatch, String winnerId) {
    final matchIndex = int.tryParse(completedMatch.id.replaceFirst('m_', '')) ?? 0;
    final firstRoundCount = _tournament.matches.where((m) => m.round == 0).length;
    int nextMatchIndex;
    int slot;
    if (completedMatch.round == 0) {
      nextMatchIndex = firstRoundCount + (matchIndex ~/ 2);
      slot = matchIndex % 2;
    } else {
      final round1Count = firstRoundCount ~/ 2;
      final indexInRound = matchIndex - firstRoundCount;
      nextMatchIndex = firstRoundCount + round1Count + (indexInRound ~/ 2);
      slot = indexInRound % 2;
    }
    _updateOrCreateNextMatch(completedMatch.round + 1, nextMatchIndex, slot, winnerId);
  }

  void _updateOrCreateNextMatch(int nextRound, int nextMatchIndex, int slot, String winnerId) {
    final existing = _tournament.matches.where((m) => m.id == 'm_$nextMatchIndex').toList();
    if (existing.isNotEmpty) {
      final m = existing.single;
      final updated = slot == 0
          ? m.copyWith(player1Id: winnerId)
          : m.copyWith(player2Id: winnerId);
      final newMatches = _tournament.matches.map((x) => x.id == m.id ? updated : x).toList();
      setState(() => _tournament = _tournament.copyWith(matches: newMatches));
    } else {
      final newMatch = TennisMatch(
        id: 'm_$nextMatchIndex',
        player1Id: slot == 0 ? winnerId : '',
        player2Id: slot == 1 ? winnerId : '',
        round: nextRound,
      );
      setState(() => _tournament = _tournament.copyWith(
        matches: [..._tournament.matches, newMatch],
      ));
    }
  }

  Future<void> _setMatchResult(TennisMatch m, String winnerId, String score) async {
    final updated = m.copyWith(
      status: MatchStatus.completed,
      winnerId: winnerId,
      score: score.isEmpty ? null : score,
    );
    final newMatches = _tournament.matches.map((x) => x.id == m.id ? updated : x).toList();
    setState(() => _tournament = _tournament.copyWith(matches: newMatches));
    _advanceWinner(m, winnerId);
    await _saveTournament();
    await recordMatchResult(
      tournament: _tournament,
      player1Id: m.player1Id,
      player2Id: m.player2Id,
      winnerId: winnerId,
      score: score.isEmpty ? null : score,
    );
  }

  Future<void> _registerForTournament() async {
    final profileId = widget.currentUser.playerProfileId;
    if (profileId == null) return;
    final profiles = await loadPlayerProfiles();
    final profile = profiles.cast<PlayerProfile?>().firstWhere(
          (p) => p?.id == profileId,
          orElse: () => null,
        );
    if (profile == null) return;
    final alreadyIn = _tournament.players.any((p) => p.profileId == profileId);
    if (alreadyIn) return;
    final newPlayer = Player(id: profile.id, name: profile.name, profileId: profile.id);
    setState(() => _tournament = _tournament.copyWith(
      players: [..._tournament.players, newPlayer],
    ));
    await _saveTournament();
  }

  Future<void> _generateBracket() async {
    if (_tournament.players.length < 2) return;
    final matches = generateSingleEliminationMatches(_tournament.players);
    setState(() => _tournament = _tournament.copyWith(matches: matches));
    await _saveTournament();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = widget.currentUser.isPremium;
    final profileId = widget.currentUser.playerProfileId;
    final canRegister = !isPremium &&
        profileId != null &&
        _tournament.openForRegistration &&
        !_tournament.players.any((p) => p.profileId == profileId);
    final canGenerateBracket = isPremium &&
        _tournament.matches.isEmpty &&
        _tournament.players.length >= 2 &&
        _tournament.format == TournamentFormat.singleElimination;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_tournament.name),
          actions: [
            if (canRegister)
              TextButton.icon(
                onPressed: _registerForTournament,
                icon: const Icon(Icons.person_add),
                label: const Text('Register'),
              ),
            if (canGenerateBracket)
              TextButton.icon(
                onPressed: _generateBracket,
                icon: const Icon(Icons.shuffle),
                label: const Text('Generate bracket'),
              ),
          ],
          bottom: const TabBar(
            tabs: [Tab(text: 'Bracket'), Tab(text: 'Players')],
          ),
        ),
        body: Column(
          children: [
            _TournamentInfoCard(tournament: _tournament),
            Expanded(
              child: TabBarView(
                children: [
                  _BracketTab(
                    tournament: _tournament,
                    playerName: _playerName,
                    canEnterResults: isPremium,
                    onSetResult: (match, winnerId, score) async {
                      await _setMatchResult(match, winnerId, score);
                    },
                  ),
                  _PlayersTab(players: _tournament.players),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TournamentInfoCard extends StatelessWidget {
  final Tournament tournament;

  const _TournamentInfoCard({required this.tournament});

  @override
  Widget build(BuildContext context) {
    final s = tournament.startDate;
    final e = tournament.endDate;
    final sameDay = s.year == e.year && s.month == e.month && s.day == e.day;
    final dateText = sameDay
        ? '${s.day}/${s.month}/${s.year}'
        : '${s.day}/${s.month}/${s.year} – ${e.day}/${e.month}/${e.year}';
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TournamentLogo(logoPath: tournament.logoPath, size: 56),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tournament.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(dateText, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  if (tournament.location != null && tournament.location!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            tournament.location!,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (tournament.categories.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      children: tournament.categories
                          .map((c) => Chip(
                                label: Text(c, style: const TextStyle(fontSize: 11)),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BracketTab extends StatelessWidget {
  final Tournament tournament;
  final String Function(String id) playerName;
  final bool canEnterResults;
  final Future<void> Function(TennisMatch match, String winnerId, String score) onSetResult;

  const _BracketTab({
    required this.tournament,
    required this.playerName,
    required this.canEnterResults,
    required this.onSetResult,
  });

  @override
  Widget build(BuildContext context) {
    final byRound = <int, List<TennisMatch>>{};
    for (final m in tournament.matches) {
      byRound.putIfAbsent(m.round, () => []).add(m);
    }
    for (final list in byRound.values) {
      list.sort((a, b) {
        final i = int.tryParse(a.id.replaceFirst('m_', '')) ?? 0;
        final j = int.tryParse(b.id.replaceFirst('m_', '')) ?? 0;
        return i.compareTo(j);
      });
    }
    final rounds = byRound.keys.toList()..sort();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rounds.length,
      itemBuilder: (context, i) {
        final round = rounds[i];
        final matches = byRound[round]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              roundName(round),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            ...matches.map((m) => _MatchCard(
                  match: m,
                  player1Name: m.player1Id.isEmpty ? 'TBD' : playerName(m.player1Id),
                  player2Name: m.player2Id.isEmpty ? 'TBD' : playerName(m.player2Id),
                  canEnterResults: canEnterResults,
                  onSetResult: onSetResult,
                )),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _MatchCard extends StatelessWidget {
  final TennisMatch match;
  final String player1Name;
  final String player2Name;
  final bool canEnterResults;
  final Future<void> Function(TennisMatch, String, String) onSetResult;

  const _MatchCard({
    required this.match,
    required this.player1Name,
    required this.player2Name,
    required this.canEnterResults,
    required this.onSetResult,
  });

  @override
  Widget build(BuildContext context) {
    final canEdit = canEnterResults &&
        match.status != MatchStatus.completed &&
        match.player1Id.isNotEmpty &&
        match.player2Id.isNotEmpty &&
        !player1Name.startsWith('BYE') &&
        !player2Name.startsWith('BYE');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(player1Name, style: const TextStyle(fontWeight: FontWeight.w500))),
                if (match.score != null) Text(match.score!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: Text(player2Name, style: const TextStyle(fontWeight: FontWeight.w500))),
              ],
            ),
            if (match.status == MatchStatus.completed)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Winner: ${match.winnerId == match.player1Id ? player1Name : player2Name}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green[700])),
              )
            else if (canEdit)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    FilledButton.tonal(
                      onPressed: () => _showResultDialog(context, match.player1Id),
                      child: Text('$player1Name wins'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: () => _showResultDialog(context, match.player2Id),
                      child: Text('$player2Name wins'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showResultDialog(BuildContext context, String winnerId) {
    final scoreController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Match result'),
        content: TextField(
          controller: scoreController,
          decoration: const InputDecoration(
            labelText: 'Score (e.g. 6-4, 6-3)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onSetResult(match, winnerId, scoreController.text.trim());
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _PlayersTab extends StatelessWidget {
  final List<Player> players;

  const _PlayersTab({required this.players});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      itemBuilder: (context, i) {
        final p = players[i];
        if (p.id.startsWith('bye_')) return const SizedBox.shrink();
        return ListTile(
          leading: CircleAvatar(child: Text(p.name.isNotEmpty ? p.name[0].toUpperCase() : '?')),
          title: Text(p.name),
        );
      },
    );
  }
}
