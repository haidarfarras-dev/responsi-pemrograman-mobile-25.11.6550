/// Model catatan kuliah.
///
/// Hanya metadata ([id], [title], [createdAt]) yang disimpan di
/// SharedPreferences. [content] disimpan terenkripsi di secure storage.
class Note {
  /// Membuat objek [Note] yang immutable.
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  /// Membuat catatan baru dengan id unik berbasis waktu.
  factory Note.create({required String title, required String content}) {
    final now = DateTime.now();
    return Note(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: now,
    );
  }

  /// Membuat [Note] dari metadata JSON dan [content] dari secure storage.
  factory Note.fromMetadata(
    Map<String, dynamic> json, {
    required String content,
  }) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: content,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Identitas unik catatan.
  final String id;

  /// Judul catatan.
  final String title;

  /// Isi catatan (disimpan terenkripsi, bukan di SharedPreferences).
  final String content;

  /// Waktu catatan dibuat.
  final DateTime createdAt;

  /// Metadata catatan untuk SharedPreferences (tanpa isi catatan).
  Map<String, dynamic> toMetadata() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
      };
}
