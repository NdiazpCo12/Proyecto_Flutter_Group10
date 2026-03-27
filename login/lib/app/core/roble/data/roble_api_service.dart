import 'package:dio/dio.dart';

import '../../storage/session_storage_service.dart';
import '../models/roble_models.dart';
import '../roble_config.dart';

/// Handles all HTTP requests to the ROBLE database API.
/// Uses the access token persisted by [SessionStorageService] after login.
class RobleApiService {
  RobleApiService({SessionStorageService? storage})
    : _storage = storage ?? SessionStorageService();

  final SessionStorageService _storage;

  Dio? _dio;

  Future<Dio> _client() async {
    final token = await _storage.getAccessToken();
    _dio ??= Dio(
      BaseOptions(
        baseUrl: RobleConfig.dbBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      ),
    );
    _dio!.options.headers['Authorization'] = 'Bearer ${token ?? ''}';
    return _dio!;
  }

  Map<String, dynamic> _sanitizePayload(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};
    for (final entry in data.entries) {
      if (entry.value == null) {
        sanitized[entry.key] = '';
      } else if (entry.value is String &&
          (entry.value as String).trim().isEmpty) {
        sanitized[entry.key] = '';
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    return sanitized;
  }

  Future<List<Map<String, dynamic>>> read(
    String table, {
    Map<String, dynamic> filters = const {},
  }) async {
    final client = await _client();
    final queryParameters = <String, dynamic>{'tableName': table};

    for (final entry in filters.entries) {
      if (entry.value == null) continue;
      final value = entry.value.toString().trim();
      if (value.isEmpty) continue;
      queryParameters[entry.key] = value;
    }

    try {
      final response = await client.get(
        '/read',
        queryParameters: queryParameters,
      );
      final body = response.data;

      if (body is List) {
        return body
            .whereType<Map>()
            .map((row) => Map<String, dynamic>.from(row))
            .toList();
      }

      throw Exception('No fue posible leer la informacion solicitada.');
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? e.toString();
      throw Exception('No se pudo cargar la informacion: $msg');
    }
  }

  /// Inserts [data] into [table] and returns the auto-generated `_id`.
  Future<String> insert(String table, Map<String, dynamic> data) async {
    final client = await _client();
    final sanitizedData = _sanitizePayload(data);
    final payload = {
      'tableName': table,
      'records': [sanitizedData],
    };

    try {
      final response = await client.post('/insert', data: payload);
      final body = response.data;

      if (body is Map<String, dynamic>) {
        final skipped = body['skipped'];
        if (skipped is List && skipped.isNotEmpty) {
          final firstSkip = skipped.first as Map<String, dynamic>;
          final reason = firstSkip['reason'] ?? 'Motivo desconocido';
          throw Exception('Registro omitido (skipped). Motivo: $reason');
        }

        final inserted = body['inserted'];
        if (inserted is List && inserted.isNotEmpty) {
          final firstRecord = inserted.first as Map<String, dynamic>;
          final id = firstRecord['_id'] ?? firstRecord['id'];

          if (id != null) {
            print('ID capturado con exito: $id');
            return id.toString();
          }
        }
      }

      throw Exception('No fue posible guardar la informacion.');
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? e.toString();
      throw Exception('No se pudo guardar la informacion: $msg');
    } catch (e) {
      throw Exception('Ocurrio un problema al procesar la solicitud: $e');
    }
  }

  /// Deletes a record from [table] using [idColumn] and [idValue].
  Future<void> delete(
    String table, {
    required String idColumn,
    required String idValue,
  }) async {
    final trimmedId = idValue.trim();
    if (trimmedId.isEmpty) {
      return;
    }

    final client = await _client();
    final payload = {
      'tableName': table,
      'idColumn': idColumn,
      'idValue': trimmedId,
    };

    try {
      await client.delete('/delete', data: payload);
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? e.toString();
      throw Exception('No se pudo eliminar la informacion: $msg');
    }
  }

  Future<void> deleteById(String table, String idValue) {
    return delete(table, idColumn: '_id', idValue: idValue);
  }

  /// Fetches courses for the given teacher email from ROBLE `courses` table.
  Future<List<RobleCourseHome>> getCourses(String teacherEmail) async {
    final client = await _client();
    final token = await _storage.getAccessToken();
    try {
      print('=== Solicitando cursos ===');
      print('URL: ${client.options.baseUrl}/read?tableName=courses');
      print('Token enviado: $token');

      final response = await client.get(
        '/read',
        queryParameters: {'tableName': 'courses'},
        options: Options(
          headers: {
            'Authorization': 'Bearer ${token ?? ''}',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Respuesta RAW de ROBLE: ${response.data}');
      final body = response.data;

      print('Filtrando cursos para el email: $teacherEmail');

      if (body is List) {
        final mapped = body
            .map((e) {
              final json = e as Map<String, dynamic>;
              print('Mapeando curso JSON: $json');
              return RobleCourseHome.fromJson(json);
            })
            .where(
              (c) =>
                  teacherEmail.isEmpty ||
                  c.teacherEmail.toLowerCase() == teacherEmail.toLowerCase(),
            )
            .toList();

        final enriched = <RobleCourseHome>[];
        for (final course in mapped) {
          final stats = await _getCourseStats(course.id);
          enriched.add(course.copyWith(studentCount: stats.studentCount));
        }

        print('Cursos obtenidos despues de filtro: ${enriched.length}');
        enriched.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return enriched;
      }

      print('El body no tenia el formato esperado de List.');
      return [];
    } catch (e) {
      if (e is DioException) {
        print('Error response status: ${e.response?.statusCode}');
        print('Error response data: ${e.response?.data}');
      }
      print('Error en getCourses: $e');
      throw Exception('No se pudieron cargar los cursos.');
    }
  }

  Future<List<StudentCourseEnrollment>> getStudentEnrollments(
    String studentEmail,
  ) async {
    final trimmedEmail = studentEmail.trim().toLowerCase();
    if (trimmedEmail.isEmpty) {
      return [];
    }

    final studentRows = await read(
      'students',
      filters: {'email': trimmedEmail},
    );
    if (studentRows.isEmpty) {
      return [];
    }

    final students = studentRows.map(RobleStudentRecord.fromJson).toList();
    final memberships = <RobleGroupMemberRecord>[];

    for (final student in students) {
      final membershipRows = await read(
        'group_members',
        filters: {'student_id': student.id},
      );
      memberships.addAll(membershipRows.map(RobleGroupMemberRecord.fromJson));
    }

    if (memberships.isEmpty) {
      return [];
    }

    final groupCache = <String, RobleCourseGroupRecord>{};
    final categoryCache = <String, RobleGroupCategoryRecord>{};
    final courseCache = <String, RobleCourseHome>{};
    final enrollments = <StudentCourseEnrollment>[];
    final seenEnrollmentKeys = <String>{};

    for (final membership in memberships) {
      final group = await _getCourseGroupById(membership.groupId, groupCache);
      if (group == null) continue;

      final course = await _getCourseById(group.courseId, courseCache);
      if (course == null) continue;

      final enrollmentKey = '${course.id}:${group.id}:${membership.studentId}';
      if (!seenEnrollmentKeys.add(enrollmentKey)) {
        continue;
      }

      final category = await _getGroupCategoryById(
        group.categoryId,
        categoryCache,
      );

      enrollments.add(
        StudentCourseEnrollment(
          course: course,
          groupName: group.groupName,
          groupCode: group.groupCode,
          groupCategoryName: category?.name ?? 'Sin categoria',
          enrollmentDate: membership.enrollmentDate,
        ),
      );
    }

    enrollments.sort(
      (a, b) => b.course.createdAt.compareTo(a.course.createdAt),
    );
    return enrollments;
  }

  Future<List<RobleStudentAssessmentAssignment>> getStudentAssessments(
    String studentEmail,
  ) async {
    final trimmedEmail = studentEmail.trim().toLowerCase();
    if (trimmedEmail.isEmpty) {
      return [];
    }

    final studentRows = await read(
      'students',
      filters: {'email': trimmedEmail},
    );
    if (studentRows.isEmpty) {
      return [];
    }

    final students = studentRows.map(RobleStudentRecord.fromJson).toList();
    final assignments = <RobleStudentAssessmentAssignment>[];
    final seenAssignmentKeys = <String>{};
    final groupCache = <String, RobleCourseGroupRecord>{};
    final categoryCache = <String, RobleGroupCategoryRecord>{};
    final courseCache = <String, RobleCourseHome>{};
    final studentCache = <String, RobleStudentRecord?>{
      for (final student in students) student.id: student,
    };
    final criteriaCache = <String, List<RobleAssessmentCriterionDetail>>{};

    for (final student in students) {
      final membershipRows = await read(
        'group_members',
        filters: {'student_id': student.id},
      );
      final memberships = membershipRows
          .map(RobleGroupMemberRecord.fromJson)
          .where((membership) => membership.id.isNotEmpty)
          .toList();

      for (final membership in memberships) {
        final group = await _getCourseGroupById(membership.groupId, groupCache);
        if (group == null) {
          continue;
        }

        final course = await _getCourseById(group.courseId, courseCache);
        if (course == null) {
          continue;
        }

        final category = await _getGroupCategoryById(
          group.categoryId,
          categoryCache,
        );
        final assessmentRows = await read(
          'assessments',
          filters: {'category_id': group.categoryId},
        );

        for (final row in assessmentRows) {
          final assessment = RobleAssessment.fromJson(row);
          if (assessment.courseId.isNotEmpty &&
              assessment.courseId != course.id) {
            continue;
          }

          final assignmentKey = '${assessment.id}:${student.id}:${group.id}';
          if (!seenAssignmentKeys.add(assignmentKey)) {
            continue;
          }

          final criteria = await _getAssessmentCriteriaDetails(
            assessment.id ?? '',
            criteriaCache,
          );
          final teammates = await _getGroupTeammates(
            groupId: group.id,
            reviewerStudentId: student.id,
            studentCache: studentCache,
          );
          final submission = await _getStudentSubmission(
            assessmentId: assessment.id ?? '',
            reviewerStudentId: student.id,
          );
          final savedScores = submission == null
              ? const <String, Map<String, int>>{}
              : await _getSavedScoresByReviewee(submission.id ?? '');

          assignments.add(
            RobleStudentAssessmentAssignment(
              assessment: assessment,
              course: course,
              category: category,
              group: group,
              reviewer: student,
              teammates: teammates,
              criteria: criteria,
              isSubmitted: submission?.isSubmitted ?? false,
              submissionId: submission?.id,
              submissionStatus: submission?.status,
              submittedAt: submission?.submittedAt,
              savedScoresByReviewee: savedScores,
            ),
          );
        }
      }
    }

    assignments.sort((a, b) {
      final aRank = _studentAssessmentSortRank(a);
      final bRank = _studentAssessmentSortRank(b);
      if (aRank != bRank) {
        return aRank.compareTo(bRank);
      }
      return a.assessment.endsAt.compareTo(b.assessment.endsAt);
    });
    return assignments;
  }

  Future<void> submitStudentAssessment({
    required RobleStudentAssessmentAssignment assignment,
    required Map<String, Map<String, int>> scoresByReviewee,
  }) async {
    final assessmentId = assignment.assessment.id?.trim() ?? '';
    final reviewerStudentId = assignment.reviewer.id.trim();
    final groupId = assignment.group.id.trim();
    final courseId = assignment.course.id.trim();
    final categoryId = assignment.assessment.categoryId.trim();

    if (assessmentId.isEmpty ||
        reviewerStudentId.isEmpty ||
        groupId.isEmpty ||
        courseId.isEmpty ||
        categoryId.isEmpty) {
      throw Exception('No fue posible identificar esta evaluacion.');
    }

    if (scoresByReviewee.isEmpty) {
      throw Exception('Debes calificar a tus companeros antes de enviar.');
    }

    final existingSubmission = await _getStudentSubmission(
      assessmentId: assessmentId,
      reviewerStudentId: reviewerStudentId,
    );
    if (existingSubmission != null && existingSubmission.isSubmitted) {
      throw Exception('Esta evaluacion ya fue enviada.');
    }
    if (existingSubmission != null &&
        (existingSubmission.id ?? '').isNotEmpty) {
      await _deleteSubmissionCascade(existingSubmission.id!);
    }

    final now = DateTime.now();
    String? createdSubmissionId;
    try {
      final submission = RobleAssessmentSubmission(
        assessmentId: assessmentId,
        courseId: courseId,
        categoryId: categoryId,
        groupId: groupId,
        reviewerStudentId: reviewerStudentId,
        status: 'submitted',
        generalComment: '',
        startedAt: now,
        submittedAt: now,
        createdAt: now,
      );
      createdSubmissionId = await insert(
        'assessment_submissions',
        submission.toJson(),
      );

      for (final teammateEntry in scoresByReviewee.entries) {
        final revieweeStudentId = teammateEntry.key.trim();
        final criterionScores = teammateEntry.value;
        if (revieweeStudentId.isEmpty ||
            revieweeStudentId == reviewerStudentId ||
            criterionScores.isEmpty) {
          continue;
        }

        final peerReview = RobleAssessmentPeerReview(
          submissionId: createdSubmissionId,
          assessmentId: assessmentId,
          courseId: courseId,
          categoryId: categoryId,
          groupId: groupId,
          reviewerStudentId: reviewerStudentId,
          revieweeStudentId: revieweeStudentId,
          generalComment: '',
          createdAt: now,
        );
        final peerReviewId = await insert(
          'assessment_peer_reviews',
          peerReview.toJson(),
        );

        for (final scoreEntry in criterionScores.entries) {
          final criterionId = scoreEntry.key.trim();
          final scoreValue = scoreEntry.value;
          if (criterionId.isEmpty) {
            continue;
          }

          final score = RobleAssessmentScore(
            peerReviewId: peerReviewId,
            assessmentId: assessmentId,
            courseId: courseId,
            categoryId: categoryId,
            groupId: groupId,
            reviewerStudentId: reviewerStudentId,
            revieweeStudentId: revieweeStudentId,
            criterionId: criterionId,
            scoreValue: scoreValue,
            createdAt: now,
            updatedAt: now,
          );
          await insert('assessment_scores', score.toJson());
        }
      }
    } catch (error) {
      if (createdSubmissionId != null) {
        try {
          await _deleteSubmissionCascade(createdSubmissionId);
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<List<RobleGroupCategoryRecord>> getCourseCategories(
    String courseId,
  ) async {
    if (courseId.trim().isEmpty) {
      return [];
    }

    final rows = await read(
      'group_categories',
      filters: {'course_id': courseId},
    );
    final categories =
        rows
            .map(RobleGroupCategoryRecord.fromJson)
            .where((category) => category.id.isNotEmpty)
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    return categories;
  }

  Future<List<RobleAssessmentOverview>> getTeacherAssessments(
    String teacherEmail,
  ) async {
    final courses = await getCourses(teacherEmail);
    final assessments = <RobleAssessmentOverview>[];

    for (final course in courses) {
      final categories = await getCourseCategories(course.id);
      final categoriesById = {
        for (final category in categories) category.id: category,
      };

      final rows = await read('assessments', filters: {'course_id': course.id});

      for (final row in rows) {
        final assessment = RobleAssessment.fromJson(row);
        final responsesSubmitted = await _getSubmittedResponses(assessment.id);
        final totalReviewers = await _getCategoryStudentCount(
          assessment.categoryId,
        );

        assessments.add(
          RobleAssessmentOverview(
            assessment: assessment,
            course: course,
            categoryName:
                categoriesById[assessment.categoryId]?.name ?? 'Sin categoria',
            responsesSubmitted: responsesSubmitted,
            totalReviewers: totalReviewers,
          ),
        );
      }
    }

    assessments.sort(
      (a, b) => b.assessment.startsAt.compareTo(a.assessment.startsAt),
    );
    return assessments;
  }

  Future<RobleAssessmentDetailData?> getAssessmentDetail(
    String assessmentId,
  ) async {
    final trimmedId = assessmentId.trim();
    if (trimmedId.isEmpty) {
      return null;
    }

    final rows = await read('assessments', filters: {'_id': trimmedId});
    if (rows.isEmpty) {
      return null;
    }

    final assessment = RobleAssessment.fromJson(rows.first);
    final course = await _getCourseById(
      assessment.courseId,
      <String, RobleCourseHome>{},
    );
    if (course == null) {
      return null;
    }

    final category = await _getGroupCategoryById(
      assessment.categoryId,
      <String, RobleGroupCategoryRecord>{},
    );
    final responsesSubmitted = await _getSubmittedResponses(assessment.id);
    final totalReviewers = await _getCategoryStudentCount(
      assessment.categoryId,
    );

    final criteriaRows = await read(
      'assessment_criteria',
      filters: {'assessment_id': trimmedId},
    );
    final criteria =
        criteriaRows
            .map(RobleAssessmentCriterion.fromJson)
            .where((criterion) => (criterion.id ?? '').isNotEmpty)
            .toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    final criterionDetails = <RobleAssessmentCriterionDetail>[];
    for (final criterion in criteria) {
      final levelRows = await read(
        'assessment_criterion_levels',
        filters: {'criterion_id': criterion.id},
      );
      final levels =
          levelRows.map(RobleAssessmentCriterionLevel.fromJson).toList()
            ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

      criterionDetails.add(
        RobleAssessmentCriterionDetail(criterion: criterion, levels: levels),
      );
    }

    return RobleAssessmentDetailData(
      overview: RobleAssessmentOverview(
        assessment: assessment,
        course: course,
        categoryName: category?.name ?? 'Sin categoria',
        responsesSubmitted: responsesSubmitted,
        totalReviewers: totalReviewers,
      ),
      category: category,
      criteria: criterionDetails,
    );
  }

  Future<RobleCourseManagementData> getCourseManagementData(
    RobleCourseHome course,
  ) async {
    final categoryRows = await read(
      'group_categories',
      filters: {'course_id': course.id},
    );
    final categories =
        categoryRows
            .map(RobleGroupCategoryRecord.fromJson)
            .where((category) => category.id.isNotEmpty)
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    final groupsRows = await read(
      'course_groups',
      filters: {'course_id': course.id},
    );
    final groups =
        groupsRows
            .map(RobleCourseGroupRecord.fromJson)
            .where((group) => group.id.isNotEmpty)
            .toList()
          ..sort((a, b) => a.groupName.compareTo(b.groupName));

    final categoryById = {
      for (final category in categories) category.id: category,
    };
    final studentCache = <String, RobleStudentRecord?>{};
    final roster = <RobleCourseRosterEntry>[];

    for (final group in groups) {
      final membershipRows = await read(
        'group_members',
        filters: {'group_id': group.id},
      );
      final memberships = membershipRows
          .map(RobleGroupMemberRecord.fromJson)
          .where((membership) => membership.id.isNotEmpty)
          .toList();

      for (final membership in memberships) {
        final student = await _getStudentRecordById(
          membership.studentId,
          studentCache,
        );
        if (student == null) {
          continue;
        }

        final category = categoryById[group.categoryId];
        roster.add(
          RobleCourseRosterEntry(
            studentId: student.id,
            username: student.username,
            orgDefinedId: student.orgDefinedId,
            firstName: student.firstName,
            lastName: student.lastName,
            email: student.email,
            groupId: group.id,
            groupName: group.groupName,
            groupCode: group.groupCode,
            categoryId: group.categoryId,
            categoryName: category?.name ?? 'Sin categoria',
            enrollmentDate: membership.enrollmentDate,
          ),
        );
      }
    }

    roster.sort((a, b) {
      final categoryCompare = a.categoryName.compareTo(b.categoryName);
      if (categoryCompare != 0) {
        return categoryCompare;
      }

      final groupCompare = a.groupName.compareTo(b.groupName);
      if (groupCompare != 0) {
        return groupCompare;
      }

      return a.fullName.compareTo(b.fullName);
    });

    return RobleCourseManagementData(
      course: course.copyWith(
        studentCount: roster.map((entry) => entry.studentId).toSet().length,
      ),
      categories: categories,
      roster: roster,
    );
  }

  Future<void> deleteCourseCascade(String courseId) async {
    if (courseId.trim().isEmpty) {
      return;
    }

    final categoryRows = await read(
      'group_categories',
      filters: {'course_id': courseId},
    );
    final categories = categoryRows
        .map(RobleGroupCategoryRecord.fromJson)
        .where((category) => category.id.isNotEmpty)
        .toList();

    final groupRows = await read(
      'course_groups',
      filters: {'course_id': courseId},
    );
    final groups = groupRows
        .map(RobleCourseGroupRecord.fromJson)
        .where((group) => group.id.isNotEmpty)
        .toList();

    final membershipIds = <String>{};
    final affectedStudentIds = <String>{};

    for (final group in groups) {
      final membershipRows = await read(
        'group_members',
        filters: {'group_id': group.id},
      );
      final memberships = membershipRows
          .map(RobleGroupMemberRecord.fromJson)
          .where((membership) => membership.id.isNotEmpty)
          .toList();

      for (final membership in memberships) {
        membershipIds.add(membership.id);
        if (membership.studentId.isNotEmpty) {
          affectedStudentIds.add(membership.studentId);
        }
      }
    }

    for (final membershipId in membershipIds) {
      await deleteById('group_members', membershipId);
    }

    for (final group in groups) {
      await deleteById('course_groups', group.id);
    }

    for (final category in categories) {
      await deleteById('group_categories', category.id);
    }

    await _deleteStudentsIfOrphaned(affectedStudentIds);
    await deleteById('courses', courseId);
  }

  Future<RobleCourseGroupRecord?> _getCourseGroupById(
    String groupId,
    Map<String, RobleCourseGroupRecord> cache,
  ) async {
    if (groupId.isEmpty) return null;
    if (cache.containsKey(groupId)) {
      return cache[groupId];
    }

    final rows = await read('course_groups', filters: {'_id': groupId});
    if (rows.isEmpty) return null;

    final group = RobleCourseGroupRecord.fromJson(rows.first);
    cache[groupId] = group;
    return group;
  }

  Future<RobleGroupCategoryRecord?> _getGroupCategoryById(
    String categoryId,
    Map<String, RobleGroupCategoryRecord> cache,
  ) async {
    if (categoryId.isEmpty) return null;
    if (cache.containsKey(categoryId)) {
      return cache[categoryId];
    }

    final rows = await read('group_categories', filters: {'_id': categoryId});
    if (rows.isEmpty) return null;

    final category = RobleGroupCategoryRecord.fromJson(rows.first);
    cache[categoryId] = category;
    return category;
  }

  Future<RobleCourseHome?> _getCourseById(
    String courseId,
    Map<String, RobleCourseHome> cache,
  ) async {
    if (courseId.isEmpty) return null;
    if (cache.containsKey(courseId)) {
      return cache[courseId];
    }

    final rows = await read('courses', filters: {'_id': courseId});
    if (rows.isEmpty) return null;

    final course = RobleCourseHome.fromJson(rows.first);
    cache[courseId] = course;
    return course;
  }

  Future<RobleStudentRecord?> _getStudentRecordById(
    String studentId,
    Map<String, RobleStudentRecord?> cache,
  ) async {
    if (studentId.isEmpty) {
      return null;
    }
    if (cache.containsKey(studentId)) {
      return cache[studentId];
    }

    final rows = await read('students', filters: {'_id': studentId});
    if (rows.isEmpty) {
      cache[studentId] = null;
      return null;
    }

    final student = RobleStudentRecord.fromJson(rows.first);
    cache[studentId] = student;
    return student;
  }

  Future<List<RobleAssessmentCriterionDetail>> _getAssessmentCriteriaDetails(
    String assessmentId,
    Map<String, List<RobleAssessmentCriterionDetail>> cache,
  ) async {
    final trimmedId = assessmentId.trim();
    if (trimmedId.isEmpty) {
      return const [];
    }
    if (cache.containsKey(trimmedId)) {
      return cache[trimmedId]!;
    }

    final criteriaRows = await read(
      'assessment_criteria',
      filters: {'assessment_id': trimmedId},
    );
    final criteria =
        criteriaRows
            .map(RobleAssessmentCriterion.fromJson)
            .where((criterion) => (criterion.id ?? '').isNotEmpty)
            .toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    final details = <RobleAssessmentCriterionDetail>[];
    for (final criterion in criteria) {
      final levelRows = await read(
        'assessment_criterion_levels',
        filters: {'criterion_id': criterion.id},
      );
      final levels =
          levelRows
              .map(RobleAssessmentCriterionLevel.fromJson)
              .where((level) => level.scoreValue > 0)
              .toList()
            ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      details.add(
        RobleAssessmentCriterionDetail(criterion: criterion, levels: levels),
      );
    }

    cache[trimmedId] = details;
    return details;
  }

  Future<List<RobleStudentAssessmentTeammate>> _getGroupTeammates({
    required String groupId,
    required String reviewerStudentId,
    required Map<String, RobleStudentRecord?> studentCache,
  }) async {
    final membershipRows = await read(
      'group_members',
      filters: {'group_id': groupId},
    );
    final teammates = <RobleStudentAssessmentTeammate>[];
    final seenStudentIds = <String>{};

    for (final row in membershipRows) {
      final membership = RobleGroupMemberRecord.fromJson(row);
      if (membership.studentId.isEmpty ||
          membership.studentId == reviewerStudentId ||
          !seenStudentIds.add(membership.studentId)) {
        continue;
      }

      final student = await _getStudentRecordById(
        membership.studentId,
        studentCache,
      );
      if (student == null) {
        continue;
      }

      final name = '${student.firstName.trim()} ${student.lastName.trim()}'
          .trim();
      teammates.add(
        RobleStudentAssessmentTeammate(
          studentId: student.id,
          name: name.isEmpty ? student.username : name,
          email: student.email,
        ),
      );
    }

    teammates.sort((a, b) => a.name.compareTo(b.name));
    return teammates;
  }

  Future<RobleAssessmentSubmission?> _getStudentSubmission({
    required String assessmentId,
    required String reviewerStudentId,
  }) async {
    final trimmedAssessmentId = assessmentId.trim();
    final trimmedReviewerId = reviewerStudentId.trim();
    if (trimmedAssessmentId.isEmpty || trimmedReviewerId.isEmpty) {
      return null;
    }

    final rows = await read(
      'assessment_submissions',
      filters: {
        'assessment_id': trimmedAssessmentId,
        'reviewer_student_id': trimmedReviewerId,
      },
    );
    if (rows.isEmpty) {
      return null;
    }

    final submissions = rows.map(RobleAssessmentSubmission.fromJson).toList()
      ..sort((a, b) {
        if (a.isSubmitted != b.isSubmitted) {
          return a.isSubmitted ? -1 : 1;
        }
        final aDate = a.submittedAt ?? a.startedAt ?? a.createdAt;
        final bDate = b.submittedAt ?? b.startedAt ?? b.createdAt;
        return bDate.compareTo(aDate);
      });

    return submissions.first;
  }

  Future<Map<String, Map<String, int>>> _getSavedScoresByReviewee(
    String submissionId,
  ) async {
    final trimmedSubmissionId = submissionId.trim();
    if (trimmedSubmissionId.isEmpty) {
      return const {};
    }

    final peerReviewRows = await read(
      'assessment_peer_reviews',
      filters: {'submission_id': trimmedSubmissionId},
    );
    final savedScores = <String, Map<String, int>>{};

    for (final row in peerReviewRows) {
      final peerReview = RobleAssessmentPeerReview.fromJson(row);
      if ((peerReview.id ?? '').isEmpty ||
          peerReview.revieweeStudentId.isEmpty) {
        continue;
      }

      final scoreRows = await read(
        'assessment_scores',
        filters: {'peer_review_id': peerReview.id},
      );
      final criterionScores = <String, int>{};
      for (final scoreRow in scoreRows) {
        final score = RobleAssessmentScore.fromJson(scoreRow);
        if (score.criterionId.isEmpty) {
          continue;
        }
        criterionScores[score.criterionId] = score.scoreValue;
      }
      savedScores[peerReview.revieweeStudentId] = criterionScores;
    }

    return savedScores;
  }

  Future<void> _deleteSubmissionCascade(String submissionId) async {
    final trimmedSubmissionId = submissionId.trim();
    if (trimmedSubmissionId.isEmpty) {
      return;
    }

    final peerReviewRows = await read(
      'assessment_peer_reviews',
      filters: {'submission_id': trimmedSubmissionId},
    );
    final peerReviews = peerReviewRows
        .map(RobleAssessmentPeerReview.fromJson)
        .where((peerReview) => (peerReview.id ?? '').isNotEmpty)
        .toList();

    for (final peerReview in peerReviews) {
      final scoreRows = await read(
        'assessment_scores',
        filters: {'peer_review_id': peerReview.id},
      );
      final scores = scoreRows
          .map(RobleAssessmentScore.fromJson)
          .where((score) => (score.id ?? '').isNotEmpty)
          .toList();

      for (final score in scores) {
        await deleteById('assessment_scores', score.id!);
      }

      await deleteById('assessment_peer_reviews', peerReview.id!);
    }

    await deleteById('assessment_submissions', trimmedSubmissionId);
  }

  int _studentAssessmentSortRank(RobleStudentAssessmentAssignment assignment) {
    switch (assignment.statusLabel) {
      case 'Active':
        return 0;
      case 'Scheduled':
        return 1;
      case 'Completed':
        return 2;
      case 'Closed':
        return 3;
      default:
        return 4;
    }
  }

  Future<int> _getSubmittedResponses(String? assessmentId) async {
    final trimmedId = assessmentId?.trim() ?? '';
    if (trimmedId.isEmpty) {
      return 0;
    }

    final rows = await read(
      'assessment_submissions',
      filters: {'assessment_id': trimmedId},
    );

    var submitted = 0;
    for (final row in rows) {
      final status = row['status']?.toString().toLowerCase() ?? '';
      final submittedAt = row['submitted_at']?.toString().trim() ?? '';
      if (status == 'submitted' || submittedAt.isNotEmpty) {
        submitted++;
      }
    }
    return submitted;
  }

  Future<int> _getCategoryStudentCount(String categoryId) async {
    final trimmedId = categoryId.trim();
    if (trimmedId.isEmpty) {
      return 0;
    }

    final groupRows = await read(
      'course_groups',
      filters: {'category_id': trimmedId},
    );
    final groups = groupRows
        .map(RobleCourseGroupRecord.fromJson)
        .where((group) => group.id.isNotEmpty)
        .toList();

    final studentIds = <String>{};
    for (final group in groups) {
      final membershipRows = await read(
        'group_members',
        filters: {'group_id': group.id},
      );

      for (final row in membershipRows) {
        final membership = RobleGroupMemberRecord.fromJson(row);
        if (membership.studentId.isNotEmpty) {
          studentIds.add(membership.studentId);
        }
      }
    }

    return studentIds.length;
  }

  Future<_CourseStats> _getCourseStats(String courseId) async {
    if (courseId.isEmpty) {
      return const _CourseStats(studentCount: 0);
    }

    final groupRows = await read(
      'course_groups',
      filters: {'course_id': courseId},
    );
    if (groupRows.isEmpty) {
      return const _CourseStats(studentCount: 0);
    }

    final groups = groupRows.map(RobleCourseGroupRecord.fromJson).toList();
    final studentIds = <String>{};

    for (final group in groups) {
      final membershipRows = await read(
        'group_members',
        filters: {'group_id': group.id},
      );

      for (final row in membershipRows) {
        final membership = RobleGroupMemberRecord.fromJson(row);
        if (membership.studentId.isNotEmpty) {
          studentIds.add(membership.studentId);
        }
      }
    }

    return _CourseStats(studentCount: studentIds.length);
  }

  /// Inserts multiple rows into [table] sequentially, in chunks of [chunkSize].
  /// Returns the list of generated IDs in the same order as [rows].
  Future<List<String>> insertBatch(
    String table,
    List<Map<String, dynamic>> rows, {
    int chunkSize = 10,
    void Function(int done, int total)? onProgress,
  }) async {
    final ids = <String>[];
    for (var i = 0; i < rows.length; i += chunkSize) {
      final chunk = rows.skip(i).take(chunkSize);
      for (final row in chunk) {
        ids.add(await insert(table, row));
      }
      onProgress?.call((i + chunkSize).clamp(0, rows.length), rows.length);
    }
    return ids;
  }

  /// Resets the cached Dio instance so the next request picks up a fresh token.
  void resetClient() => _dio = null;

  Future<void> _deleteStudentsIfOrphaned(Iterable<String> studentIds) async {
    for (final studentId in studentIds) {
      final trimmedStudentId = studentId.trim();
      if (trimmedStudentId.isEmpty) {
        continue;
      }

      final remainingMemberships = await read(
        'group_members',
        filters: {'student_id': trimmedStudentId},
      );
      if (remainingMemberships.isEmpty) {
        await deleteById('students', trimmedStudentId);
      }
    }
  }
}

class _CourseStats {
  const _CourseStats({required this.studentCount});

  final int studentCount;
}
