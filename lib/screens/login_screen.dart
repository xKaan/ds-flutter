// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart'; // Importez AuthService
import 'profile_screen.dart'; // Importez ProfileScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.title});

  final String title;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Clé pour le formulaire
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService(); // Instanciation d'AuthService

  bool _isLoading = false; // État de chargement
  bool _hidePassword = true; // Mot de passe masqué ou visible

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text;

    try {
      User user = await _authService.login(email, password);

      // L'écran a pu être fermé pendant l'appel réseau
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen(user: user)),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // En paysage, on cache l'icône pour que tout tienne à l'écran
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // Ajout de SingleChildScrollView pour la réactivité
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey, // Assignation de la clé au formulaire
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (!isLandscape) ...[
                      const Icon(Icons.lock_person, size: 80),
                      const SizedBox(height: 32.0),
                    ],
                    // Champ Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        // Validation de l'email
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        // Regex simple pour valider l'email
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Veuillez entrer un email valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    // Champ Mot de Passe
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _hidePassword,
                      onFieldSubmitted: (_) => _login(),
                      validator: (value) {
                        // Validation du mot de passe
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre mot de passe';
                        }
                        if (value.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    // Bouton de Connexion ou Indicateur de Chargement
                    _isLoading
                        ? const CircularProgressIndicator()
                        : FilledButton(
                            onPressed: _login,
                            child: const Text('Se connecter'),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
