part of 'teacher_home_view.dart';

class _TeacherReports extends StatelessWidget {
  const _TeacherReports({required this.controller});

  final TeacherHomeController controller;

  @override
  Widget build(BuildContext context) {
    const activityBars = [
      _ChartBar(label: 'Sprint 1', value: 4.2, color: AppTheme.primaryGreen),
      _ChartBar(
        label: 'Sprint 2',
        value: 4.5,
        color: AppTheme.primaryGreen,
        highlighted: true,
      ),
      _ChartBar(label: 'Sprint 3', value: 4.3, color: AppTheme.primaryGreen),
      _ChartBar(label: 'Midterm', value: 4.1, color: AppTheme.primaryGreen),
    ];
    const teamBars = [
      _ChartBar(label: 'Team A', value: 4.6, color: AppTheme.secondarySlate),
      _ChartBar(label: 'Team B', value: 4.4, color: AppTheme.secondarySlate),
      _ChartBar(
        label: 'Team C',
        value: 4.7,
        color: AppTheme.secondarySlate,
        highlighted: true,
      ),
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

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        Container(
          color: AppTheme.primaryGreen,
          child: SafeArea(
            bottom: false,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(22, 24, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analytics Hub',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'View assessment insights and trends',
                    style: TextStyle(fontSize: 16, color: Color(0xFFDDE9DE)),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
          child: Column(
            children: [
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
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
                          DropdownMenuItem(
                            value: 'Team A',
                            child: Text('Team A'),
                          ),
                          DropdownMenuItem(
                            value: 'Team B',
                            child: Text('Team B'),
                          ),
                          DropdownMenuItem(
                            value: 'Team C',
                            child: Text('Team C'),
                          ),
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
                            expanded:
                                _TeacherUiState.expandedStudent.value ==
                                student.name,
                            onToggle: () {
                              _TeacherUiState.expandedStudent.value =
                                  _TeacherUiState.expandedStudent.value ==
                                      student.name
                                  ? ''
                                  : student.name;
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
