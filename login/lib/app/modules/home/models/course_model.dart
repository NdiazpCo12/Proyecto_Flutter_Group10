class CourseModel {
  final String name;
  final String code;
  final int studentCount;
  final int activeAssessments;

  const CourseModel({
    required this.name,
    required this.code,
    required this.studentCount,
    required this.activeAssessments,
  });

  // Mock courses data
  static const List<CourseModel> mockCourses = [
    CourseModel(
      name: 'Software Engineering',
      code: 'CS 401',
      studentCount: 45,
      activeAssessments: 2,
    ),
    CourseModel(
      name: 'Data Structures',
      code: 'CS 302',
      studentCount: 38,
      activeAssessments: 1,
    ),
    CourseModel(
      name: 'Web Development',
      code: 'CS 350',
      studentCount: 52,
      activeAssessments: 3,
    ),
    CourseModel(
      name: 'Database Systems',
      code: 'CS 405',
      studentCount: 41,
      activeAssessments: 1,
    ),
  ];
}
