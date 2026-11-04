# Application de connexion Flutter – API REST

Application Flutter de connexion qui authentifie les utilisateurs via une API REST en PHP. L'application envoie l'email et le mot de passe à l'API, lit la réponse JSON et affiche le profil de l'utilisateur connecté.

API utilisée : [ds-flutter-api](https://github.com/xKaan/ds-flutter-api)

## Fonctionnalités

- Connexion via `POST /login.php` avec le package `http`
- Profil affiché à partir de la réponse JSON (nom, email, rôle)
- Token d'authentification stocké de façon chiffrée avec `flutter_secure_storage`
- Session conservée : au lancement, l'app vérifie le token avec `GET /me.php` et ouvre directement le profil
- Déconnexion via `POST /logout.php` : le token est supprimé côté serveur et sur l'appareil
- Messages d'erreur clairs : identifiants incorrects, serveur injoignable, délai dépassé, réponse invalide
- Indicateur de chargement pendant la connexion
- Validation du formulaire (email valide, mot de passe de 6 caractères minimum)
- Bouton pour afficher / masquer le mot de passe
- Mise en page responsive : portrait et paysage

## Structure

```
lib/
├── main.dart                 # Point d'entrée et thème
├── config/
│   └── api_config.dart       # URL de l'API et timeout
├── models/
│   └── user.dart             # Modèle User (depuis le JSON)
├── screens/
│   ├── start_screen.dart     # Vérifie le token au lancement
│   ├── login_screen.dart     # Écran de connexion
│   └── profile_screen.dart   # Écran de profil
└── services/
    ├── auth_service.dart     # Appels HTTP à l'API (login, me, logout)
    └── token_storage.dart    # Stockage chiffré du token
```

## Fonctionnement du token

1. À la connexion, l'API renvoie un `token` avec le profil. L'app l'enregistre avec `flutter_secure_storage` (chiffré).
2. Au lancement suivant, `StartScreen` lit le token et appelle `GET /me.php` avec l'en-tête `Authorization: Bearer <token>` :
   - 200 : le profil s'ouvre directement ;
   - 401 (token expiré ou supprimé) : le token est effacé et l'écran de connexion s'affiche.
3. À la déconnexion, l'app appelle `POST /logout.php` puis efface le token de l'appareil.

## Lancer le projet

### 1. Lancer l'API

```bash
git clone https://github.com/xKaan/ds-flutter-api.git
cd ds-flutter-api
cp .env.example .env
docker compose up -d --build
```

L'API répond sur http://localhost:8080. Plus de détails dans le README de l'API.

### 2. Lancer l'application

```bash
git clone https://github.com/xKaan/ds-flutter.git
cd ds-flutter
flutter pub get
flutter run
```

Sur l'émulateur Android, l'app appelle `http://10.0.2.2:8080`, qui correspond au `localhost` de la machine où tourne Docker.

Pour utiliser une autre URL (vrai téléphone, serveur distant, HTTPS) :

```bash
flutter run --dart-define=API_BASE_URL=https://mon-serveur.fr
```

## Identifiants de test

| Email | Mot de passe | Rôle |
|---|---|---|
| jean@example.com | Jean2026! | Administrateur (2) |
| marie@example.com | Marie2026! | Utilisateur (1) |

## Sécurité

- Les mots de passe sont hachés avec bcrypt côté serveur, jamais stockés en clair.
- Le token est stocké chiffré sur l'appareil (`flutter_secure_storage`), jamais en clair. Côté serveur, seul son hash est enregistré.
- L'application n'autorise le HTTP non chiffré que vers l'API locale (`10.0.2.2` et `localhost`, voir `android/app/src/main/res/xml/network_security_config.xml`). Tout autre serveur doit être en HTTPS.
- Pour tester en HTTPS sans serveur, on peut exposer l'API locale avec un tunnel :

  ```bash
  cloudflared tunnel --url http://localhost:8080
  ```

  puis lancer l'app avec l'URL `https://xxx.trycloudflare.com` donnée par la commande :

  ```bash
  flutter run --dart-define=API_BASE_URL=https://xxx.trycloudflare.com
  ```

## Captures d'écran
