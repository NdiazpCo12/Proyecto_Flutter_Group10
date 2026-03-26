import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/errors/error_message_formatter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/roble/roble.dart';
import '../../login/bindings/login_binding.dart';
import '../../login/models/auth_user.dart';
import '../../login/services/auth_service.dart';
import '../../login/views/login_view.dart';

part 'student_dashboard_view.dart';
part 'student_shared_widgets.dart';
part 'student_assessments_view.dart';
part 'student_results_view.dart';
part 'student_profile_view.dart';

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
  String _displayName = 'Student';
  bool _isLoadingCourses = true;
  List<StudentCourseEnrollment> _courses = [];
  final RobleApiService _api = RobleApiService();

  final List<_StudentAssessment> _assessments = _buildMockAssessments();
  static const _resultsSummary = _StudentResultsSummary(
    overallScore: 4.5,
    assessmentCount: 3,
    reviewCount: 12,
    criteria: [
      _StudentCriterionScore(label: 'Punctuality', score: 4.5),
      _StudentCriterionScore(label: 'Contributions', score: 4.2),
      _StudentCriterionScore(label: 'Commitment', score: 4.7),
      _StudentCriterionScore(label: 'Attitude', score: 4.6),
    ],
    history: [
      _StudentAssessmentHistoryItem(
        title: 'Sprint 1 Review',
        date: 'Feb 15, 2026',
        score: 4.5,
      ),
      _StudentAssessmentHistoryItem(
        title: 'Lab Evaluation',
        date: 'Feb 8, 2026',
        score: 4.3,
      ),
      _StudentAssessmentHistoryItem(
        title: 'Project Milestone',
        date: 'Jan 25, 2026',
        score: 4.6,
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    setState(() => _isLoadingCourses = true);
    try {
      final user = await Get.find<AuthService>().getStoredUser();
      final email = user?.email ?? '';
      final fetched = await _api.getStudentEnrollments(email);
      if (!mounted) return;
      setState(() {
        _courses = fetched;
        _isLoadingCourses = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingCourses = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            formatUserErrorMessage(
              e,
              fallback: 'No se pudo cargar la informacion del curso.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _loadCurrentUser() async {
    final user = await Get.find<AuthService>().getStoredUser();
    final name = user?.name.trim();

    if (!mounted || name == null || name.isEmpty) {
      return;
    }

    setState(() {
      _displayName = name;
    });
  }

  Future<void> _sync() async {
    if (_isSyncing) {
      return;
    }

    setState(() => _isSyncing = true);
    await _fetchCourses();
    if (!mounted) return;

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
            isLoadingCourses: _isLoadingCourses,
            onSync: _sync,
            courses: _courses,
            displayName: _displayName,
          ),
          _StudentAssessmentsView(assessments: _assessments),
          const _StudentResultsView(summary: _resultsSummary),
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

class _StudentAssessment {
  _StudentAssessment({
    required this.title,
    required this.courseCode,
    required this.courseName,
    required this.dueDate,
    required this.groupType,
    required this.criteria,
    required this.teammates,
    required this.isSubmitted,
  });

  final String title;
  final String courseCode;
  final String courseName;
  final String dueDate;
  final String groupType;
  final List<_StudentCriterion> criteria;
  final List<_StudentTeammateEvaluation> teammates;
  bool isSubmitted;
}

class _StudentCriterion {
  const _StudentCriterion({
    required this.id,
    required this.title,
    required this.description,
    required this.ratingLabels,
  });

  final String id;
  final String title;
  final String description;
  final Map<int, String> ratingLabels;
}

class _StudentTeammateEvaluation {
  _StudentTeammateEvaluation({
    required this.name,
    required Map<String, int> ratings,
  }) : ratings = Map<String, int>.from(ratings);

  final String name;
  final Map<String, int> ratings;
}

class _StudentResultsSummary {
  const _StudentResultsSummary({
    required this.overallScore,
    required this.assessmentCount,
    required this.reviewCount,
    required this.criteria,
    required this.history,
  });

  final double overallScore;
  final int assessmentCount;
  final int reviewCount;
  final List<_StudentCriterionScore> criteria;
  final List<_StudentAssessmentHistoryItem> history;
}

class _StudentCriterionScore {
  const _StudentCriterionScore({required this.label, required this.score});

  final String label;
  final double score;
}

class _StudentAssessmentHistoryItem {
  const _StudentAssessmentHistoryItem({
    required this.title,
    required this.date,
    required this.score,
  });

  final String title;
  final String date;
  final double score;
}

List<_StudentAssessment> _buildMockAssessments() {
  const criteria = [
    _StudentCriterion(
      id: 'punctuality',
      title: 'Punctuality',
      description: 'Arrives on time for meetings and meets deadlines',
      ratingLabels: {
        1: 'Poor: Rarely on time and often misses deadlines',
        2: 'Below Average: Sometimes late and inconsistent with deadlines',
        3: 'Average: Usually punctual with minor delays',
        4: 'Good: Consistently on time and meets deadlines',
        5: 'Excellent: Always prepared and reliably ahead of schedule',
      },
    ),
    _StudentCriterion(
      id: 'contributions',
      title: 'Contributions',
      description: 'Quality and quantity of work contributed to the team',
      ratingLabels: {
        1: 'Poor: Minimal contribution to team deliverables',
        2: 'Below Average: Inconsistent contribution to shared work',
        3: 'Average: Completes assigned work satisfactorily',
        4: 'Good: Strong contributions that support the team',
        5: 'Excellent: Outstanding contributions that elevate the team',
      },
    ),
    _StudentCriterion(
      id: 'commitment',
      title: 'Commitment',
      description: 'Dedication to team goals and willingness to help',
      ratingLabels: {
        1: 'Poor: Rarely engaged with team goals',
        2: 'Below Average: Needs reminders to stay engaged',
        3: 'Average: Committed to assigned tasks',
        4: 'Good: Invested in helping the whole team succeed',
        5: 'Excellent: Exceptionally dependable and team-oriented',
      },
    ),
    _StudentCriterion(
      id: 'attitude',
      title: 'Attitude',
      description: 'Positivity, collaboration, and team dynamics',
      ratingLabels: {
        1: 'Poor: Negative impact on collaboration',
        2: 'Below Average: Sometimes displays poor attitude',
        3: 'Average: Maintains a workable team attitude',
        4: 'Good: Very positive and supportive team member',
        5: 'Excellent: Inspires strong collaboration and morale',
      },
    ),
  ];

  return [
    _StudentAssessment(
      title: 'Sprint 1 Team Review',
      courseCode: 'CS 401',
      courseName: 'Software Engineering',
      dueDate: 'Feb 28, 2026',
      groupType: 'Project Teams',
      isSubmitted: false,
      criteria: criteria,
      teammates: [
        _StudentTeammateEvaluation(
          name: 'Alice Johnson',
          ratings: {
            'punctuality': 4,
            'contributions': 5,
            'commitment': 3,
            'attitude': 2,
          },
        ),
        _StudentTeammateEvaluation(
          name: 'David Lee',
          ratings: {
            'punctuality': 3,
            'contributions': 3,
            'commitment': 3,
            'attitude': 4,
          },
        ),
        _StudentTeammateEvaluation(
          name: 'Maria Garcia',
          ratings: {
            'punctuality': 5,
            'contributions': 4,
            'commitment': 5,
            'attitude': 5,
          },
        ),
        _StudentTeammateEvaluation(
          name: 'Noah Wilson',
          ratings: {
            'punctuality': 4,
            'contributions': 4,
            'commitment': 4,
            'attitude': 4,
          },
        ),
      ],
    ),
    _StudentAssessment(
      title: 'Lab Group Evaluation',
      courseCode: 'CS 302',
      courseName: 'Data Structures',
      dueDate: 'Mar 1, 2026',
      groupType: 'Lab Groups',
      isSubmitted: false,
      criteria: criteria,
      teammates: [
        _StudentTeammateEvaluation(
          name: 'Emma Carter',
          ratings: {
            'punctuality': 4,
            'contributions': 4,
            'commitment': 5,
            'attitude': 4,
          },
        ),
        _StudentTeammateEvaluation(
          name: 'Liam Brown',
          ratings: {
            'punctuality': 3,
            'contributions': 4,
            'commitment': 3,
            'attitude': 3,
          },
        ),
        _StudentTeammateEvaluation(
          name: 'Sophia Martinez',
          ratings: {
            'punctuality': 5,
            'contributions': 5,
            'commitment': 4,
            'attitude': 5,
          },
        ),
      ],
    ),
  ];
}
