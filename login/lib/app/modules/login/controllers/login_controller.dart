import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../../profile/controllers/profile_controller.dart';

class LoginController extends GetxController {
  LoginController({required AuthService authService})
    : _authService = authService;

  final AuthService _authService;

  final emailController = TextEditingController(text: 'student@university.edu');
  final passwordController = TextEditingController(text: '123456');

  final selectedRole = UserRole.student.obs;
  final isSubmitting = false.obs;

  void selectRole(UserRole role) {
    selectedRole.value = role;
  }

  Future<void> signIn() async {
    if (isSubmitting.value) {
      return;
    }

    isSubmitting.value = true;

    try {
      final result = await _authService.signIn(
        role: selectedRole.value,
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (result.success) {
        Get.snackbar(
          'Success',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF176B22),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        
        // Update ProfileController with user data
        if (result.user != null) {
          final profileController = Get.find<ProfileController>();
          profileController.updateUserFromLogin(result.user!);
        }
        
        // Navigate to home/dashboard
        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          'Login Failed',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
