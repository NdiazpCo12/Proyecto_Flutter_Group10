import '../models/user_model.dart';
import '../models/user_role.dart';

class AuthService {
  // Mock credentials storage
  static final Map<String, UserModel> _mockUsers = {
    'student@university.edu': UserModel(
      email: 'student@university.edu',
      name: 'Student',
      role: UserRole.student,
    ),
    'teacher@university.edu': UserModel(
      email: 'teacher@university.edu',
      name: 'Teacher',
      role: UserRole.teacher,
    ),
    'professor@university.edu': UserModel(
      email: 'professor@university.edu',
      name: 'Professor',
      role: UserRole.teacher,
    ),
  };

  static const String mockPassword = '123456';

  Future<AuthResult> signIn({
    required UserRole role,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    // Find user by email
    final user = _mockUsers[email.toLowerCase().trim()];

    if (user == null) {
      return AuthResult(
        success: false,
        message: 'User not found. Please check your email.',
      );
    }

    if (password != mockPassword) {
      return AuthResult(
        success: false,
        message: 'Incorrect password. Please try again.',
      );
    }

    if (user.role != role) {
      final roleLabel = role == UserRole.student ? 'Student' : 'Teacher';
      return AuthResult(
        success: false,
        message: 'This account is not registered as $roleLabel.',
      );
    }

    return AuthResult(
      success: true,
      message: 'Signed in successfully!',
      user: user,
    );
  }
}
