import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../login/bindings/login_binding.dart';
import '../../login/services/auth_service.dart';
import '../../login/views/login_view.dart';

class StudentHomeView extends StatefulWidget {
  const StudentHomeView({super.key});

  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  int _selectedIndex = 0;
  bool _isSyncing = false;
  bool _emailNotifications = true;
  bool _assessmentReminders = true;
  bool _newResults = true;

  static const _courses = [
    _StudentCourse(
      name: 'Software Engineering',
      code: 'CS 401',
      students: 45,
      activeAssessments: 2,
    ),
    _StudentCourse(
      name: 'Data Structures',
      code: 'CS 302',
      students: 38,
      activeAssessments: 1,
    ),
    _StudentCourse(
      name: 'Mobile Development',
      code: 'CS 330',
      students: 32,
      activeAssessments: 3,
    ),
    _StudentCourse(
      name: 'UI Design',
      code: 'CS 220',
      students: 26,
      activeAssessments: 1,
    ),
  ];

  Future<void> _sync() async {
    if (_isSyncing) {
      return;
    }

    setState(() => _isSyncing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) {
      return;
    }
    setState(() => _isSyncing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Courses synced successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _StudentDashboard(
            isSyncing: _isSyncing,
            onSync: _sync,
            courses: _courses,
          ),
          const _StudentPlaceholder(title: 'Assessments'),
          const _StudentPlaceholder(title: 'Results'),
          _StudentProfile(
            emailNotifications: _emailNotifications,
            assessmentReminders: _assessmentReminders,
            newResults: _newResults,
            onEmailNotificationsChanged: (value) {
              setState(() => _emailNotifications = value);
            },
            onAssessmentRemindersChanged: (value) {
              setState(() => _assessmentReminders = value);
            },
            onNewResultsChanged: (value) {
              setState(() => _newResults = value);
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Assessments',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Results',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _StudentDashboard extends StatelessWidget {
  const _StudentDashboard({
    required this.isSyncing,
    required this.onSync,
    required this.courses,
  });

  final bool isSyncing;
  final VoidCallback onSync;
  final List<_StudentCourse> courses;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(height: 170, color: AppTheme.primaryGreen),
        SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 120),
            children: [
              const Text(
                'Welcome back, asdsdsasd!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Student Dashboard',
                style: TextStyle(fontSize: 16, color: Color(0xFFDDE9DE)),
              ),
              const SizedBox(height: 14),
              _StudentSurfaceCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Brightspace\nIntegration',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Sync your courses and data',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textMuted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: isSyncing ? null : onSync,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      icon: isSyncing
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.sync_rounded, size: 18),
                      label: Text(isSyncing ? 'Syncing' : 'Sync Now'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Enrolled Courses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '${courses.length} courses',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...courses.map(
                (course) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _StudentCourseCard(course: course),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StudentCourseCard extends StatelessWidget {
  const _StudentCourseCard({required this.course});

  final _StudentCourse course;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            course.code,
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: AppTheme.cardTint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.menu_book_outlined,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 18,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${course.students} students',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_outlined,
                      size: 18,
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${course.activeAssessments} active assessments',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
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

class _StudentSurfaceCard extends StatelessWidget {
  const _StudentSurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StudentPlaceholder extends StatelessWidget {
  const _StudentPlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppTheme.textMuted,
        ),
      ),
    );
  }
}

class _StudentProfile extends StatelessWidget {
  const _StudentProfile({
    required this.emailNotifications,
    required this.assessmentReminders,
    required this.newResults,
    required this.onEmailNotificationsChanged,
    required this.onAssessmentRemindersChanged,
    required this.onNewResultsChanged,
  });

  final bool emailNotifications;
  final bool assessmentReminders;
  final bool newResults;
  final ValueChanged<bool> onEmailNotificationsChanged;
  final ValueChanged<bool> onAssessmentRemindersChanged;
  final ValueChanged<bool> onNewResultsChanged;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(height: 120, color: AppTheme.primaryGreen),
        SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 120),
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage your account settings',
                style: TextStyle(fontSize: 16, color: Color(0xFFDDE9DE)),
              ),
              const SizedBox(height: 18),
              _StudentSurfaceCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            color: AppTheme.cardTint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: AppTheme.primaryGreen,
                            size: 38,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Asdsdsdasd',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Student',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(height: 1),
                    const SizedBox(height: 18),
                    const _ProfileInfoRow(
                      icon: Icons.mail_outline,
                      text: 'asdsdsdasd@university.edu',
                    ),
                    const SizedBox(height: 14),
                    const _ProfileInfoRow(
                      icon: Icons.school_outlined,
                      text: 'Computer Science Department',
                    ),
                    const SizedBox(height: 14),
                    const _ProfileInfoRow(
                      icon: Icons.shield_outlined,
                      text: 'Student Account',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              _StudentSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.notifications_none,
                          color: AppTheme.primaryGreen,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Manage your notification preferences',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                    ),
                    const SizedBox(height: 18),
                    _SettingToggleTile(
                      title: 'Email Notifications',
                      subtitle: 'Receive updates via email',
                      value: emailNotifications,
                      onChanged: onEmailNotificationsChanged,
                    ),
                    const Divider(height: 22),
                    _SettingToggleTile(
                      title: 'Assessment Reminders',
                      subtitle: 'Get reminded about due dates',
                      value: assessmentReminders,
                      onChanged: onAssessmentRemindersChanged,
                    ),
                    const Divider(height: 22),
                    _SettingToggleTile(
                      title: 'New Results',
                      subtitle: 'Notify when results are available',
                      value: newResults,
                      onChanged: onNewResultsChanged,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _StudentSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.help_outline, color: AppTheme.primaryGreen),
                        SizedBox(width: 10),
                        Text(
                          'Support',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Get help and support',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                    ),
                    const SizedBox(height: 18),
                    _SupportButton(
                      icon: Icons.help_outline,
                      label: 'Help Center',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _SupportButton(
                      icon: Icons.mail_outline,
                      label: 'Contact Support',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    try {
                      await Get.find<AuthService>().logout();
                    } catch (_) {
                      await Get.find<AuthService>().clearLocalSession();
                    }
                    Get.offAll(
                      () => const LoginView(),
                      binding: LoginBinding(),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD81B45),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Peer Assessment Platform',
                      style: TextStyle(
                        color: AppTheme.secondarySlate,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Powered by Roble • Version 1.0.0',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.secondarySlate),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
      ],
    );
  }
}

class _SettingToggleTile extends StatelessWidget {
  const _SettingToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: AppTheme.primaryGreen,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SupportButton extends StatelessWidget {
  const _SupportButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        backgroundColor: const Color(0xFFF8F8F8),
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _StudentCourse {
  const _StudentCourse({
    required this.name,
    required this.code,
    required this.students,
    required this.activeAssessments,
  });

  final String name;
  final String code;
  final int students;
  final int activeAssessments;
}
