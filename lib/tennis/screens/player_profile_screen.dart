import 'package:flutter/material.dart';
import '../models/player_profile.dart';

class PlayerProfileScreen extends StatelessWidget {
  final PlayerProfile profile;

  const PlayerProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final history = List<MatchRecord>.from(profile.matchHistory)
      ..sort((a, b) => b.date.compareTo(a.date));
    return Scaffold(
      appBar: AppBar(title: Text(profile.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatChip(
                        label: 'Wins',
                        value: '${profile.wins}',
                      ),
                      _StatChip(
                        label: 'Losses',
                        value: '${profile.losses}',
                      ),
                      _StatChip(
                        label: 'Win rate',
                        value: profile.totalMatches > 0
                            ? '${(profile.winRate * 100).toStringAsFixed(0)}%'
                            : '-',
                      ),
                      _StatChip(
                        label: 'Tournaments',
                        value: '${profile.tournamentIds.length}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Match history',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (history.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No matches yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            )
          else
            ...history.map((m) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      m.won ? Icons.emoji_events : Icons.sports,
                      color: m.won ? Colors.green : Colors.grey,
                    ),
                    title: Text('${m.won ? "W" : "L"} vs ${m.opponentName}'),
                    subtitle: Text(
                      '${m.tournamentName} · ${m.date.day}/${m.date.month}/${m.date.year}${m.score != null ? " · ${m.score}" : ""}',
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
      ],
    );
  }
}
