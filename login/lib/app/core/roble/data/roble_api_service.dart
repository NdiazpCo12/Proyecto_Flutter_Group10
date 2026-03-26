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
