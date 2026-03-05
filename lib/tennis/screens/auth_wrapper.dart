import 'package:flutter/material.dart';
import '../models/user.dart';
import '../storage.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';
import 'role_selection_screen.dart';

/// Shows Welcome if no user, otherwise Home.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  AppUser? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await loadCurrentUser();
    if (mounted) setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _goToRoleSelection() async {
    final user = await Navigator.of(context).push<AppUser>(
      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
    );
    if (user != null && mounted) {
      await saveCurrentUser(user);
      if (mounted) setState(() => _user = user);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_user == null) {
      return WelcomeScreen(onGetStarted: _goToRoleSelection);
    }
    return TennisHomeScreen(
      currentUser: _user!,
      onUserUpdated: _load,
    );
  }
}
