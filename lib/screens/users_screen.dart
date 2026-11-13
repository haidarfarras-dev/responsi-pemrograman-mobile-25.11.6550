import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/empty_state.dart';

/// Halaman demo HTTP GET: menampilkan daftar pengguna dari API publik.
///
/// Menangani state loading, error (timeout/tanpa koneksi), kosong, dan data.
class UsersScreen extends StatefulWidget {
  /// Membuat [UsersScreen]; [apiService] dapat diganti untuk pengujian.
  const UsersScreen({super.key, this.apiService});

  /// Layanan API (default: [ApiService]).
  final ApiService? apiService;

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late final ApiService _api;
  List<ApiUser> _users = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = widget.apiService ?? ApiService();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final users = await _api.fetchUsers();
      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data dari API')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ErrorState(message: _error!, onRetry: _fetch);
    }
    if (_users.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        title: 'Data kosong',
        message: 'Server tidak mengembalikan data pengguna.',
      );
    }
    return RefreshIndicator(
      onRefresh: _fetch,
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            leading: CircleAvatar(child: Text('${user.id}')),
            title: Text(user.name),
            subtitle: Text('${user.email}\n${user.company}'),
            isThreeLine: true,
          );
        },
      ),
    );
  }
}
