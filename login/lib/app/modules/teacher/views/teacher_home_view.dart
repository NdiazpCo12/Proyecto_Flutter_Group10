import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../login/bindings/login_binding.dart';
import '../../login/views/login_view.dart';
import '../controllers/teacher_home_controller.dart';
import '../models/teacher_models.dart';

class TeacherHomeView extends GetView<TeacherHomeController> {
  const TeacherHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      _TeacherDashboard(controller: controller),
      _TeacherEvaluations(controller: controller),
      _TeacherReports(controller: controller),
      const _TeacherProfile(),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.selectedTab.value,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.selectedTab.value,
          onDestinationSelected: controller.changeTab,
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
      ),
    );
  }
}

class _TeacherUiState {
  _TeacherUiState._();

  static final emailNotifications = true.obs;
  static final assessmentReminders = true.obs;
  static final newResults = true.obs;
  static final selectedGroup = 'Team A'.obs;
  static final expandedStudent = 'Alice Johnson'.obs;
}

class TeacherCourseDetailView extends GetView<TeacherHomeController> {
  const TeacherCourseDetailView({super.key, required this.course});

  final TeacherCourse course;

  @override
  Widget build(BuildContext context) {
    final groups = controller.groupsForCourse(course.id);
    final evaluations = controller.evaluationsForCourse(course.id);

    return Scaffold(
      appBar: AppBar(title: Text(course.name)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.code,
                  style: const TextStyle(color: AppTheme.textMuted),
                ),
                const SizedBox(height: 8),
                Text(
                  course.term,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _MiniInfo(
                        label: 'Students',
                        value: course.studentCount.toString(),
                      ),
                    ),
                    Expanded(
                      child: _MiniInfo(
                        label: 'Groups',
                        value: course.groupCount.toString(),
                      ),
                    ),
                    Expanded(
                      child: _MiniInfo(
                        label: 'Pending',
                        value: course.pendingEvaluations.toString(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enrollment tools',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Share invite code, link or QR to add students to the course.',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.key_outlined),
                      label: const Text('Generate code'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.link_outlined),
                      label: const Text('Copy invite link'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.qr_code_2_outlined),
                      label: const Text('Show QR'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Groups',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: controller.syncWithBrightspace,
                      icon: const Icon(Icons.sync),
                      label: const Text('Import'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...groups.map(
                  (group) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.cardTint,
                      child: Text(
                        group.name.replaceAll('Group ', '').substring(0, 1),
                        style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    title: Text(group.name),
                    subtitle: Text(
                      '${group.members.length} students - Avg ${group.averageScore.toStringAsFixed(1)}',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Evaluations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ...evaluations.map(
                  (evaluation) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(evaluation.title),
                    subtitle: Text(
                      '${evaluation.dateRange} - ${evaluation.visibility}',
                    ),
                    trailing: _StatusChip(
                      label: evaluation.status,
                      tone: evaluation.status == 'Active'
                          ? AppTheme.primaryGreen
                          : AppTheme.secondarySlate,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TeacherEvaluationBuilderView extends StatefulWidget {
  const TeacherEvaluationBuilderView({super.key});

  @override
  State<TeacherEvaluationBuilderView> createState() =>
      _TeacherEvaluationBuilderViewState();
}

class _TeacherEvaluationBuilderViewState
    extends State<TeacherEvaluationBuilderView> {
  final _nameController = TextEditingController();
  String _course = 'Mobile Development';
  String _groupCategory = 'Project Teams';
  bool _publicResults = true;
  double _durationDays = 7;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppTheme.primaryGreen,
            padding: const EdgeInsets.fromLTRB(22, 52, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: Get.back,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Create Assessment',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Set up a new peer assessment',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFDDE9DE),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                _SurfaceCard(
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assessment Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Basic information about the assessment',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const _FieldLabel('Assessment Name *'),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Sprint 1 Team Review',
                        ),
                      ),
                      const SizedBox(height: 18),
                      _SelectorTile<String>(
                        label: 'Course *',
                        hint: 'Select a course',
                        value: _course,
                        options: const [
                          'Mobile Development',
                          'UX Engineering',
                          'Software Architecture',
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() => _course = value);
                        },
                      ),
                      const SizedBox(height: 18),
                      _SelectorTile<String>(
                        label: 'Group Category *',
                        hint: 'Select group category',
                        value: _groupCategory,
                        options: const ['Project Teams', 'Lab Groups', 'Squads'],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() => _groupCategory = value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SurfaceCard(
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: AppTheme.primaryGreen,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Time Window',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'How long will students have to complete this?',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 16,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Duration (days)',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            _durationDays.round().toString(),
                            style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _durationDays,
                        min: 1,
                        max: 30,
                        divisions: 29,
                        activeColor: AppTheme.primaryGreen,
                        onChanged: (value) {
                          setState(() => _durationDays = value);
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            Text(
                              '1 day',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            Spacer(),
                            Text(
                              '30 days',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SurfaceCard(
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.remove_red_eye_outlined,
                            color: AppTheme.primaryGreen,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Visibility Settings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Control who can see the results',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Public Results',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Students can view their results',
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _publicResults,
                            activeThumbColor: AppTheme.primaryGreen,
                            onChanged: (value) {
                              setState(() => _publicResults = value);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Get.snackbar(
                        'Assessment created',
                        'The assessment is ready to be published.',
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Create Assessment'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: Get.back,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherDashboard extends StatelessWidget {
  const _TeacherDashboard({required this.controller});

  final TeacherHomeController controller;

  @override
  Widget build(BuildContext context) {
    final courses = controller.courses;

    return Stack(
      children: [
        Container(
          height: 210,
          color: AppTheme.primaryGreen,
        ),
        SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 120),
            children: [
              const Text(
                'Welcome back, teacher!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Teacher Dashboard',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFD4E4D6),
                ),
              ),
              const SizedBox(height: 18),
              _SurfaceCard(
                borderRadius: 28,
                padding: const EdgeInsets.all(22),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Brightspace\nIntegration',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 10),
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
                    const SizedBox(width: 16),
                    Obx(
                      () => FilledButton.icon(
                        onPressed: controller.isSyncing.value
                            ? null
                            : controller.syncWithBrightspace,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        icon: controller.isSyncing.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.sync_rounded),
                        label: Text(
                          controller.isSyncing.value
                              ? 'Syncing'
                              : 'Sync Now',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 34),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Enrolled Courses',
                      style: TextStyle(
                        fontSize: 22,
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
              const SizedBox(height: 16),
              ...courses.map(
                (course) => Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: _CourseCard(
                    course: course,
                    onTap: () {
                      Get.to(() => TeacherCourseDetailView(course: course));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeacherEvaluations extends StatelessWidget {
  const _TeacherEvaluations({required this.controller});

  final TeacherHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: AppTheme.primaryGreen,
          padding: const EdgeInsets.fromLTRB(16, 56, 16, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assessments',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Manage peer assessments',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFDDE9DE),
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  Get.to(() => const TeacherEvaluationBuilderView());
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 120),
            children: controller.evaluations
                .map(
                  (evaluation) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _AssessmentCard(evaluation: evaluation),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({required this.evaluation});

  final TeacherEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    final isActive = evaluation.status == 'Active';
    final total = isActive ? 45 : 38;
    final progress = total == 0 ? 0.0 : evaluation.responses / total;

    return _SurfaceCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PillTag(
                label: isActive ? 'Active' : 'Upcoming',
                color: isActive ? AppTheme.primaryGreen : const Color(0xFF73C79B),
              ),
              const Spacer(),
              Icon(
                isActive ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 18,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            evaluation.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            evaluation.courseId == 'mobile'
                ? 'CS 401'
                : evaluation.courseId == 'ux'
                ? 'CS 302'
                : 'CS 201',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 10),
              Text(
                'Due: ${_mockDueDate(evaluation)}',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.people_outline,
                size: 18,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 10),
              Text(
                evaluation.groupCategory,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Completion',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
              Text(
                '${evaluation.responses}/$total',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFE0E0E0),
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherReports extends StatelessWidget {
  const _TeacherReports({required this.controller});

  final TeacherHomeController controller;

  @override
  Widget build(BuildContext context) {
    const activityBars = [
      _ChartBar(label: 'Sprint 1', value: 4.2, color: AppTheme.primaryGreen),
      _ChartBar(label: 'Sprint 2', value: 4.5, color: AppTheme.primaryGreen, highlighted: true),
      _ChartBar(label: 'Sprint 3', value: 4.3, color: AppTheme.primaryGreen),
      _ChartBar(label: 'Midterm', value: 4.1, color: AppTheme.primaryGreen),
    ];
    const teamBars = [
      _ChartBar(label: 'Team A', value: 4.6, color: AppTheme.secondarySlate),
      _ChartBar(label: 'Team B', value: 4.4, color: AppTheme.secondarySlate),
      _ChartBar(label: 'Team C', value: 4.7, color: AppTheme.secondarySlate, highlighted: true),
      _ChartBar(label: 'Team D', value: 4.3, color: AppTheme.secondarySlate),
      _ChartBar(label: 'Team E', value: 4.5, color: AppTheme.secondarySlate),
    ];
    const students = [
      _BreakdownStudent(
        initials: 'AJ',
        name: 'Alice Johnson',
        average: 4.5,
        details: {
          'Punctuality': 4.5,
          'Contributions': 4.3,
          'Commitment': 4.6,
          'Attitude': 4.7,
        },
      ),
      _BreakdownStudent(initials: 'BS', name: 'Bob Smith', average: 4.4),
      _BreakdownStudent(initials: 'CW', name: 'Carol White', average: 4.7),
      _BreakdownStudent(initials: 'DL', name: 'David Lee', average: 4.2),
    ];

    return Stack(
      children: [
        Container(height: 100, color: AppTheme.primaryGreen),
        SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 120),
            children: [
              const Text(
                'Analytics Hub',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'View assessment insights and trends',
                style: TextStyle(fontSize: 16, color: Color(0xFFDDE9DE)),
              ),
              const SizedBox(height: 20),
              const _MetricSummaryCard(
                icon: Icons.trending_up,
                title: 'Overall Engagement',
                value: '87%',
                subtitle: 'Student participation rate',
              ),
              const SizedBox(height: 14),
              const _MetricSummaryCard(
                icon: Icons.people_outline,
                title: 'Average Score',
                value: '4.3',
                subtitle: 'Out of 5.0',
              ),
              const SizedBox(height: 14),
              const _ChartCard(
                title: 'Activity Average',
                subtitle: 'Average scores across assessments',
                bars: activityBars,
                tooltipLabel: 'Sprint 2',
                tooltipValue: 'average : 4.5',
              ),
              const SizedBox(height: 14),
              const _ChartCard(
                title: 'Team Performance',
                subtitle: 'Average scores by team',
                bars: teamBars,
                tooltipLabel: 'Team C',
                tooltipValue: 'average : 4.7',
              ),
              const SizedBox(height: 14),
              _SurfaceCard(
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detailed Breakdown',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'View individual student scores',
                      style: TextStyle(fontSize: 16, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 18),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        initialValue: _TeacherUiState.selectedGroup.value,
                        decoration: const InputDecoration(),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        items: const [
                          DropdownMenuItem(value: 'Team A', child: Text('Team A')),
                          DropdownMenuItem(value: 'Team B', child: Text('Team B')),
                          DropdownMenuItem(value: 'Team C', child: Text('Team C')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _TeacherUiState.selectedGroup.value = value;
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...students.map(
                      (student) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Obx(
                          () => _StudentBreakdownCard(
                            student: student,
                            expanded: _TeacherUiState.expandedStudent.value == student.name,
                            onToggle: () {
                              _TeacherUiState.expandedStudent.value =
                                  _TeacherUiState.expandedStudent.value == student.name ? '' : student.name;
                            },
                          ),
                        ),
                      ),
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

class _TeacherProfile extends StatelessWidget {
  const _TeacherProfile();

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
              _SurfaceCard(
                borderRadius: 20,
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
                                'Dasdsada',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Teacher',
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
                    const _TeacherInfoRow(
                      icon: Icons.mail_outline,
                      text: 'dasdsada@university.edu',
                    ),
                    const SizedBox(height: 14),
                    const _TeacherInfoRow(
                      icon: Icons.school_outlined,
                      text: 'Computer Science Department',
                    ),
                    const SizedBox(height: 14),
                    const _TeacherInfoRow(
                      icon: Icons.shield_outlined,
                      text: 'Teacher Account',
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
              _SurfaceCard(
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notifications_none, color: AppTheme.primaryGreen),
                        SizedBox(width: 10),
                        Text(
                          'Notifications',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Manage your notification preferences',
                      style: TextStyle(fontSize: 16, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 18),
                    Obx(
                      () => _TeacherToggleTile(
                        title: 'Email Notifications',
                        subtitle: 'Receive updates via email',
                        value: _TeacherUiState.emailNotifications.value,
                        onChanged: (value) {
                          _TeacherUiState.emailNotifications.value = value;
                        },
                      ),
                    ),
                    const Divider(height: 22),
                    Obx(
                      () => _TeacherToggleTile(
                        title: 'Assessment Reminders',
                        subtitle: 'Get reminded about due dates',
                        value: _TeacherUiState.assessmentReminders.value,
                        onChanged: (value) {
                          _TeacherUiState.assessmentReminders.value = value;
                        },
                      ),
                    ),
                    const Divider(height: 22),
                    Obx(
                      () => _TeacherToggleTile(
                        title: 'New Results',
                        subtitle: 'Notify when results are available',
                        value: _TeacherUiState.newResults.value,
                        onChanged: (value) {
                          _TeacherUiState.newResults.value = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SurfaceCard(
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.help_outline, color: AppTheme.primaryGreen),
                        SizedBox(width: 10),
                        Text(
                          'Support',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Get help and support',
                      style: TextStyle(fontSize: 16, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 18),
                    _TeacherSupportButton(
                      icon: Icons.help_outline,
                      label: 'Help Center',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _TeacherSupportButton(
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
                  onPressed: () {
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
                  label: const Text('Log Out'),
                ),
              ),
              const SizedBox(height: 18),
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Peer Assessment Platform',
                      style: TextStyle(color: AppTheme.secondarySlate, fontSize: 16),
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

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.onTap});

  final TeacherCourse course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 12,
              decoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(26),
                  topRight: Radius.circular(26),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              course.code,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          color: AppTheme.cardTint,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          course.status == 'Closed'
                              ? Icons.archive_outlined
                              : Icons.menu_book_outlined,
                          color: AppTheme.primaryGreen,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 20,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${course.studentCount} students',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_outlined,
                        size: 20,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${course.pendingEvaluations} active assessments',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 22,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppTheme.textMuted)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.tone});

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: tone, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _PillTag extends StatelessWidget {
  const _PillTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _mockDueDate(TeacherEvaluation evaluation) {
  switch (evaluation.id) {
    case 'eval-1':
      return 'Feb 28, 2026';
    case 'eval-2':
      return 'Mar 5, 2026';
    default:
      return 'Mar 12, 2026';
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.w700),
    );
  }
}

class _SelectorTile<T> extends StatelessWidget {
  const _SelectorTile({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final T value;
  final List<T> options;
  final ValueChanged<T?> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          decoration: InputDecoration(
            hintText: hint,
          ),
          borderRadius: BorderRadius.circular(18),
          items: options
              .map(
                (option) => DropdownMenuItem<T>(
                  value: option,
                  child: Text(option.toString()),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _MetricSummaryCard extends StatelessWidget {
  const _MetricSummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryGreen),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 16, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.bars,
    required this.tooltipLabel,
    required this.tooltipValue,
  });

  final String title;
  final String subtitle;
  final List<_ChartBar> bars;
  final String tooltipLabel;
  final String tooltipValue;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(fontSize: 16, color: AppTheme.textMuted)),
          const SizedBox(height: 18),
          _MiniBarChart(
            bars: bars,
            tooltipLabel: tooltipLabel,
            tooltipValue: tooltipValue,
          ),
        ],
      ),
    );
  }
}

class _MiniBarChart extends StatefulWidget {
  const _MiniBarChart({
    required this.bars,
    required this.tooltipLabel,
    required this.tooltipValue,
  });

  final List<_ChartBar> bars;
  final String tooltipLabel;
  final String tooltipValue;

  @override
  State<_MiniBarChart> createState() => _MiniBarChartState();
}

class _MiniBarChartState extends State<_MiniBarChart> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(left: 28, top: 12, right: 8, bottom: 42),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE1E3E6)),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(left: 28, top: 12, right: 8, bottom: 42),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  3,
                  (_) => Container(height: 1, color: const Color(0xFFE1E3E6)),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 6,
            bottom: 34,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text('5', style: TextStyle(color: AppTheme.secondarySlate)),
                Text('2', style: TextStyle(color: AppTheme.secondarySlate)),
                Text('0', style: TextStyle(color: AppTheme.secondarySlate)),
              ],
            ),
          ),
          Positioned(
            left: 38,
            right: 12,
            bottom: 12,
            top: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: widget.bars
                  .map(
                    (bar) {
                      final index = widget.bars.indexOf(bar);
                      final isHovered = _hoveredIndex == index;

                      return MouseRegion(
                        onEnter: (_) {
                          setState(() => _hoveredIndex = index);
                        },
                        onExit: (_) {
                          setState(() => _hoveredIndex = null);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isHovered)
                              Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xFFD8DDE3)),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x12000000),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(bar.label, style: const TextStyle(fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text(
                                      'average : ${bar.value.toStringAsFixed(1)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.primaryGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              const SizedBox(height: 54),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              width: 32,
                              height: (bar.value / 5) * 120,
                              decoration: BoxDecoration(
                                color: bar.color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 18,
                              child: Text(
                                bar.label,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.secondarySlate,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartBar {
  const _ChartBar({
    required this.label,
    required this.value,
    required this.color,
    this.highlighted = false,
  });

  final String label;
  final double value;
  final Color color;
  final bool highlighted;
}

class _BreakdownStudent {
  const _BreakdownStudent({
    required this.initials,
    required this.name,
    required this.average,
    this.details,
  });

  final String initials;
  final String name;
  final double average;
  final Map<String, double>? details;
}

class _StudentBreakdownCard extends StatelessWidget {
  const _StudentBreakdownCard({
    required this.student,
    required this.expanded,
    required this.onToggle,
  });

  final _BreakdownStudent student;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD8DDE3)),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onToggle,
            leading: CircleAvatar(
              backgroundColor: AppTheme.cardTint,
              child: Text(
                student.initials,
                style: const TextStyle(color: AppTheme.primaryGreen),
              ),
            ),
            title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('Average: ${student.average.toStringAsFixed(1)}'),
            trailing: Icon(expanded ? Icons.keyboard_arrow_down : Icons.chevron_right),
          ),
          if (expanded && student.details != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: const BoxDecoration(
                color: AppTheme.cardTint,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Wrap(
                spacing: 24,
                runSpacing: 12,
                children: student.details!.entries
                    .map(
                      (entry) => SizedBox(
                        width: 110,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.key, style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(
                              entry.value.toStringAsFixed(1),
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _TeacherInfoRow extends StatelessWidget {
  const _TeacherInfoRow({required this.icon, required this.text});

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

class _TeacherToggleTile extends StatelessWidget {
  const _TeacherToggleTile({
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
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 14, color: AppTheme.textMuted)),
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

class _TeacherSupportButton extends StatelessWidget {
  const _TeacherSupportButton({
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
