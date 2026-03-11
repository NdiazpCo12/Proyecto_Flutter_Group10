import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../login/models/user_role.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/home_controller.dart';
import '../models/course_model.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header verde oscuro - only show when not on Profile tab
            Obx(() {
              if (controller.selectedTabIndex.value == 3) {
                return const SizedBox.shrink();
              }
              return _buildHeader();
            }),
            // Contenido scrollable
            Expanded(
              child: Obx(() {
                // Show ProfileView when Profile tab is selected
                if (controller.selectedTabIndex.value == 3) {
                  return const ProfileView();
                }
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brightspace Integration Card
                      _buildBrightspaceCard(),
                      const SizedBox(height: 24),
                      // Enrolled Courses Section
                      _buildCoursesSection(),
                    ],
                  ),
                );
              }),
            ),
            // Bottom Navigation Bar
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF176B22),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Obx(() => Text(
            'Welcome back, ${controller.userName.value}!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          )),
          const SizedBox(height: 4),
          Obx(() => Text(
            controller.userRole.value == UserRole.student
                ? 'Student Dashboard'
                : 'Teacher Dashboard',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBrightspaceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Brightspace Integration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sync your courses and data',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Obx(() => ElevatedButton.icon(
            onPressed: controller.isSyncing.value ? null : controller.syncCourses,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: controller.isSyncing.value
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.sync, size: 16),
            label: Text(
              controller.isSyncing.value ? 'Syncing...' : 'Sync Now',
              style: const TextStyle(fontSize: 13),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCoursesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Enrolled Courses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            Obx(() => Text(
              '${controller.courses.length} courses',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            )),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() => Column(
          children: controller.courses
              .map((course) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CourseCard(course: course),
                  ))
              .toList(),
        )),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                isSelected: controller.selectedTabIndex.value == 0,
                onTap: () => controller.changeTab(0),
              ),
              _NavItem(
                icon: Icons.assignment_outlined,
                label: 'Assessments',
                isSelected: controller.selectedTabIndex.value == 1,
                onTap: () => controller.changeTab(1),
              ),
              _NavItem(
                icon: Icons.grade_outlined,
                label: 'Results',
                isSelected: controller.selectedTabIndex.value == 2,
                onTap: () => controller.changeTab(2),
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                isSelected: controller.selectedTabIndex.value == 3,
                onTap: () => controller.changeTab(3),
              ),
            ],
          )),
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Green accent bar at top
          Container(
            height: 5,
            decoration: const BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            course.code,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: AppTheme.primaryGreen,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 16,
                      color: Color(0xFF5F6B7A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${course.studentCount} students',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5F6B7A),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.assignment_outlined,
                      size: 16,
                      color: Color(0xFF5F6B7A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${course.activeAssessments} active assessments',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5F6B7A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppTheme.primaryGreen : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppTheme.primaryGreen : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
