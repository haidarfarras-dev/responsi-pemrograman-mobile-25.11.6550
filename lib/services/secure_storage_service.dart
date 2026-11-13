import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Layanan penyimpanan terenkripsi untuk isi catatan.
///
/// Memakai `flutter_secure_storage` (Keystore di Android, Keychain di iOS).
/// Layanan ini tidak pernah mencetak isi catatan ke log.
class SecureStorageService {
  /// Membuat layanan; [storage] dapat diganti untuk keperluan pengujian.
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage ();

  final FlutterSecureStorage _storage;

  /// Membentuk key penyimpanan untuk catatan: `note_content_<id>`.
  static String keyFor(String noteId) => 'note_content_$noteId';

  /// Menyimpan [content] terenkripsi untuk catatan dengan id [noteId].
  ///
  /// Melempar exception jika penyimpanan gagal.
  Future<void> saveContent(String noteId, String content) async {
    await _storage.write(key: keyFor(noteId), value: content);
    debugPrint('[SecureStorage] Isi catatan $noteId tersimpan.');
  }

  /// Membaca isi catatan dengan id [noteId].
  ///
  /// Mengembalikan `null` jika tidak ada atau gagal dibaca.
  Future<String?> getContent(String noteId) async {
    try {
      return await _storage.read(key: keyFor(noteId));
    } catch (e) {
      debugPrint('[SecureStorage] Gagal membaca catatan $noteId: ${e.runtimeType}');
      return null;
    }
  }

  /// Menghapus isi catatan dengan id [noteId].
  Future<void> deleteContent(String noteId) async {
    await _storage.delete(key: keyFor(noteId));
    debugPrint('[SecureStorage] Isi catatan $noteId dihapus.');
  }
}
