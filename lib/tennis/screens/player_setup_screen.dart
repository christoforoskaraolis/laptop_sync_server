import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/player_profile.dart';
import '../storage.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createProfileAndContinue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }
    final profileId = 'pr_${DateTime.now().millisecondsSinceEpoch}';
    final profile = PlayerProfile(id: profileId, name: name);
    final profiles = await loadPlayerProfiles();
    profiles.add(profile);
    await savePlayerProfiles(profiles);
    final user = AppUser(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: UserType.player,
      playerProfileId: profileId,
    );
    if (mounted) Navigator.of(context).pop(user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create your player profile to register for tournaments and track your stats.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your name',
                border: OutlineInputBorder(),
                hintText: 'e.g. John Smith',
              ),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _createProfileAndContinue(),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _createProfileAndContinue,
              icon: const Icon(Icons.person_add),
              label: const Text('Create profile & continue'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
