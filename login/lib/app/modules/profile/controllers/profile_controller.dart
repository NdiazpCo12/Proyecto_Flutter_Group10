import 'package:get/get.dart';

import '../../login/models/user_model.dart';
import '../../login/models/user_role.dart';

class ProfileController extends GetxController {
  // User data - will be populated from login/AuthService
  final userName = ''.obs;
  final userEmail = ''.obs;
  final userRole = Rx<UserRole?>(null);

  // Notification settings
  final emailNotifications = true.obs;
  final assessmentReminders = true.obs;
  final newResults = true.obs;

  @override
  void onInit() {
    super.onInit();
    // In a real app, this would come from the AuthService or a user session
    // For now, we'll use mock data based on what was entered in login
    _loadUserData();
  }

  void _loadUserData() {
    // Mock user data - in production this would come from GetStorage or AuthService
    // Using the same mock data pattern from AuthService
    userName.value = 'Student';
    userEmail.value = 'student@university.edu';
    userRole.value = UserRole.student;
  }

  void updateUserFromLogin(UserModel user) {
    userName.value = user.name;
    userEmail.value = user.email;
    userRole.value = user.role;
  }

  String get roleDisplayName {
    if (userRole.value == UserRole.student) {
      return 'Student';
    } else if (userRole.value == UserRole.teacher) {
      return 'Professor';
    }
    return 'User';
  }

  String get department {
    return 'Computer Science Department';
  }

  String get accountType {
    if (userRole.value == UserRole.student) {
      return 'Student Account';
    } else if (userRole.value == UserRole.teacher) {
      return 'Professor Account';
    }
    return 'Account';
  }

  void toggleEmailNotifications(bool value) {
    emailNotifications.value = value;
  }

  void toggleAssessmentReminders(bool value) {
    assessmentReminders.value = value;
  }

  void toggleNewResults(bool value) {
    newResults.value = value;
  }

  void logout() {
    // Clear user data
    userName.value = '';
    userEmail.value = '';
    userRole.value = null;
    
    // Navigate to login
    Get.offAllNamed('/login');
  }
}
