part of 'teacher_home_view.dart';

class _TeacherEvaluations extends StatelessWidget {
  const _TeacherEvaluations({required this.controller});

  final TeacherHomeController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        Container(
          width: double.infinity,
          color: AppTheme.primaryGreen,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
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
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
          child: Column(
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
                color: isActive
                    ? AppTheme.primaryGreen
                    : const Color(0xFF73C79B),
              ),
              const Spacer(),
              Icon(
                isActive
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right, color: AppTheme.textMuted),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            evaluation.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            evaluation.courseId == 'mobile'
                ? 'CS 401'
                : evaluation.courseId == 'ux'
                ? 'CS 302'
                : 'CS 201',
            style: const TextStyle(fontSize: 16, color: AppTheme.textMuted),
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
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 15),
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
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Completion',
                  style: TextStyle(fontSize: 15, color: AppTheme.textMuted),
                ),
              ),
              Text(
                '${evaluation.responses}/$total',
                style: const TextStyle(fontWeight: FontWeight.w700),
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
