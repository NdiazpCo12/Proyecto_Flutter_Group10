import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../student/views/student_home_view.dart';
import '../../teacher/bindings/teacher_home_binding.dart';
import '../../teacher/views/teacher_home_view.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';

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

      if (selectedRole.value == UserRole.teacher &&
          emailController.text.trim().isNotEmpty &&
          passwordController.text.isNotEmpty) {
        Get.offAll(
          () => const TeacherHomeView(),
          binding: TeacherHomeBinding(),
        );
        return;
      }

      if (selectedRole.value == UserRole.student &&
          emailController.text.trim().isNotEmpty &&
          passwordController.text.isNotEmpty) {
        Get.offAll(() => const StudentHomeView());
        return;
      }

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
