import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../login/bindings/login_binding.dart';
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
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        Container(
          color: AppTheme.primaryGreen,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Welcome back, asdsdsasd!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Student Dashboard',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFDDE9DE),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
          child: Column(
            children: [
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

class _StudentAssessmentsView extends StatefulWidget {
  const _StudentAssessmentsView({required this.assessments});

  final List<_StudentAssessment> assessments;

  @override
  State<_StudentAssessmentsView> createState() => _StudentAssessmentsViewState();
}

class _StudentAssessmentsViewState extends State<_StudentAssessmentsView> {
  _StudentAssessment? _selectedAssessment;
  int _currentTeammateIndex = 0;

  void _openAssessment(_StudentAssessment assessment) {
    setState(() {
      _selectedAssessment = assessment;
      _currentTeammateIndex = 0;
    });
  }

  void _closeAssessment() {
    setState(() {
      _selectedAssessment = null;
      _currentTeammateIndex = 0;
    });
  }

  void _setRating(_StudentCriterion criterion, int value) {
    final assessment = _selectedAssessment;
    if (assessment == null) {
      return;
    }

    setState(() {
      assessment.teammates[_currentTeammateIndex].ratings[criterion.id] = value;
    });
  }

  Future<void> _goNext() async {
    final assessment = _selectedAssessment;
    if (assessment == null) {
      return;
    }

    if (_currentTeammateIndex < assessment.teammates.length - 1) {
      setState(() => _currentTeammateIndex += 1);
      return;
    }

    final shouldSubmit = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Submit Assessment?',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'You are about to submit your peer assessment for '
            '${assessment.teammates.length} teammates. This action cannot be '
            'undone. Are you sure you want to continue?',
            style: const TextStyle(
              color: AppTheme.textMuted,
              height: 1.5,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text(
                'Yes, Submit',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (shouldSubmit != true || !mounted) {
      return;
    }

    setState(() {
      assessment.isSubmitted = true;
      _selectedAssessment = null;
      _currentTeammateIndex = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${assessment.title} submitted successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assessment = _selectedAssessment;
    if (assessment == null) {
      return _StudentAssessmentList(
        assessments: widget.assessments,
        onOpenAssessment: _openAssessment,
      );
    }

    return _StudentAssessmentDetail(
      assessment: assessment,
      teammate: assessment.teammates[_currentTeammateIndex],
      teammateIndex: _currentTeammateIndex,
      totalTeammates: assessment.teammates.length,
      onBack: _closeAssessment,
      onPrevious: _currentTeammateIndex == 0
          ? null
          : () => setState(() => _currentTeammateIndex -= 1),
      onNext: _goNext,
      onRateCriterion: _setRating,
    );
  }
}

class _StudentAssessmentList extends StatelessWidget {
  const _StudentAssessmentList({
    required this.assessments,
    required this.onOpenAssessment,
  });

  final List<_StudentAssessment> assessments;
  final ValueChanged<_StudentAssessment> onOpenAssessment;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        Container(
          color: AppTheme.primaryGreen,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Assessments',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Complete your evaluations',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFDDE9DE),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
          child: Column(
            children: [
              ...assessments.map(
                (assessment) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _StudentAssessmentCard(
                    assessment: assessment,
                    onTap: assessment.isSubmitted
                        ? null
                        : () => onOpenAssessment(assessment),
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

class _StudentAssessmentCard extends StatelessWidget {
  const _StudentAssessmentCard({
    required this.assessment,
    required this.onTap,
  });

  final _StudentAssessment assessment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: assessment.isSubmitted
                      ? const Color(0xFFE6F4EA)
                      : AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  assessment.isSubmitted ? 'Completed' : 'Active',
                  style: TextStyle(
                    color: assessment.isSubmitted
                        ? AppTheme.primaryGreen
                        : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color: onTap == null
                    ? const Color(0xFFB8C0CC)
                    : AppTheme.secondarySlate,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            assessment.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            assessment.courseCode,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 28),
          _AssessmentMetaRow(
            icon: Icons.calendar_today_outlined,
            text: 'Due: ${assessment.dueDate}',
          ),
          const SizedBox(height: 12),
          _AssessmentMetaRow(
            icon: Icons.group_outlined,
            text: assessment.groupType,
          ),
          const SizedBox(height: 18),
          Text(
            'Evaluate ${assessment.teammates.length} teammates',
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.secondarySlate,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: onTap == null
                    ? const Color(0xFF95B79A)
                    : AppTheme.primaryGreen,
                minimumSize: const Size.fromHeight(36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                assessment.isSubmitted
                    ? 'Assessment Submitted'
                    : 'Start Assessment',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentAssessmentDetail extends StatelessWidget {
  const _StudentAssessmentDetail({
    required this.assessment,
    required this.teammate,
    required this.teammateIndex,
    required this.totalTeammates,
    required this.onBack,
    required this.onPrevious,
    required this.onNext,
    required this.onRateCriterion,
  });

  final _StudentAssessment assessment;
  final _StudentTeammateEvaluation teammate;
  final int teammateIndex;
  final int totalTeammates;
  final VoidCallback onBack;
  final VoidCallback? onPrevious;
  final VoidCallback onNext;
  final void Function(_StudentCriterion criterion, int value) onRateCriterion;

  @override
  Widget build(BuildContext context) {
    final progress = (teammateIndex + 1) / totalTeammates;
    final isLastTeammate = teammateIndex == totalTeammates - 1;

    return Column(
      children: [
        Container(
          color: AppTheme.primaryGreen,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: onBack,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.arrow_back, size: 20),
                    label: const Text(
                      'Back',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    assessment.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${assessment.courseCode} - ${assessment.courseName}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFDDE9DE),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE2E5E8)),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Progress: ${teammateIndex + 1} of $totalTeammates',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${teammateIndex + 1} completed',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFDADDE1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Evaluating: ${teammate.name}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Rate your teammate on the following criteria',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppTheme.primaryGreen,
                                      width: 2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 18,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            ...List.generate(
                              assessment.criteria.length,
                              (index) {
                                final criterion = assessment.criteria[index];
                                final rating = teammate.ratings[criterion.id] ?? 0;
                                return _CriterionRatingRow(
                                  criterion: criterion,
                                  rating: rating,
                                  isLast:
                                      index == assessment.criteria.length - 1,
                                  onChanged: (value) =>
                                      onRateCriterion(criterion, value),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundColor,
                    border: Border(
                      top: BorderSide(color: Color(0xFFE2E5E8)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onPrevious,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            backgroundColor: Colors.white,
                            foregroundColor: onPrevious == null
                                ? const Color(0xFF9DA6B2)
                                : AppTheme.secondarySlate,
                            side: BorderSide(
                              color: onPrevious == null
                                  ? const Color(0xFFE1E4E8)
                                  : const Color(0xFFD2D9DE),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Previous',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: onNext,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            isLastTeammate
                                ? 'Submit Assessment'
                                : 'Next Teammate',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
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

class _CriterionRatingRow extends StatelessWidget {
  const _CriterionRatingRow({
    required this.criterion,
    required this.rating,
    required this.isLast,
    required this.onChanged,
  });

  final _StudentCriterion criterion;
  final int rating;
  final bool isLast;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = criterion.ratingLabels[rating] ?? 'Select a rating';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 700;

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CriterionDescription(criterion: criterion),
                    const SizedBox(height: 20),
                    _CriterionStars(
                      rating: rating,
                      label: label,
                      onChanged: onChanged,
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _CriterionDescription(criterion: criterion),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: _CriterionStars(
                      rating: rating,
                      label: label,
                      onChanged: onChanged,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFE2E5E8)),
      ],
    );
  }
}

class _CriterionDescription extends StatelessWidget {
  const _CriterionDescription({required this.criterion});

  final _StudentCriterion criterion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              criterion.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.info_outline,
              size: 18,
              color: AppTheme.textMuted,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          criterion.description,
          style: const TextStyle(
            fontSize: 15,
            color: AppTheme.secondarySlate,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _CriterionStars extends StatelessWidget {
  const _CriterionStars({
    required this.rating,
    required this.label,
    required this.onChanged,
  });

  final int rating;
  final String label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 2,
          children: List.generate(
            5,
            (index) {
              final starValue = index + 1;
              final isFilled = starValue <= rating;
              return IconButton(
                onPressed: () => onChanged(starValue),
                visualDensity: VisualDensity.compact,
                splashRadius: 22,
                iconSize: 36,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 40,
                  height: 40,
                ),
                icon: Icon(
                  isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                  color:
                      isFilled ? const Color(0xFFFFC107) : const Color(0xFFCBD2DB),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.secondarySlate,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _AssessmentMetaRow extends StatelessWidget {
  const _AssessmentMetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textMuted),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            color: AppTheme.secondarySlate,
          ),
        ),
      ],
    );
  }
}

class _StudentResultsView extends StatelessWidget {
  const _StudentResultsView({required this.summary});

  final _StudentResultsSummary summary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        Container(
          color: AppTheme.primaryGreen,
          child: SafeArea(
            bottom: false,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(22, 22, 22, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Results',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'View your peer assessment feedback',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFDDE9DE),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
          child: Column(
            children: [
              _StudentSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Performance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your average score across all criteria',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.secondarySlate,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            summary.overallScore.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 46,
                              height: 1,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Out of 5.0',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppTheme.secondarySlate,
                            ),
                          ),
                          const SizedBox(height: 26),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _ResultsStat(
                                value: '${summary.assessmentCount}',
                                label: 'Assessments',
                              ),
                              const SizedBox(width: 30),
                              _ResultsStat(
                                value: '${summary.reviewCount}',
                                label: 'Reviews',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _StudentSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Criteria Breakdown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your scores by evaluation criteria',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.secondarySlate,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: SizedBox(
                        width: 320,
                        height: 320,
                        child: _RadarChart(scores: summary.criteria),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _StudentSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detailed Scores',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Breakdown by criteria',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.secondarySlate,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...summary.criteria.map(
                      (criterion) => Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _DetailedScoreRow(score: criterion),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _StudentSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assessment History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your past peer assessments',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.secondarySlate,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...summary.history.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AssessmentHistoryCard(item: item),
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

class _ResultsStat extends StatelessWidget {
  const _ResultsStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: AppTheme.secondarySlate,
          ),
        ),
      ],
    );
  }
}

class _DetailedScoreRow extends StatelessWidget {
  const _DetailedScoreRow({required this.score});

  final _StudentCriterionScore score;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;
        final bar = Expanded(
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: score.score / 5,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFD9D9D9),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 42,
                child: Text(
                  score.score.toStringAsFixed(1),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                score.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Row(children: [bar]),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: Text(
                score.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(child: bar),
          ],
        );
      },
    );
  }
}

class _AssessmentHistoryCard extends StatelessWidget {
  const _AssessmentHistoryCard({required this.item});

  final _StudentAssessmentHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7F0),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.date,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.secondarySlate,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.score.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarChart extends StatefulWidget {
  const _RadarChart({required this.scores});

  final List<_StudentCriterionScore> scores;

  @override
  State<_RadarChart> createState() => _RadarChartState();
}

class _RadarChartState extends State<_RadarChart> {
  int? _activeIndex;

  void _updateActiveIndex(Offset localPosition, Size size) {
    final index = _RadarChartPainter.hitTestIndex(
      localPosition: localPosition,
      size: size,
      scores: widget.scores,
    );
    setState(() => _activeIndex = index);
  }

  void _clearActiveIndex() {
    if (_activeIndex != null) {
      setState(() => _activeIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final tooltipPosition = _activeIndex == null
            ? null
            : _RadarChartPainter.tooltipPositionForIndex(
                index: _activeIndex!,
                size: size,
                scores: widget.scores,
              );

        return MouseRegion(
          onHover: (event) => _updateActiveIndex(event.localPosition, size),
          onExit: (_) => _clearActiveIndex(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => _updateActiveIndex(details.localPosition, size),
            onPanDown: (details) => _updateActiveIndex(details.localPosition, size),
            onPanUpdate: (details) =>
                _updateActiveIndex(details.localPosition, size),
            onTap: () {},
            child: Stack(
              children: [
                CustomPaint(
                  painter: _RadarChartPainter(
                    scores: widget.scores,
                    activeIndex: _activeIndex,
                  ),
                  child: const SizedBox.expand(),
                ),
                if (_activeIndex != null && tooltipPosition != null)
                  Positioned(
                    left: tooltipPosition.dx,
                    top: tooltipPosition.dy,
                    child: IgnorePointer(
                      child: Container(
                        width: 94,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFD3D3D3)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x16000000),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.scores[_activeIndex!].label,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Score : ${widget.scores[_activeIndex!].score.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  _RadarChartPainter({required this.scores, this.activeIndex});

  final List<_StudentCriterionScore> scores;
  final int? activeIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) {
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.34;
    final axisPaint = Paint()
      ..color = const Color(0xFF6F796D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final fillPaint = Paint()
      ..color = AppTheme.primaryGreen.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..color = AppTheme.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var ring = 1; ring <= 2; ring++) {
      final ringPath = Path();
      for (var i = 0; i < scores.length; i++) {
        final point = pointForIndex(
          index: i,
          count: scores.length,
          center: center,
          radius: radius * (ring / 2),
        );
        if (i == 0) {
          ringPath.moveTo(point.dx, point.dy);
        } else {
          ringPath.lineTo(point.dx, point.dy);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, axisPaint);
    }

    for (var i = 0; i < scores.length; i++) {
      final point = pointForIndex(
        index: i,
        count: scores.length,
        center: center,
        radius: radius,
      );
      canvas.drawLine(center, point, axisPaint);
    }

    final scorePath = Path();
    for (var i = 0; i < scores.length; i++) {
      final point = pointForIndex(
        index: i,
        count: scores.length,
        center: center,
        radius: radius * (scores[i].score / 5),
      );
      if (i == 0) {
        scorePath.moveTo(point.dx, point.dy);
      } else {
        scorePath.lineTo(point.dx, point.dy);
      }
    }
    scorePath.close();
    canvas.drawPath(scorePath, fillPaint);
    canvas.drawPath(scorePath, outlinePaint);

    final pointPaint = Paint()..color = AppTheme.primaryGreen;
    for (var i = 0; i < scores.length; i++) {
      final point = pointForIndex(
        index: i,
        count: scores.length,
        center: center,
        radius: radius * (scores[i].score / 5),
      );
      canvas.drawCircle(point, activeIndex == i ? 4.5 : 3.5, pointPaint);
    }

    final labelStyle = const TextStyle(
      fontSize: 14,
      color: AppTheme.secondarySlate,
    );
    final tickStyle = const TextStyle(
      fontSize: 12,
      color: AppTheme.secondarySlate,
    );

    for (var i = 0; i < scores.length; i++) {
      final point = pointForIndex(
        index: i,
        count: scores.length,
        center: center,
        radius: radius + 18,
      );
      final painter = TextPainter(
        text: TextSpan(text: scores[i].label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(point.dx - painter.width / 2, point.dy - painter.height / 2),
      );
    }

    final zeroPainter = TextPainter(
      text: TextSpan(text: '0', style: tickStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    zeroPainter.paint(canvas, Offset(center.dx - 3, center.dy - 12));

    final twoPainter = TextPainter(
      text: TextSpan(text: '2', style: tickStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    twoPainter.paint(canvas, Offset(center.dx - 3, center.dy - radius / 2 - 10));

    final fivePainter = TextPainter(
      text: TextSpan(text: '5', style: tickStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    fivePainter.paint(canvas, Offset(center.dx - 3, center.dy - radius - 10));
  }

  static int? hitTestIndex({
    required Offset localPosition,
    required Size size,
    required List<_StudentCriterionScore> scores,
  }) {
    if (scores.isEmpty) {
      return null;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.34;
    for (var i = 0; i < scores.length; i++) {
      final point = pointForIndex(
        index: i,
        count: scores.length,
        center: center,
        radius: radius * (scores[i].score / 5),
      );
      if ((localPosition - point).distance <= 28) {
        return i;
      }
    }

    return null;
  }

  static Offset tooltipPositionForIndex({
    required int index,
    required Size size,
    required List<_StudentCriterionScore> scores,
  }) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.34;
    final point = pointForIndex(
      index: index,
      count: scores.length,
      center: center,
      radius: radius * (scores[index].score / 5),
    );

    final left = max(10.0, min(size.width - 104, point.dx + 10));
    final top = max(10.0, min(size.height - 74, point.dy - 18));
    return Offset(left, top);
  }

  static Offset pointForIndex({
    required int index,
    required int count,
    required Offset center,
    required double radius,
  }) {
    final angle = (-90 + (360 / count) * index) * 3.141592653589793 / 180;
    return Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.scores != scores || oldDelegate.activeIndex != activeIndex;
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
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        Container(
          color: AppTheme.primaryGreen,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Manage your account settings',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFDDE9DE),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
          child: Column(
            children: [
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
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
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 16,
                      ),
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
                        Icon(
                          Icons.help_outline,
                          color: AppTheme.primaryGreen,
                        ),
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
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 16,
                      ),
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
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
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
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15),
          ),
        ),
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
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
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

class _StudentAssessment {
  _StudentAssessment({
    required this.title,
    required this.courseCode,
    required this.courseName,
    required this.dueDate,
    required this.groupType,
    required this.criteria,
    required this.teammates,
    this.isSubmitted = false,
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
  const _StudentCriterionScore({
    required this.label,
    required this.score,
  });

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
