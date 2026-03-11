import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../login/models/user_role.dart';
import '../../profile/controllers/profile_controller.dart';
import '../models/course_model.dart';

class HomeController extends GetxController {
  // Current selected tab index
  final selectedTabIndex = 0.obs;
  
  // User data from ProfileController
  final userName = ''.obs;
  final userRole = Rx<UserRole?>(null);
  
  // Courses list
  final courses = <CourseModel>[].obs;
  
  // Sync status
  final isSyncing = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load mock courses
    courses.value = CourseModel.mockCourses;
    // Get user data from ProfileController
    _loadUserData();
  }

  void _loadUserData() {
    // Get user data from ProfileController if available
    if (Get.isRegistered<ProfileController>()) {
      final profileController = Get.find<ProfileController>();
      userName.value = profileController.userName.value;
      userRole.value = profileController.userRole.value;
      
      // Listen for changes in ProfileController
      profileController.userName.listen((name) {
        userName.value = name;
      });
      profileController.userRole.listen((role) {
        if (role != null) {
          userRole.value = role;
        }
      });
    } else {
      // Default values
      userName.value = 'Student';
      userRole.value = UserRole.student;
    }
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  Future<void> syncCourses() async {
    if (isSyncing.value) return;
    
    isSyncing.value = true;
    
    // Simulate sync delay
    await Future<void>.delayed(const Duration(seconds: 1));
    
    isSyncing.value = false;
    
    Get.snackbar(
      'Sync Complete',
      'Courses have been synchronized successfully.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }
}
