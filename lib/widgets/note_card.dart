import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/note.dart';

/// Kartu ringkas untuk satu [Note] pada daftar catatan.
class NoteCard extends StatelessWidget {
  /// Membuat [NoteCard].
  ///
  /// [onDelete] dipanggil saat ikon hapus ditekan, [onTap] saat kartu ditekan.
  const NoteCard({
    super.key,
    required this.note,
    required this.onDelete,
    this.onTap,
  });

  /// Catatan yang ditampilkan.
  final Note note;

  /// Callback ketika tombol hapus ditekan.
  final VoidCallback onDelete;

  /// Callback ketika kartu ditekan (mis. melihat isi lengkap).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final date = DateFormat('dd MMM yyyy, HH:mm').format(note.createdAt);
    final preview = note.content.replaceAll(RegExp(r'\s+'), ' ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        title: Text(
          note.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(date, style: textTheme.labelSmall),
            const SizedBox(height: 4),
            Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: 'Hapus catatan',
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
