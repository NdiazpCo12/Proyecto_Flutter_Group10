import '../models/user_role.dart';

class AuthService {
  Future<String> signIn({
    required UserRole role,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final roleLabel = role == UserRole.student ? 'Student' : 'Teacher';

    if (email.isEmpty || password.isEmpty) {
      return 'Complete email and password for $roleLabel.';
    }

    return 'Signed in as $roleLabel.';
  }
}
