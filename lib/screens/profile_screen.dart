// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';

import '../models/user.dart';

class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil de l\'Utilisateur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Action de déconnexion
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          // Scroll pour le mode paysage
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: <Widget>[
                  // Avatar avec les initiales
                  CircleAvatar(
                    radius: 40,
                    child: Text(
                      user.firstName[0] + user.lastName[0],
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  // Affichage des informations du profil
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Nom'),
                          subtitle: Text(user.fullName),
                        ),
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: const Text('Email'),
                          subtitle: Text(user.email),
                        ),
                        ListTile(
                          leading: const Icon(Icons.security),
                          title: const Text('Rôle'),
                          subtitle: Text(user.roleLabel),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  FilledButton(
                    onPressed: () {
                      // Déconnexion en retournant à l'écran de connexion
                      Navigator.pop(context);
                    },
                    child: const Text('Se déconnecter'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
