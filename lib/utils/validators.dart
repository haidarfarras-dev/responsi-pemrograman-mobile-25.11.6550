/// Kumpulan fungsi validasi dan sanitasi input pengguna.
///
/// Semua validator mengembalikan `null` jika input valid, atau pesan error
/// jika tidak valid, sehingga dapat langsung dipakai pada `TextFormField`.
class Validators {
  Validators._();

  /// Panjang minimal judul catatan.
  static const int titleMin = 3;

  /// Panjang maksimal judul catatan.
  static const int titleMax = 50;

  /// Panjang minimal isi catatan.
  static const int contentMin = 10;

  /// Panjang maksimal isi catatan.
  static const int contentMax = 1000;

  static final RegExp _specialChars = RegExp('[<>"\']');
  static final RegExp _controlChars =
      RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]');
  static final RegExp _emailPattern =
      RegExp(r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');
  static final RegExp _nimPattern = RegExp(r'^[0-9.]{6,15}$');

  /// Membersihkan karakter khusus `<`, `>`, `"`, dan `'` serta karakter
  /// kontrol dari [input].
  ///
  /// Jika [singleLine] bernilai `true`, semua whitespace (termasuk baris baru)
  /// dipadatkan menjadi satu spasi. Hasil akhir selalu di-`trim`.
  static String sanitize(String input, {bool singleLine = false}) {
    var result = input.replaceAll(_specialChars, '');
    result = result.replaceAll(_controlChars, '');
    if (singleLine) {
      result = result.replaceAll(RegExp(r'\s+'), ' ');
    }
    return result.trim();
  }

  /// Memvalidasi judul catatan (3–50 karakter setelah disanitasi).
  static String? validateTitle(String? value) {
    final clean = sanitize(value ?? '', singleLine: true);
    if (clean.isEmpty) return 'Judul wajib diisi';
    if (clean.length < titleMin) {
      return 'Judul minimal $titleMin karakter';
    }
    if (clean.length > titleMax) {
      return 'Judul maksimal $titleMax karakter';
    }
    return null;
  }

  /// Memvalidasi isi catatan (10–1000 karakter setelah disanitasi).
  static String? validateContent(String? value) {
    final clean = sanitize(value ?? '');
    if (clean.isEmpty) return 'Isi catatan wajib diisi';
    if (clean.length < contentMin) {
      return 'Isi catatan minimal $contentMin karakter';
    }
    if (clean.length > contentMax) {
      return 'Isi catatan maksimal $contentMax karakter';
    }
    return null;
  }

  /// Memvalidasi nama mahasiswa (3–60 karakter).
  static String? validateName(String? value) {
    final clean = sanitize(value ?? '', singleLine: true);
    if (clean.isEmpty) return 'Nama wajib diisi';
    if (clean.length < 3) return 'Nama minimal 3 karakter';
    if (clean.length > 60) return 'Nama maksimal 60 karakter';
    return null;
  }

  /// Memvalidasi NIM (angka dan titik, 6–15 karakter, mis. `25.11.6550`).
  static String? validateNim(String? value) {
    final clean = sanitize(value ?? '', singleLine: true);
    if (clean.isEmpty) return 'NIM wajib diisi';
    if (!_nimPattern.hasMatch(clean)) {
      return 'NIM hanya angka dan titik (6–15 karakter)';
    }
    return null;
  }

  /// Memvalidasi program studi (3–50 karakter).
  static String? validateProgramStudi(String? value) {
    final clean = sanitize(value ?? '', singleLine: true);
    if (clean.isEmpty) return 'Program studi wajib diisi';
    if (clean.length < 3) return 'Program studi minimal 3 karakter';
    if (clean.length > 50) return 'Program studi maksimal 50 karakter';
    return null;
  }

  /// Memvalidasi format email.
  static String? validateEmail(String? value) {
    final clean = sanitize(value ?? '', singleLine: true);
    if (clean.isEmpty) return 'Email wajib diisi';
    if (!_emailPattern.hasMatch(clean)) return 'Format email tidak valid';
    return null;
  }
}
