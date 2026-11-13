import 'package:flutter/material.dart';

import '../models/note.dart';
import '../models/student.dart';
import '../repositories/note_repository.dart';

/// InheritedWidget yang menyediakan state aplikasi ke seluruh subtree.
///
/// Widget di bawahnya cukup memanggil [AppProvider.of] untuk membaca data dan
/// memanggil aksi (update profil, tambah/hapus catatan) tanpa mengetahui
/// bagaimana data disimpan.
class AppProvider extends InheritedWidget {
  /// Membuat [AppProvider] dengan state dan aksi yang akan dibagikan.
  const AppProvider({
    super.key,
    required this.student,
    required this.notes,
    required this.isLoading,
    required this.errorMessage,
    required this.updateStudent,
    required this.addNote,
    required this.deleteNote,
    required this.reload,
    required super.child,
  });

  /// Profil mahasiswa saat ini.
  final Student student;

  /// Daftar catatan (tanpa isi yang dapat diubah dari luar).
  final List<Note> notes;

  /// `true` ketika data awal sedang dimuat.
  final bool isLoading;

  /// Pesan error jika pemuatan data gagal, selain itu `null`.
  final String? errorMessage;

  /// Memperbarui profil. Mengembalikan `true` jika berhasil.
  final Future<bool> Function(Student) updateStudent;

  /// Menambah catatan. Mengembalikan `true` jika berhasil.
  final Future<bool> Function(Note) addNote;

  /// Menghapus catatan berdasarkan id. Mengembalikan `true` jika berhasil.
  final Future<bool> Function(String) deleteNote;

  /// Memuat ulang data dari penyimpanan (dipakai tombol "Coba lagi").
  final Future<void> Function() reload;

  /// Mengambil [AppProvider] terdekat dan mendaftarkan dependensi rebuild.
  ///
  /// Gunakan di dalam `build`.
  static AppProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppProvider>();
    assert(provider != null, 'AppProvider tidak ditemukan di widget tree.');
    return provider!;
  }

  /// Mengambil [AppProvider] tanpa mendaftarkan dependensi rebuild.
  ///
  /// Gunakan di dalam callback (onPressed, submit, dsb.).
  static AppProvider read(BuildContext context) {
    final provider = context.getInheritedWidgetOfExactType<AppProvider>();
    assert(provider != null, 'AppProvider tidak ditemukan di widget tree.');
    return provider!;
  }

  @override
  bool updateShouldNotify(AppProvider oldWidget) {
    return student != oldWidget.student ||
        !identical(notes, oldWidget.notes) ||
        isLoading != oldWidget.isLoading ||
        errorMessage != oldWidget.errorMessage;
  }
}

/// StatefulWidget yang mengelola state aplikasi dan menyediakan [AppProvider].
///
/// Prinsip least privilege: setiap aksi hanya mengubah bagian state yang
/// memang diperlukan (profil saja, atau daftar catatan saja).
class AppProviderWrapper extends StatefulWidget {
  /// Membuat wrapper. Repository dapat diganti untuk keperluan pengujian.
  const AppProviderWrapper({
    super.key,
    required this.child,
    this.noteRepository,
    this.studentRepository,
  });

  /// Subtree aplikasi yang akan menerima [AppProvider].
  final Widget child;

  /// Repository catatan (default: [LocalNoteRepository]).
  final NoteRepository? noteRepository;

  /// Repository profil (default: [StudentRepository]).
  final StudentRepository? studentRepository;

  @override
  State<AppProviderWrapper> createState() => _AppProviderWrapperState();
}

class _AppProviderWrapperState extends State<AppProviderWrapper> {
  late final NoteRepository _noteRepository;
  late final StudentRepository _studentRepository;

  Student _student = Student.defaultProfile;
  List<Note> _notes = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _noteRepository = widget.noteRepository ?? LocalNoteRepository();
    _studentRepository = widget.studentRepository ?? StudentRepository();
    _load();
  }

  Future<void> _load() async {
    if (!_isLoading || _errorMessage != null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    try {
      final student = await _studentRepository.getStudent();
      final notes = await _noteRepository.getNotes();
      if (!mounted) return;
      setState(() {
        _student = student ?? Student.defaultProfile;
        _notes = List.unmodifiable(notes);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[AppProvider] Gagal memuat data: ${e.runtimeType}');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Data tidak dapat dimuat. Silakan coba lagi.';
      });
    }
  }

  Future<bool> _updateStudent(Student student) async {
    try {
      await _studentRepository.saveStudent(student);
      if (!mounted) return false;
      setState(() => _student = student);
      return true;
    } catch (e) {
      debugPrint('[AppProvider] Gagal menyimpan profil: ${e.runtimeType}');
      return false;
    }
  }

  Future<bool> _addNote(Note note) async {
    try {
      await _noteRepository.addNote(note);
      if (!mounted) return false;
      setState(() => _notes = List.unmodifiable([note, ..._notes]));
      return true;
    } catch (e) {
      debugPrint('[AppProvider] Gagal menyimpan catatan: ${e.runtimeType}');
      return false;
    }
  }

  Future<bool> _deleteNote(String id) async {
    try {
      await _noteRepository.deleteNote(id);
      if (!mounted) return false;
      setState(() {
        _notes = List.unmodifiable(_notes.where((n) => n.id != id));
      });
      return true;
    } catch (e) {
      debugPrint('[AppProvider] Gagal menghapus catatan: ${e.runtimeType}');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppProvider(
      student: _student,
      notes: _notes,
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      updateStudent: _updateStudent,
      addNote: _addNote,
      deleteNote: _deleteNote,
      reload: _load,
      child: widget.child,
    );
  }
}
