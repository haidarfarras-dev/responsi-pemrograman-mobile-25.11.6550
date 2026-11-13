import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// Data pengguna sederhana dari endpoint `/users`.
class ApiUser {
  /// Membuat objek [ApiUser].
  const ApiUser({
    required this.id,
    required this.name,
    required this.email,
    required this.company,
  });

  /// Membuat [ApiUser] dari JSON JSONPlaceholder.
  factory ApiUser.fromJson(Map<String, dynamic> json) {
    final company = json['company'];
    return ApiUser(
      id: json['id'] as int,
      name: json['name'] as String? ?? '-',
      email: json['email'] as String? ?? '-',
      company: company is Map<String, dynamic>
          ? (company['name'] as String? ?? '-')
          : '-',
    );
  }

  /// Id pengguna.
  final int id;

  /// Nama pengguna.
  final String name;

  /// Email pengguna.
  final String email;

  /// Nama perusahaan pengguna.
  final String company;
}

/// Exception dengan pesan yang aman ditampilkan kepada pengguna.
class ApiException implements Exception {
  /// Membuat [ApiException] dengan [message].
  const ApiException(this.message);

  /// Pesan error yang ramah pengguna.
  final String message;

  @override
  String toString() => message;
}

/// Layanan HTTP dasar untuk mengambil data dari API publik.
///
/// Log hanya memuat metode, path, dan status code. API key dan isi respons
/// tidak pernah dicetak.
class ApiService {
  /// Membuat layanan; [client] dapat diganti untuk pengujian.
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Batas waktu tunggu untuk setiap permintaan.
  static const Duration timeout = Duration(seconds: 10);

  final http.Client _client;

  /// Mengambil daftar pengguna lewat HTTP GET `/users`.
  ///
  /// Melempar [ApiException] dengan pesan yang jelas jika terjadi timeout,
  /// tidak ada koneksi, status bukan 200, atau data tidak valid.
  Future<List<ApiUser>> fetchUsers() async {
    final uri = Uri.parse('${AppConfig.baseUrl}/users');
    try {
      debugPrint('[API] GET /users');
      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (AppConfig.hasApiKey) 'x-api-key': AppConfig.apiKey,
        },
      ).timeout(timeout);
      debugPrint('[API] Status ${response.statusCode}');

      if (response.statusCode != 200) {
        throw ApiException('Server merespons dengan status ${response.statusCode}.');
      }
      final decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded
          .map((e) => ApiUser.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } on SocketException {
      debugPrint('[API] SocketException');
      throw const ApiException('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } on TimeoutException {
      debugPrint('[API] Timeout');
      throw const ApiException('Permintaan melebihi batas waktu. Coba lagi.');
    } on http.ClientException {
      debugPrint('[API] ClientException');
      throw const ApiException('Gagal terhubung ke server. Periksa koneksi Anda.');
    } on FormatException {
      debugPrint('[API] FormatException');
      throw const ApiException('Format data dari server tidak valid.');
    } catch (e) {
      debugPrint('[API] Error tak terduga: ${e.runtimeType}');
      throw const ApiException('Terjadi kesalahan tak terduga.');
    }
  }
}
