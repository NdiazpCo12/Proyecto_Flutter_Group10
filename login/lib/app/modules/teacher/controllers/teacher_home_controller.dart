import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../login/services/auth_service.dart';
import '../data/teacher_mock_data.dart';
import '../models/teacher_models.dart';

class TeacherHomeController extends GetxController {
  final selectedTab = 0.obs;
  final isSyncing = false.obs;
  final displayName = 'Teacher'.obs;

  List<TeacherCourse> get courses => TeacherMockData.courses;
  List<TeacherEvaluation> get evaluations => TeacherMockData.evaluations;
  List<TeacherGroup> get groups => TeacherMockData.groups;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  Future<void> syncWithBrightspace() async {
    if (isSyncing.value) {
      return;
    }

    isSyncing.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    isSyncing.value = false;

    Get.snackbar(
      'Brightspace',
      'Courses and groups were synced successfully.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  List<TeacherGroup> groupsForCourse(String courseId) {
    return groups.where((group) => group.courseId == courseId).toList();
  }

  List<TeacherEvaluation> evaluationsForCourse(String courseId) {
    return evaluations
        .where((evaluation) => evaluation.courseId == courseId)
        .toList();
  }

  Future<void> _loadCurrentUser() async {
    final user = await Get.find<AuthService>().getStoredUser();
    final name = user?.name.trim();

    if (name == null || name.isEmpty) {
      return;
    }

    displayName.value = name;
  }
}
