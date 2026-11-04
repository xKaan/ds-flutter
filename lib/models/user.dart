// lib/models/user.dart

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final int role;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  });

  // Lève une FormatException si le JSON est incomplet
  factory User.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final firstName = json['firstName'];
    final lastName = json['lastName'];
    final email = json['email'];
    final role = json['role'];

    if (id is! int ||
        firstName is! String ||
        lastName is! String ||
        email is! String ||
        role is! int) {
      throw const FormatException('Réponse utilisateur invalide');
    }

    return User(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      role: role,
    );
  }

  String get fullName => '$firstName $lastName';

  String get roleLabel {
    switch (role) {
      case 1:
        return 'Utilisateur';
      case 2:
        return 'Administrateur';
      default:
        return 'Rôle $role';
    }
  }
}
