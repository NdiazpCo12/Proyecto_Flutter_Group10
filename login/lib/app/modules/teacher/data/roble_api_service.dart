import 'package:dio/dio.dart';

import '../../../core/config/roble_config.dart';
import '../../../core/storage/session_storage_service.dart';
import '../models/roble_models.dart';

/// Handles all HTTP requests to the ROBLE database API.
/// Uses the access token persisted by [SessionStorageService] after login.
class RobleApiService {
  RobleApiService({SessionStorageService? storage})
    : _storage = storage ?? SessionStorageService();

  final SessionStorageService _storage;

  Dio? _dio;

  Future<Dio> _client() async {
    final token = await _storage.getAccessToken();
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: RobleConfig.dbBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        ),
      );
    }
    // Update token dynamically just in case it was refreshed or null on startup
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

      throw Exception(
        'La API no devolvio una lista valida para la tabla "$table". '
        'Respuesta completa: $body',
      );
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? e.toString();
      throw Exception('ROBLE read error [$table]: $msg');
    }
  }

  /// Inserts [data] into [table] and returns the auto-generated `_id`.
  ///
  /// ROBLE endpoint: POST /:dbName/insert
  /// Expected response: `{ "_id": "...", ... }`
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
            print('ID capturado con éxito: $id');
            return id.toString();
          }
        }
      }

      throw Exception(
        'La API no devolvió un _id válido para la tabla "$table".\n'
        'Respuesta completa: $body',
      );
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? e.toString();
      throw Exception('ROBLE insert error [$table]: $msg');
    } catch (e) {
      throw Exception('Internal error processing ROBLE API connection: $e');
    }
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
        final list = body;
        final mapped = list
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

        print('Cursos obtenidos despues de filtro: ${mapped.length}');
        // Sort newest first
        mapped.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return mapped;
      }

      print('El body no tenia el formato esperado de List.');
      return [];
    } catch (e) {
      if (e is DioException) {
        print('Error response status: ${e.response?.statusCode}');
        print('Error response data: ${e.response?.data}');
      }
      print('Error en getCourses: $e');
      throw Exception('No se pudieron obtener los cursos: $e');
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
      memberships.addAll(
        membershipRows.map(RobleGroupMemberRecord.fromJson),
      );
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

  /// Resets the cached Dio instance, allowing the next call to [_client] to
  /// pick up a fresh access token (useful after token refresh).
  void resetClient() => _dio = null;
}
