import 'package:flutter/material.dart';

import '../models/student.dart';
import '../providers/app_provider.dart';
import '../utils/validators.dart';
import '../widgets/profile_card.dart';

/// Halaman profil mahasiswa: menampilkan [ProfileCard] dan form edit profil.
///
/// Logika penyimpanan ada di [AppProvider]; layar ini hanya mengurus tampilan
/// dan input (separation of concerns).
class ProfileScreen extends StatefulWidget {
  /// Membuat [ProfileScreen].
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _prodiController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _prodiController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _startEditing(Student student) {
    _nameController.text = student.name;
    _nimController.text = student.nim;
    _prodiController.text = student.programStudi;
    _emailController.text = student.email;
    setState(() => _isEditing = true);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = AppProvider.read(context);
    final messenger = ScaffoldMessenger.of(context);
    final student = Student(
      name: Validators.sanitize(_nameController.text, singleLine: true),
      nim: Validators.sanitize(_nimController.text, singleLine: true),
      programStudi: Validators.sanitize(_prodiController.text, singleLine: true),
      email: Validators.sanitize(_emailController.text, singleLine: true),
    );

    setState(() => _isSaving = true);
    final success = await provider.updateStudent(student);
    if (!mounted) return;

    setState(() {
      _isSaving = false;
      if (success) _isEditing = false;
    });
    messenger.showSnackBar(
      SnackBar(
        content: Text(success ? 'Profil berhasil diperbarui' : 'Profil gagal disimpan'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = AppProvider.of(context).student;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Mahasiswa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileCard(student: student),
            const SizedBox(height: 20),
            if (_isEditing) _buildForm() else _buildEditButton(student),
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton(Student student) {
    return FilledButton.icon(
      onPressed: () => _startEditing(student),
      icon: const Icon(Icons.edit),
      label: const Text('Edit Profil'),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nama',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            validator: Validators.validateName,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nimController,
            decoration: const InputDecoration(
              labelText: 'NIM',
              prefixIcon: Icon(Icons.badge_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: Validators.validateNim,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _prodiController,
            decoration: const InputDecoration(
              labelText: 'Program Studi',
              prefixIcon: Icon(Icons.school_outlined),
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            validator: Validators.validateProgramStudi,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => setState(() => _isEditing = false),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
