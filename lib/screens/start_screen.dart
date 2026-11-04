// lib/screens/start_screen.dart

import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final AuthService _authService = AuthService();
  late final Future<User?> _currentUser = _authService.getCurrentUser();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != null) {
          return ProfileScreen(user: snapshot.data!);
        }

        return const LoginScreen(title: 'Page de Connexion');
      },
    );
  }
}
