import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/auth_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const TennisTournamentApp());
}

/// Tennis green & white theme.
class TennisTournamentApp extends StatelessWidget {
  const TennisTournamentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tennis Tournaments',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF1B5E20),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}
