import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/note.dart';
import '../providers/app_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_card.dart';
import 'note_form_screen.dart';
import 'profile_screen.dart';
import 'users_screen.dart';

/// Halaman utama: profil singkat, daftar catatan, dan tombol tambah catatan.
class HomeScreen extends StatelessWidget {
  /// Membuat [HomeScreen].
  const HomeScreen({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openProfile(BuildContext context) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  Future<void> _openUsers(BuildContext context) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const UsersScreen()),
    );
  }

  Future<void> _openNoteForm(BuildContext context) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const NoteFormScreen()),
    );
    if (saved == true && context.mounted) {
      _showMessage(context, 'Catatan berhasil disimpan');
    }
  }

  Future<void> _confirmDelete(BuildContext context, Note note) async {
    final provider = AppProvider.read(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus catatan?'),
        content: Text('Catatan "${note.title}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final success = await provider.deleteNote(note.id);
    if (!context.mounted) return;
    _showMessage(
      context,
      success ? 'Catatan dihapus' : 'Catatan gagal dihapus',
    );
  }

  void _showDetail(BuildContext context, Note note) {
    final date = DateFormat('dd MMM yyyy, HH:mm').format(note.createdAt);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text(
              note.title,
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(date, style: Theme.of(sheetContext).textTheme.labelMedium),
            const Divider(height: 24),
            SelectableText(note.content),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = AppProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Kuliah'),
        actions: [
          IconButton(
            tooltip: 'Data dari API',
            icon: const Icon(Icons.cloud_outlined),
            onPressed: () => _openUsers(context),
          ),
          IconButton(
            tooltip: 'Profil',
            icon: const Icon(Icons.person),
            onPressed: () => _openProfile(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _ProfileSummary(name: provider.student.name, nim: provider.student.nim),
          Expanded(child: _buildNotes(context, provider)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNoteForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Catatan'),
      ),
    );
  }

  Widget _buildNotes(BuildContext context, AppProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null) {
      return ErrorState(message: provider.errorMessage!, onRetry: provider.reload);
    }
    if (provider.notes.isEmpty) {
      return const EmptyState(
        icon: Icons.note_add_outlined,
        title: 'Belum ada catatan',
        message: 'Ketuk tombol "Catatan" untuk menambahkan catatan kuliah pertamamu.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: provider.notes.length,
      itemBuilder: (context, index) {
        final note = provider.notes[index];
        return NoteCard(
          note: note,
          onTap: () => _showDetail(context, note),
          onDelete: () => _confirmDelete(context, note),
        );
      },
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({required this.name, required this.nim});

  final String name;
  final String nim;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'NIM $nim',
            style: textTheme.bodyMedium?.copyWith(color: scheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}
