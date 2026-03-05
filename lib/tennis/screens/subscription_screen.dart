import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../config/stripe_config.dart';
import '../models/user.dart';
import '../payment_service.dart';
import '../storage.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _subscribeWithStripe(BuildContext context) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    await PaymentService.ensureInitialized();
    final result = await PaymentService.payForPremiumSubscription();

    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case PaymentResult.success:
        await _completeSubscription(context);
        break;
      case PaymentResult.cancelled:
        break;
      case PaymentResult.failed:
        setState(() => _error = 'Payment failed. Please try again.');
        break;
      case PaymentResult.notConfigured:
        await _subscribeDemo(context);
        break;
    }
  }

  Future<void> _subscribeDemo(BuildContext context) async {
    await _subscribe(context, isDemo: true);
  }

  Future<void> _completeSubscription(BuildContext context) async {
    await _subscribe(context, isDemo: false);
  }

  Future<void> _subscribe(BuildContext context, {required bool isDemo}) async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isDemo ? 'Your name (demo)' : 'Complete sign-up'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (_) => Navigator.pop(ctx, nameController.text.trim().isEmpty ? 'Organizer' : nameController.text.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, nameController.text.trim().isEmpty ? 'Organizer' : nameController.text.trim()),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (name == null) return;
    final expiry = DateTime.now().add(const Duration(days: 365));
    final user = AppUser(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: UserType.premium,
      subscriptionExpiry: expiry,
    );
    if (context.mounted) Navigator.of(context).pop(user);
  }

  @override
  Widget build(BuildContext context) {
    final stripeReady = StripeConfig.isConfigured && StripeConfig.hasBackend;
    return Scaffold(
      appBar: AppBar(title: const Text('Premium subscription')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.workspace_premium, size: 48, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Organizer plan',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '€${premiumPricePerYear.toStringAsFixed(2)} / year',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('• Create unlimited tournaments'),
                  const SizedBox(height: 8),
                  const Text('• See all results and standings'),
                  const SizedBox(height: 8),
                  const Text('• Manage draws and match results'),
                  const SizedBox(height: 8),
                  const Text('• Add players and run brackets'),
                ],
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          if (stripeReady) ...[
            FilledButton.icon(
              onPressed: _loading ? null : () => _subscribeWithStripe(context),
              icon: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.payment),
              label: Text(_loading ? 'Processing…' : 'Pay with Google Pay, Apple Pay or Card'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
            if (!kIsWeb)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Google Pay on Android · Apple Pay on iOS · Card on all devices',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
          ] else ...[
            FilledButton.icon(
              onPressed: _loading ? null : () => _subscribeDemo(context),
              icon: const Icon(Icons.payment),
              label: const Text('Subscribe (€49.99/year)'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
            const SizedBox(height: 12),
            Text(
              stripeReady
                  ? 'Pay securely with Google Pay, Apple Pay or card.'
                  : 'Demo mode: no payment. To accept Google Pay / Apple Pay / card, set STRIPE_PUBLISHABLE_KEY and SUBSCRIPTION_BACKEND_URL (see lib/tennis/config/stripe_config.dart) and add a backend that creates a Stripe PaymentIntent for €49.99.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
