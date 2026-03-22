part of 'student_home_view.dart';

class _StudentAssessmentsView extends StatefulWidget {
  const _StudentAssessmentsView({required this.assessments});

  final List<_StudentAssessment> assessments;

  @override
  State<_StudentAssessmentsView> createState() =>
      _StudentAssessmentsViewState();
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
            style: const TextStyle(color: AppTheme.textMuted, height: 1.5),
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
                    style: TextStyle(fontSize: 16, color: Color(0xFFDDE9DE)),
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
  const _StudentAssessmentCard({required this.assessment, required this.onTap});

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            assessment.courseCode,
            style: const TextStyle(fontSize: 15, color: AppTheme.textMuted),
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
                    label: const Text('Back', style: TextStyle(fontSize: 16)),
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
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E5E8))),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Progress: ${teammateIndex + 1} of $totalTeammates',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Text(
                          '${teammateIndex + 1} completed',
                          style: const TextStyle(color: AppTheme.textMuted),
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
                            ...List.generate(assessment.criteria.length, (
                              index,
                            ) {
                              final criterion = assessment.criteria[index];
                              final rating =
                                  teammate.ratings[criterion.id] ?? 0;
                              return _CriterionRatingRow(
                                criterion: criterion,
                                rating: rating,
                                isLast: index == assessment.criteria.length - 1,
                                onChanged: (value) =>
                                    onRateCriterion(criterion, value),
                              );
                            }),
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
                    border: Border(top: BorderSide(color: Color(0xFFE2E5E8))),
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.info_outline, size: 18, color: AppTheme.textMuted),
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
          children: List.generate(5, (index) {
            final starValue = index + 1;
            final isFilled = starValue <= rating;
            return IconButton(
              onPressed: () => onChanged(starValue),
              visualDensity: VisualDensity.compact,
              splashRadius: 22,
              iconSize: 36,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              icon: Icon(
                isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                color: isFilled
                    ? const Color(0xFFFFC107)
                    : const Color(0xFFCBD2DB),
              ),
            );
          }),
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
          style: const TextStyle(fontSize: 15, color: AppTheme.secondarySlate),
        ),
      ],
    );
  }
}
