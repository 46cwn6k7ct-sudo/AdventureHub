import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'services/trip_repository.dart';

class AdventureHubApp extends StatelessWidget {
  const AdventureHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF176B63),
      brightness: Brightness.light,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF68D5C8),
      brightness: Brightness.dark,
    );
    return MaterialApp(
      title: 'Adventure Hub',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: _theme(scheme),
      darkTheme: _theme(darkScheme),
      home: const HomeShell(repository: TripRepository()),
    );
  }

  ThemeData _theme(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
