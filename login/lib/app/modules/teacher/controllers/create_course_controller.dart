import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../login/services/auth_service.dart';
import '../controllers/teacher_home_controller.dart';
import '../data/roble_api_service.dart';
import '../models/roble_models.dart';

class CreateCourseController extends GetxController {
  CreateCourseController({RobleApiService? apiService})
    : _api = apiService ?? RobleApiService();

  final RobleApiService _api;

  final isLoading = false.obs;
  final statusMessage = ''.obs;
  final progress = 0.0.obs;

  String? _cachedCourseId;
  String? _cachedCategoryId;

  // ── Public entry point ────────────────────────────────────────────────────

  /// Called from the view after the user enters the course name and taps
  /// "Cargar CSV". Opens the file picker, parses the CSV, and uploads
  /// all records to ROBLE in the correct hierarchical order.
  Future<void> pickAndUpload(String courseName) async {
    final trimmed = courseName.trim();
    if (trimmed.isEmpty) {
      Get.snackbar(
        'Campo requerido',
        'Por favor ingresa el nombre del curso.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // ── 1. Pick file ─────────────────────────────────────────────────────
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.isEmpty) return;

    isLoading.value = true;
    progress.value = 0;

    try {
      // ── 2. Parse CSV ───────────────────────────────────────────────────
      _setStatus('Leyendo archivo CSV…');
      final rows = await _parseCsv(result.files.first);

      if (rows.isEmpty) {
        throw Exception('El archivo CSV está vacío o no tiene filas válidas.');
      }

      // ── 3. Get Auth User & Insert course ─────────────────────────────────
      String courseId;
      if (_cachedCourseId != null) {
        _setStatus('Reutilizando curso "$trimmed" (_id: $_cachedCourseId)…');
        courseId = _cachedCourseId!;
      } else {
        _setStatus('Creando curso "$trimmed"…');
        final authService = Get.find<AuthService>();
        final user = await authService.getStoredUser();
        final teacherEmail = user?.email ?? 'profesor@uninorte.edu.co';

        final courseCode = rows.first.groupCode.isNotEmpty
            ? rows.first.groupCode
            : trimmed.replaceAll(' ', '_').toUpperCase();

        final courseObj = RobleCourse(
          name: trimmed,
          code: courseCode,
          description: rows.first.groupCategoryName.isNotEmpty
              ? rows.first.groupCategoryName
              : 'Curso importado desde CSV',
          teacherEmail: teacherEmail,
        );
        print('=== Enviando payload a courses ===\n${courseObj.toJson()}');

        courseId = await _api.insert('courses', courseObj.toJson());
        _cachedCourseId = courseId;
      }

      // ── 4. Insert unique group category ───────────────────────────────
      String categoryId;
      if (_cachedCategoryId != null) {
        _setStatus('Reutilizando categoría (_id: $_cachedCategoryId)…');
        categoryId = _cachedCategoryId!;
      } else {
        var categoryName = rows.first.groupCategoryName;
        if (categoryName.isEmpty) categoryName = 'Categoría General';

        _setStatus('Creando categoría "$categoryName"…');
        final categoryObj = RobleGroupCategory(
          name: categoryName,
          courseId: courseId,
        );
        print(
          '=== Enviando payload a group_categories ===\n${categoryObj.toJson()}',
        );

        categoryId = await _api.insert(
          'group_categories',
          categoryObj.toJson(),
        );
        _cachedCategoryId = categoryId;
      }

      // ── 5. Insert unique groups ────────────────────────────────────────
      _setStatus('Creando grupos…');
      final groupIds = await _insertUniqueGroups(rows, courseId, categoryId);

      // ── 6. Insert students (deduplicated by email) ─────────────────────
      _setStatus('Insertando estudiantes…');
      final studentIds = await _insertUniqueStudents(rows);

      // ── 7. Insert group_members ────────────────────────────────────────
      _setStatus('Vinculando estudiantes a grupos…');
      await _insertGroupMembers(rows, studentIds, groupIds);

      _setStatus('¡Curso creado exitosamente!');
      Get.snackbar(
        'Éxito',
        'El curso "$trimmed" se creó con ${studentIds.length} estudiantes.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
      Get.find<TeacherHomeController>().fetchCourses();
    } catch (e) {
      _setStatus('Error: ${e.toString()}');
      Get.snackbar(
        'Error al crear curso',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 6),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<List<CsvRow>> _parseCsv(PlatformFile file) async {
    String content;
    if (file.bytes != null) {
      content = String.fromCharCodes(file.bytes!);
    } else if (file.path != null) {
      content = await File(file.path!).readAsString();
    } else {
      throw Exception('No se pudo leer el archivo seleccionado.');
    }

    final rawRows = const CsvToListConverter(eol: '\n').convert(content);

    // Skip the header row (index 0) if it starts with a known header text
    final startIndex =
        (rawRows.isNotEmpty &&
            rawRows.first.first.toString().contains('Group Category'))
        ? 1
        : 0;

    return rawRows
        .skip(startIndex)
        .where(
          (row) =>
              row.isNotEmpty && row.any((c) => c.toString().trim().isNotEmpty),
        )
        .map(CsvRow.fromList)
        .toList();
  }

  /// Inserts each unique group (by code) and returns a map of groupCode → ROBLE ID.
  Future<Map<String, String>> _insertUniqueGroups(
    List<CsvRow> rows,
    String courseId,
    String categoryId,
  ) async {
    final seen = <String, String>{};
    var done = 0;

    for (final row in rows) {
      if (seen.containsKey(row.groupCode)) continue;

      final groupObj = RobleCourseGroup(
        name: row.groupName.isNotEmpty ? row.groupName : 'Grupo sin nombre',
        code: row.groupCode.isNotEmpty ? row.groupCode : 'GC',
        categoryId: categoryId,
        courseId: courseId,
      );

      print('=== Enviando payload a course_groups ===\n${groupObj.toJson()}');
      final id = await _api.insert('course_groups', groupObj.toJson());

      seen[row.groupCode] = id;
      done++;
      _setStatus('Grupos: $done insertados…');
    }

    return seen;
  }

  /// Inserts each unique student (by email) and returns a map of email → ROBLE ID.
  Future<Map<String, String>> _insertUniqueStudents(List<CsvRow> rows) async {
    final seen = <String, String>{};
    var done = 0;

    for (final row in rows) {
      if (seen.containsKey(row.email)) continue;

      final studentObj = RobleStudent(
        username: row.username.isNotEmpty
            ? row.username
            : row.email.split('@').first,
        orgId: row.orgDefinedId.isNotEmpty ? row.orgDefinedId : '00000',
        firstName: row.firstName.isNotEmpty ? row.firstName : 'Sin nombre',
        lastName: row.lastName.isNotEmpty ? row.lastName : 'Sin apellido',
        email: row.email.isNotEmpty ? row.email : 'correo@invalido.com',
      );

      print('=== Enviando payload a students ===\n${studentObj.toJson()}');
      final id = await _api.insert('students', studentObj.toJson());

      seen[row.email] = id;
      done++;
      progress.value = done / rows.length;
      _setStatus('Estudiantes: $done insertados…');
    }

    return seen;
  }

  Future<void> _insertGroupMembers(
    List<CsvRow> rows,
    Map<String, String> studentIds,
    Map<String, String> groupIds,
  ) async {
    var done = 0;
    for (final row in rows) {
      final studentId = studentIds[row.email];
      final groupId = groupIds[row.groupCode];

      if (studentId == null || groupId == null) continue;

      final fechaOriginal = row.enrollmentDate;
      final fechaFormateada = _formatSpanishDate(fechaOriginal);
      print('Fecha convertida: $fechaOriginal -> $fechaFormateada');

      final memberObj = RobleGroupMember(
        studentId: studentId,
        groupId: groupId,
        enrollmentDate: fechaFormateada,
      );

      print('=== Enviando payload a group_members ===\n${memberObj.toJson()}');
      await _api.insert('group_members', memberObj.toJson());

      done++;
      _setStatus('Membresías: $done/${rows.length}…');
    }
  }

  void _setStatus(String msg) => statusMessage.value = msg;

  String _formatSpanishDate(String date) {
    if (date.isEmpty) return DateTime.now().toIso8601String();

    final months = {
      'enero': '01',
      'febrero': '02',
      'marzo': '03',
      'abril': '04',
      'mayo': '05',
      'junio': '06',
      'julio': '07',
      'agosto': '08',
      'septiembre': '09',
      'octubre': '10',
      'noviembre': '11',
      'diciembre': '12',
    };

    try {
      // Input: '4 de febrero de 2026 08:13'
      final parts = date.toLowerCase().split(' ');
      if (parts.length >= 6) {
        final day = parts[0].padLeft(2, '0');
        final monthStr = months[parts[2]] ?? '01';
        final year = parts[4];
        final time = parts[5];
        return '$year-$monthStr-$day $time:00';
      }
    } catch (_) {}

    return DateTime.now().toIso8601String();
  }
}
