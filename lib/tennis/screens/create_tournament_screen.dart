import 'package:flutter/material.dart';
import '../bracket.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../models/tournament.dart';
import '../storage.dart';
import '../logo_helper.dart';
import '../widgets/tournament_logo.dart';

class CreateTournamentScreen extends StatefulWidget {
  final String creatorUserId;

  const CreateTournamentScreen({super.key, required this.creatorUserId});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _nameController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  TournamentFormat _format = TournamentFormat.singleElimination;
  bool _openForRegistration = false;
  final List<Player> _players = [];
  final _playerNameController = TextEditingController();
  String? _logoPath;
  final _locationController = TextEditingController();
  final List<String> _categories = [];
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _playerNameController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final path = await pickAndSaveTournamentLogo();
    if (path != null && mounted) setState(() => _logoPath = path);
  }

  void _addCategory() {
    final name = _categoryController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _categories.add(name);
      _categoryController.clear();
    });
  }

  void _removeCategory(String c) {
    setState(() => _categories.remove(c));
  }

  void _addPlayer() {
    final name = _playerNameController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _players.add(Player(id: 'p_${DateTime.now().millisecondsSinceEpoch}_${_players.length}', name: name));
      _playerNameController.clear();
    });
  }

  void _removePlayer(Player p) {
    setState(() => _players.removeWhere((x) => x.id == p.id));
  }

  bool _canCreate() {
    final name = _nameController.text.trim().isNotEmpty;
    final count = _players.length;
    // Single elimination: allow 0–16 players (0 = add players or open registration later).
    // Round robin: need at least 2 players.
    final validCount = _format == TournamentFormat.singleElimination
        ? count <= 16
        : count >= 2 && count <= 16;
    final validDates = !_endDate.isBefore(_startDate);
    return name && validCount && validDates;
  }

  /// Returns a short hint why Create is disabled, or null if creation is allowed.
  String? _getWhyCannotCreate() {
    if (_nameController.text.trim().isEmpty) {
      return 'Enter a tournament name';
    }
    if (_endDate.isBefore(_startDate)) {
      return 'End date must be on or after start date';
    }
    final count = _players.length;
    if (_format == TournamentFormat.singleElimination && count > 16) {
      return 'Single elimination supports at most 16 players';
    }
    if (_format == TournamentFormat.roundRobin && count < 2) {
      return 'Round robin requires at least 2 players';
    }
    return null;
  }

  Future<void> _create() async {
    if (!_canCreate()) return;
    final id = 't_${DateTime.now().millisecondsSinceEpoch}';
    List<TennisMatch> matches = [];
    if (_format == TournamentFormat.singleElimination) {
      matches = generateSingleEliminationMatches(_players);
    }
    final t = Tournament(
      id: id,
      name: _nameController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      format: _format,
      players: List.from(_players),
      matches: matches,
      createdByUserId: widget.creatorUserId,
      openForRegistration: _openForRegistration,
      logoPath: _logoPath,
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      categories: List.from(_categories),
    );
    final list = await loadTournaments();
    list.insert(0, t);
    await saveTournaments(list);
    if (!mounted) return;
    Navigator.of(context).pop(t);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New tournament')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Logo
          Center(
            child: GestureDetector(
              onTap: _pickLogo,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TournamentLogo(logoPath: _logoPath, size: 100),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Icon(Icons.add_a_photo, color: Theme.of(context).colorScheme.onPrimary, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Tap to add tournament logo',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Tournament name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          const Text('Start date', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            title: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setState(() {
                  _startDate = picked;
                  if (_endDate.isBefore(_startDate)) _endDate = _startDate;
                });
              }
            },
          ),
          const SizedBox(height: 8),
          const Text('End date', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            title: Text('${_endDate.day}/${_endDate.month}/${_endDate.year}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
                firstDate: _startDate,
                lastDate: DateTime(2030),
              );
              if (picked != null) setState(() => _endDate = picked);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              hintText: 'Venue or address',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Men\'s Singles',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  textCapitalization: TextCapitalization.words,
                  onSubmitted: (_) => _addCategory(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _addCategory,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          if (_categories.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _categories.map((c) => Chip(
                label: Text(c),
                onDeleted: () => _removeCategory(c),
              )).toList(),
            ),
          ],
          const SizedBox(height: 24),
          const Text('Format', style: TextStyle(fontWeight: FontWeight.bold)),
          RadioListTile<TournamentFormat>(
            title: const Text('Single elimination'),
            value: TournamentFormat.singleElimination,
            groupValue: _format,
            onChanged: (v) => setState(() => _format = v!),
          ),
          RadioListTile<TournamentFormat>(
            title: const Text('Round robin'),
            value: TournamentFormat.roundRobin,
            groupValue: _format,
            onChanged: (v) => setState(() => _format = v!),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Open for registration'),
            subtitle: const Text('Players can register themselves'),
            value: _openForRegistration,
            onChanged: (v) => setState(() => _openForRegistration = v),
          ),
          const SizedBox(height: 24),
          const Text('Players', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _playerNameController,
                  decoration: const InputDecoration(
                    hintText: 'Player name',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  textCapitalization: TextCapitalization.words,
                  onSubmitted: (_) => _addPlayer(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _addPlayer,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          if (_format == TournamentFormat.singleElimination)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Use 2, 4, 8, or 16 players for a clean bracket.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ),
          const SizedBox(height: 8),
          ..._players.map((p) => ListTile(
                title: Text(p.name),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _removePlayer(p),
                ),
              )),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _canCreate() ? _create : null,
            icon: const Icon(Icons.check),
            label: const Text('Create tournament'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          if (!_canCreate() && _getWhyCannotCreate() != null) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                _getWhyCannotCreate()!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
