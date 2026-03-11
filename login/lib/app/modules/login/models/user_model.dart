import 'user_role.dart';

class UserModel {
  final String email;
  final String name;
  final UserRole role;

  const UserModel({
    required this.email,
    required this.name,
    required this.role,
  });
}

class AuthResult {
  final bool success;
  final String message;
  final UserModel? user;

  const AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}
