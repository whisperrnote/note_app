import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/landing_screen.dart';

void main() {
  runApp(const WhisperrNoteApp());
}

class WhisperrNoteApp extends StatelessWidget {
  const WhisperrNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhisperrNote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LandingScreen(),
    );
  }
}
