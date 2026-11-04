// lib/services/auth_service.dart

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/user.dart';
import 'token_storage.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final http.Client _client;
  final TokenStorage _tokenStorage;

  AuthService({http.Client? client, TokenStorage? tokenStorage})
    : _client = client ?? http.Client(),
      _tokenStorage = tokenStorage ?? TokenStorage();

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
      final User user;
      try {
        user = User.fromJson(data);
      } on FormatException {
        throw const AuthException('Réponse du serveur invalide');
      }

      final token = data['token'];
      if (token is String) {
        await _tokenStorage.saveToken(token);
      }

      return user;
    }

    if (response.statusCode == 400) {
      throw const AuthException('Email ou mot de passe incorrect');
    }

    throw const AuthException('Erreur serveur, réessayez plus tard');
  }

  Future<User?> getCurrentUser() async {
    final token = await _tokenStorage.readToken();
    if (token == null) return null;

    final http.Response response;
    try {
      response = await _client
          .get(ApiConfig.meUri, headers: {'Authorization': 'Bearer $token'})
          .timeout(ApiConfig.timeout);
    } catch (_) {
      return null;
    }

    if (response.statusCode == 401) {
      await _tokenStorage.deleteToken();
      return null;
    }

    if (response.statusCode != 200) return null;

    try {
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    final token = await _tokenStorage.readToken();

    if (token != null) {
      try {
        await _client
            .post(
              ApiConfig.logoutUri,
              headers: {'Authorization': 'Bearer $token'},
            )
            .timeout(ApiConfig.timeout);
      } catch (_) {
      }
    }

    await _tokenStorage.deleteToken();
  }
}
