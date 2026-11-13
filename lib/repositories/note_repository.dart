import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';
import '../models/student.dart';
import '../services/secure_storage_service.dart';

/// Kontrak akses data catatan (Repository Pattern).
///
/// Lapisan UI/Provider hanya bergantung pada kontrak ini, bukan pada detail
/// penyimpanan (SharedPreferences / secure storage).
abstract class NoteRepository {
  /// Mengambil seluruh catatan (terbaru lebih dulu).
  Future<List<Note>> getNotes();

  /// Menyimpan catatan baru.
  Future<void> addNote(Note note);

  /// Menghapus catatan berdasarkan [id].
  Future<void> deleteNote(String id);
}

/// Implementasi [NoteRepository] berbasis penyimpanan lokal.
///
/// - Metadata (id, judul, tanggal) → SharedPreferences sebagai JSON list.
/// - Isi catatan → flutter_secure_storage dengan key `note_content_<id>`.
class LocalNoteRepository implements NoteRepository {
  /// Membuat repository; [secureStorage] dapat diganti untuk pengujian.
  LocalNoteRepository({SecureStorageService? secureStorage})
      : _secureStorage = secureStorage ?? SecureStorageService();

  /// Key SharedPreferences untuk daftar metadata catatan.
  static const String metadataKey = 'notes_metadata';

  final SecureStorageService _secureStorage;

  @override
  Future<List<Note>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(metadataKey);
    if (raw == null || raw.isEmpty) return [];

    final notes = <Note>[];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      for (final item in decoded) {
        final meta = item as Map<String, dynamic>;
        final content = await _secureStorage.getContent(meta['id'] as String);
        notes.add(Note.fromMetadata(meta, content: content ?? ''));
      }
    } catch (e) {
      debugPrint('[NoteRepository] Metadata catatan tidak valid: ${e.runtimeType}');
      return [];
    }
    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notes;
  }

  @override
  Future<void> addNote(Note note) async {
    final prefs = await SharedPreferences.getInstance();
    final metadata = _readMetadata(prefs);

    // Simpan isi lebih dulu; jika gagal, metadata tidak ikut tersimpan.
    await _secureStorage.saveContent(note.id, note.content);
    metadata.add(note.toMetadata());
    final ok = await prefs.setString(metadataKey, jsonEncode(metadata));
    if (!ok) {
      await _secureStorage.deleteContent(note.id);
      throw StateError('Metadata catatan gagal disimpan.');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final metadata = _readMetadata(prefs)..removeWhere((m) => m['id'] == id);
    await prefs.setString(metadataKey, jsonEncode(metadata));
    await _secureStorage.deleteContent(id);
  }

  List<Map<String, dynamic>> _readMetadata(SharedPreferences prefs) {
    final raw = prefs.getString(metadataKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }
}

/// Repository sederhana untuk menyimpan profil mahasiswa di SharedPreferences.
class StudentRepository {
  /// Key SharedPreferences untuk profil mahasiswa.
  static const String studentKey = 'student_profile';

  /// Membaca profil tersimpan; `null` jika belum ada atau rusak.
  Future<Student?> getStudent() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(studentKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return Student.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Menyimpan [student] sebagai JSON.
  Future<void> saveStudent(Student student) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(studentKey, jsonEncode(student.toJson()));
  }
}
