import 'package:flutter/material.dart';

/// Tampilan ketika belum ada data untuk ditampilkan.
class EmptyState extends StatelessWidget {
  /// Membuat [EmptyState] dengan [icon], [title], dan [message].
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  /// Ikon besar di bagian atas.
  final IconData icon;

  /// Judul singkat.
  final String title;

  /// Penjelasan atau petunjuk tindakan berikutnya.
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: scheme.outline),
            const SizedBox(height: 16),
            Text(title, style: textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tampilan ketika terjadi error, dengan tombol "Coba lagi".
class ErrorState extends StatelessWidget {
  /// Membuat [ErrorState] dengan [message] dan aksi [onRetry].
  const ErrorState({super.key, required this.message, required this.onRetry});

  /// Pesan error yang ramah pengguna.
  final String message;

  /// Dipanggil saat tombol "Coba lagi" ditekan.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 72, color: scheme.error),
            const SizedBox(height: 16),
            Text('Terjadi kesalahan', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
