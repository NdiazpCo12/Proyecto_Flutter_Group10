part of 'teacher_home_view.dart';

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
                  style: TextStyle(fontSize: 16, color: Color(0xFFDDE9DE)),
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
                        options: const [
                          'Project Teams',
                          'Lab Groups',
                          'Squads',
                        ],
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
