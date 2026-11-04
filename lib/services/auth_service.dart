// lib/services/auth_service.dart

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/user.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  // Retourne l'utilisateur connecté, lève une AuthException sinon
  Future<User> login(String email, String password) async {
    final http.Response response;

    try {
      response = await _client
          .post(
            ApiConfig.loginUri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(ApiConfig.timeout);
    } on TimeoutException {
      throw const AuthException('Le serveur ne répond pas');
    } on http.ClientException {
      throw const AuthException('Impossible de joindre le serveur');
    }

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const AuthException('Réponse du serveur invalide');
    }

    if (response.statusCode == 200 && data['status'] == 200) {
      try {
        return User.fromJson(data);
      } on FormatException {
        throw const AuthException('Réponse du serveur invalide');
      }
    }

    if (response.statusCode == 400) {
      throw const AuthException('Email ou mot de passe incorrect');
    }

    throw const AuthException('Erreur serveur, réessayez plus tard');
  }
}
