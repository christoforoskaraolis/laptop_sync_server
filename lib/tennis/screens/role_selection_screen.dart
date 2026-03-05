import 'package:flutter/material.dart';
import '../models/user.dart';
import '../storage.dart';
import 'subscription_screen.dart';
import 'player_setup_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose your role')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              'I am an...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: const Icon(Icons.star, color: Colors.amber),
                ),
                title: const Text('Organizer'),
                subtitle: const Text(
                  'Create tournaments, manage draws, see all results. Premium subscription €49.99/year.',
                ),
                onTap: () => _selectOrganizer(context),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  child: const Icon(Icons.person),
                ),
                title: const Text('Player'),
                subtitle: const Text(
                  'Register for tournaments, view your matches and stats. Free.',
                ),
                onTap: () => _selectPlayer(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectOrganizer(BuildContext context) async {
    final user = await Navigator.of(context).push<AppUser>(
      MaterialPageRoute(
        builder: (context) => const SubscriptionScreen(),
      ),
    );
    if (user != null && context.mounted) {
      await saveCurrentUser(user);
      if (context.mounted) Navigator.of(context).pop(user);
    }
  }

  Future<void> _selectPlayer(BuildContext context) async {
    final user = await Navigator.of(context).push<AppUser>(
      MaterialPageRoute(
        builder: (context) => const PlayerSetupScreen(),
      ),
    );
    if (user != null && context.mounted) {
      await saveCurrentUser(user);
      if (context.mounted) Navigator.of(context).pop(user);
    }
  }
}
