// Data models for ROBLE database entities and derived enrollment results.

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

class RobleCourseRosterEntry {
  const RobleCourseRosterEntry({
    required this.studentId,
    required this.username,
    required this.orgDefinedId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.groupId,
    required this.groupName,
    required this.groupCode,
    required this.categoryId,
    required this.categoryName,
    required this.enrollmentDate,
  });

  final String studentId;
  final String username;
  final String orgDefinedId;
  final String firstName;
  final String lastName;
  final String email;
  final String groupId;
  final String groupName;
  final String groupCode;
  final String categoryId;
  final String categoryName;
  final String enrollmentDate;

  String get fullName {
    final fullName = '${firstName.trim()} ${lastName.trim()}'.trim();
    return fullName.isEmpty ? username : fullName;
  }
}

class RobleCourseManagementData {
  const RobleCourseManagementData({
    required this.course,
    required this.categories,
    required this.roster,
  });

  final RobleCourseHome course;
  final List<RobleGroupCategoryRecord> categories;
  final List<RobleCourseRosterEntry> roster;

  int get groupCount => roster.map((entry) => entry.groupId).toSet().length;

  int get studentCount => roster.map((entry) => entry.studentId).toSet().length;
}

class RobleAssessment {
  RobleAssessment({
    this.id,
    required this.courseId,
    required this.categoryId,
    required this.name,
    required this.visibility,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    required this.createdByEmail,
    required this.createdAt,
  });

  final String? id;
  final String courseId;
  final String categoryId;
  final String name;
  final String visibility;
  final String status;
  final DateTime startsAt;
  final DateTime endsAt;
  final String createdByEmail;
  final DateTime createdAt;

  factory RobleAssessment.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return RobleAssessment(
      id: json['_id'] as String? ?? json['id'] as String?,
      courseId: json['course_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Untitled assessment',
      visibility: json['visibility']?.toString() ?? 'private',
      status: json['status']?.toString() ?? 'draft',
      startsAt: json['starts_at'] != null
          ? DateTime.tryParse(json['starts_at'].toString()) ?? now
          : now,
      endsAt: json['ends_at'] != null
          ? DateTime.tryParse(json['ends_at'].toString()) ??
                now.add(const Duration(days: 7))
          : now.add(const Duration(days: 7)),
      createdByEmail: json['created_by_email']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? now
          : now,
    );
  }

  Map<String, dynamic> toJson() => {
    'course_id': courseId,
    'category_id': categoryId,
    'name': name,
    'visibility': visibility,
    'status': status,
    'starts_at': startsAt.toIso8601String(),
    'ends_at': endsAt.toIso8601String(),
    'created_by_email': createdByEmail,
    'created_at': createdAt.toIso8601String(),
  };
}

class RobleAssessmentCriterion {
  RobleAssessmentCriterion({
    this.id,
    required this.assessmentId,
    required this.name,
    required this.description,
    required this.weight,
    required this.displayOrder,
    required this.createdAt,
  });

  final String? id;
  final String assessmentId;
  final String name;
  final String description;
  final int weight;
  final int displayOrder;
  final DateTime createdAt;

  factory RobleAssessmentCriterion.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return RobleAssessmentCriterion(
      id: json['_id'] as String? ?? json['id'] as String?,
      assessmentId: json['assessment_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Criterion',
      description: json['description']?.toString() ?? '',
      weight: int.tryParse(json['weight']?.toString() ?? '') ?? 0,
      displayOrder: int.tryParse(json['display_order']?.toString() ?? '') ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? now
          : now,
    );
  }

  Map<String, dynamic> toJson() => {
    'assessment_id': assessmentId,
    'name': name,
    'description': description,
    'weight': weight,
    'display_order': displayOrder,
    'created_at': createdAt.toIso8601String(),
  };
}

class RobleAssessmentCriterionLevel {
  RobleAssessmentCriterionLevel({
    this.id,
    required this.criterionId,
    required this.scoreValue,
    required this.label,
    required this.descriptionEn,
    required this.descriptionEs,
    required this.displayOrder,
  });

  final String? id;
  final String criterionId;
  final int scoreValue;
  final String label;
  final String descriptionEn;
  final String descriptionEs;
  final int displayOrder;

  factory RobleAssessmentCriterionLevel.fromJson(Map<String, dynamic> json) {
    return RobleAssessmentCriterionLevel(
      id: json['_id'] as String? ?? json['id'] as String?,
      criterionId: json['criterion_id']?.toString() ?? '',
      scoreValue: int.tryParse(json['score_value']?.toString() ?? '') ?? 0,
      label: json['label']?.toString() ?? '',
      descriptionEn: json['description_en']?.toString() ?? '',
      descriptionEs: json['description_es']?.toString() ?? '',
      displayOrder: int.tryParse(json['display_order']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'criterion_id': criterionId,
    'score_value': scoreValue,
    'label': label,
    'description_en': descriptionEn,
    'description_es': descriptionEs,
    'display_order': displayOrder,
  };
}

class RobleAssessmentCriterionDetail {
  const RobleAssessmentCriterionDetail({
    required this.criterion,
    required this.levels,
  });

  final RobleAssessmentCriterion criterion;
  final List<RobleAssessmentCriterionLevel> levels;
}

class RobleAssessmentOverview {
  const RobleAssessmentOverview({
    required this.assessment,
    required this.course,
    required this.categoryName,
    required this.responsesSubmitted,
    required this.totalReviewers,
  });

  final RobleAssessment assessment;
  final RobleCourseHome course;
  final String categoryName;
  final int responsesSubmitted;
  final int totalReviewers;

  String get visibilityLabel =>
      assessment.visibility.toLowerCase() == 'public' ? 'Public' : 'Private';

  String get statusLabel {
    final normalized = assessment.status.toLowerCase();
    final now = DateTime.now();
    if (normalized == 'closed' || now.isAfter(assessment.endsAt)) {
      return 'Closed';
    }
    if (normalized == 'draft') {
      return 'Draft';
    }
    if (now.isBefore(assessment.startsAt)) {
      return 'Scheduled';
    }
    return 'Active';
  }

  double get completionProgress {
    if (totalReviewers <= 0) {
      return 0;
    }
    return responsesSubmitted / totalReviewers;
  }
}

class RobleAssessmentDetailData {
  const RobleAssessmentDetailData({
    required this.overview,
    required this.category,
    required this.criteria,
  });

  final RobleAssessmentOverview overview;
  final RobleGroupCategoryRecord? category;
  final List<RobleAssessmentCriterionDetail> criteria;
}
