# Application de connexion Flutter – API REST

Application Flutter de connexion qui authentifie les utilisateurs via une API REST en PHP. L'application envoie l'email et le mot de passe à l'API, lit la réponse JSON et affiche le profil de l'utilisateur connecté.

API utilisée : [ds-flutter-api](https://github.com/xKaan/ds-flutter-api)

## Fonctionnalités

- Connexion via `POST /login.php` avec le package `http`
- Profil affiché à partir de la réponse JSON (nom, email, rôle)
- Messages d'erreur clairs : identifiants incorrects, serveur injoignable, délai dépassé, réponse invalide
- Indicateur de chargement pendant la connexion
- Validation du formulaire (email valide, mot de passe de 6 caractères minimum)
- Bouton pour afficher / masquer le mot de passe
- Mise en page responsive : portrait, paysage, tablette et web

## Structure

```
lib/
├── main.dart                 # Point d'entrée et thème
├── config/
│   └── api_config.dart       # URL de l'API et timeout
├── models/
│   └── user.dart             # Modèle User (depuis le JSON)
├── screens/
│   ├── login_screen.dart     # Écran de connexion
│   └── profile_screen.dart   # Écran de profil
└── services/
    └── auth_service.dart     # Appel HTTP à l'API
```

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

L'URL de l'API est choisie automatiquement :

| Plateforme | URL utilisée |
|---|---|
| Émulateur Android | `http://10.0.2.2:8080` |
| Web, Windows, simulateur iOS | `http://localhost:8080` |

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
