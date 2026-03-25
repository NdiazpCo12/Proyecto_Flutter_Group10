/// Models for the ROBLE database tables used in course creation.
/// Each model has a [toJson] method that produces the payload for
/// the ROBLE POST /:dbName/insert endpoint.

class RobleCourse {
  RobleCourse({
    this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.teacherEmail,
  });

  String? id;
  final String name;
  final String code;
  final String description;
  final String teacherEmail;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'code': code,
      'description': description,
      'teacher_email': teacherEmail,
    };
    if (id != null) map['_id'] = id;
    return map;
  }
}

class RobleGroupCategory {
  RobleGroupCategory({this.id, required this.name, required this.courseId});

  String? id;
  final String name;
  final String courseId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'name': name, 'course_id': courseId};
    if (id != null) map['_id'] = id;
    return map;
  }
}

class RobleCourseGroup {
  RobleCourseGroup({
    this.id,
    required this.name,
    required this.code,
    required this.categoryId,
    required this.courseId,
  });

  String? id;
  final String name;
  final String code;
  final String categoryId;
  final String courseId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'group_name': name,
      'group_code': code,
      'category_id': categoryId,
      'course_id': courseId,
    };
    if (id != null) map['_id'] = id;
    return map;
  }
}

class RobleStudent {
  RobleStudent({
    this.id,
    required this.username,
    required this.orgId,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  String? id;
  final String username;
  final String orgId;
  final String firstName;
  final String lastName;
  final String email;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'username': username,
      'org_defined_id': orgId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
    };
    if (id != null) map['_id'] = id;
    return map;
  }
}

class RobleGroupMember {
  RobleGroupMember({
    required this.studentId,
    required this.groupId,
    required this.enrollmentDate,
  });

  final String studentId;
  final String groupId;
  final String enrollmentDate;

  Map<String, dynamic> toJson() => {
    'student_id': studentId,
    'group_id': groupId,
    'enrollment_date': enrollmentDate,
  };
}

/// Represents one parsed row from the Brightspace CSV export.
/// CSV columns (0-indexed):
/// 0: Group Category Name
/// 1: Group Name
/// 2: Group Code
/// 3: Username
/// 4: OrgDefinedId
/// 5: First Name
/// 6: Last Name
/// 7: Email Address
/// 8: Group Enrollment Date
class CsvRow {
  CsvRow({
    required this.groupCategoryName,
    required this.groupName,
    required this.groupCode,
    required this.username,
    required this.orgDefinedId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.enrollmentDate,
  });

  factory CsvRow.fromList(List<dynamic> cols) {
    String cell(int i) => i < cols.length ? cols[i].toString().trim() : '';
    return CsvRow(
      groupCategoryName: cell(0),
      groupName: cell(1),
      groupCode: cell(2),
      username: cell(3),
      orgDefinedId: cell(4),
      firstName: cell(5),
      lastName: cell(6),
      email: cell(7),
      enrollmentDate: cell(8),
    );
  }

  final String groupCategoryName;
  final String groupName;
  final String groupCode;
  final String username;
  final String orgDefinedId;
  final String firstName;
  final String lastName;
  final String email;
  final String enrollmentDate;
}
