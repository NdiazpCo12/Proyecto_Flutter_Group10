part of 'teacher_home_view.dart';

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
