import 'package:flutter/material.dart';

import '../models/student.dart';

/// Kartu profil yang menampilkan avatar inisial dan data [Student].
///
/// Widget ini murni tampilan (stateless): tidak memiliki logika bisnis.
class ProfileCard extends StatelessWidget {
  /// Membuat [ProfileCard] untuk [student].
  const ProfileCard({super.key, required this.student});

  /// Data mahasiswa yang ditampilkan.
  final Student student;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            child: Text(
              student.initials,
              style: textTheme.headlineMedium?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            student.name,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(icon: Icons.badge_outlined, label: 'NIM', value: student.nim),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.school_outlined,
            label: 'Program Studi',
            value: student.programStudi,
          ),
          const SizedBox(height: 10),
          _InfoRow(icon: Icons.email_outlined, label: 'Email', value: student.email),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, color: scheme.onPrimaryContainer),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
              ),
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
