/// Models for the ROBLE database tables used in course creation.

/// Data models for parsing CSV exports and sending structured data to
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

class RobleCourseHome {
  RobleCourseHome({
    required this.id,
    required this.name,
    required this.code,
    required this.teacherEmail,
    required this.createdAt,
    this.status = 'Active',
    this.studentCount = 25,
    this.pendingEvaluations = 3,
  });

  final String id;
  final String name;
  final String code;
  final String teacherEmail;
  final DateTime createdAt;
  final String status;
  final int studentCount;
  final int pendingEvaluations;

  factory RobleCourseHome.fromJson(Map<String, dynamic> json) {
    return RobleCourseHome(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'No Name',
      code: json['code'] as String? ?? 'No Code',
      teacherEmail: json['teacher_email']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      studentCount: int.tryParse(json['student_count']?.toString() ?? '') ?? 25,
      pendingEvaluations:
          int.tryParse(json['pending_evaluations']?.toString() ?? '') ?? 3,
    );
  }

  RobleCourseHome copyWith({
    String? id,
    String? name,
    String? code,
    String? teacherEmail,
    DateTime? createdAt,
    String? status,
    int? studentCount,
    int? pendingEvaluations,
  }) {
    return RobleCourseHome(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      teacherEmail: teacherEmail ?? this.teacherEmail,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      studentCount: studentCount ?? this.studentCount,
      pendingEvaluations: pendingEvaluations ?? this.pendingEvaluations,
    );
  }
}

class RobleStudentRecord {
  RobleStudentRecord({
    required this.id,
    required this.username,
    required this.orgDefinedId,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  final String id;
  final String username;
  final String orgDefinedId;
  final String firstName;
  final String lastName;
  final String email;

  factory RobleStudentRecord.fromJson(Map<String, dynamic> json) {
    return RobleStudentRecord(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      username: json['username']?.toString() ?? '',
      orgDefinedId: json['org_defined_id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

class RobleGroupMemberRecord {
  RobleGroupMemberRecord({
    required this.id,
    required this.groupId,
    required this.studentId,
    required this.enrollmentDate,
  });

  final String id;
  final String groupId;
  final String studentId;
  final String enrollmentDate;

  factory RobleGroupMemberRecord.fromJson(Map<String, dynamic> json) {
    return RobleGroupMemberRecord(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      groupId: json['group_id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      enrollmentDate: json['enrollment_date']?.toString() ?? '',
    );
  }
}

class RobleCourseGroupRecord {
  RobleCourseGroupRecord({
    required this.id,
    required this.courseId,
    required this.categoryId,
    required this.groupName,
    required this.groupCode,
  });

  final String id;
  final String courseId;
  final String categoryId;
  final String groupName;
  final String groupCode;

  factory RobleCourseGroupRecord.fromJson(Map<String, dynamic> json) {
    return RobleCourseGroupRecord(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      courseId: json['course_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      groupName: json['group_name']?.toString() ?? '',
      groupCode: json['group_code']?.toString() ?? '',
    );
  }
}

class RobleGroupCategoryRecord {
  RobleGroupCategoryRecord({
    required this.id,
    required this.courseId,
    required this.name,
  });

  final String id;
  final String courseId;
  final String name;

  factory RobleGroupCategoryRecord.fromJson(Map<String, dynamic> json) {
    return RobleGroupCategoryRecord(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      courseId: json['course_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class StudentCourseEnrollment {
  StudentCourseEnrollment({
    required this.course,
    required this.groupName,
    required this.groupCode,
    required this.groupCategoryName,
    required this.enrollmentDate,
  });

  final RobleCourseHome course;
  final String groupName;
  final String groupCode;
  final String groupCategoryName;
  final String enrollmentDate;
}
