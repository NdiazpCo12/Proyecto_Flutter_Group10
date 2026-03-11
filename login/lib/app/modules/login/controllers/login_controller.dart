import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';

enum UserRole { student, teacher }

class LoginController extends GetxController {
  LoginController({required AuthService authService})
    : _authService = authService;

  final AuthService _authService;

  final emailController = TextEditingController(text: 'student@university.edu');
  final passwordController = TextEditingController();

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
      final message = await _authService.signIn(
        role: selectedRole.value,
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      Get.snackbar(
        'Login',
        message,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
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
