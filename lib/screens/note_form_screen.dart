import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/note.dart';
import '../providers/app_provider.dart';
import '../utils/validators.dart';

/// Form untuk menambah catatan kuliah baru.
///
/// Menutup layar dengan `Navigator.pop(context, true)` jika catatan berhasil
/// disimpan, sehingga pemanggil dapat menampilkan pesan sukses.
class NoteFormScreen extends StatefulWidget {
  /// Membuat [NoteFormScreen].
  const NoteFormScreen({super.key});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = AppProvider.read(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Sanitasi sebelum disimpan.
    final note = Note.create(
      title: Validators.sanitize(_titleController.text, singleLine: true),
      content: Validators.sanitize(_contentController.text),
    );

    setState(() => _isSaving = true);
    final success = await provider.addNote(note);
    if (!mounted) return;

    if (success) {
      navigator.pop(true);
    } else {
      setState(() => _isSaving = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Catatan gagal disimpan. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Catatan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  hintText: 'Mis. Ringkasan Widget Stateful',
                  border: OutlineInputBorder(),
                ),
                maxLength: Validators.titleMax,
                maxLengthEnforcement: MaxLengthEnforcement.none,
                textInputAction: TextInputAction.next,
                validator: Validators.validateTitle,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentController,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'Isi Catatan',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLength: Validators.contentMax,
                maxLengthEnforcement: MaxLengthEnforcement.none,
                minLines: 6,
                maxLines: 10,
                keyboardType: TextInputType.multiline,
                validator: Validators.validateContent,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Catatan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
