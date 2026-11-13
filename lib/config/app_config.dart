import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Konfigurasi aplikasi yang dimuat dari file `.env`.
///
/// File `.env` diabaikan oleh Git (lihat `.gitignore`) sehingga nilai
/// konfigurasi tidak ikut terunggah ke repositori. Gunakan `.env.example`
/// sebagai template.
class AppConfig {
  AppConfig._();

  static const String _defaultBaseUrl = 'https://jsonplaceholder.typicode.com';

  /// Memuat file `.env` ke memori.
  ///
  /// Jika file tidak ditemukan, aplikasi tetap berjalan dengan nilai default
  /// (tanpa API key) dan hanya mencetak pesan umum ke log.
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      debugPrint('[Config] File .env tidak dapat dimuat, memakai nilai default.');
    }
  }

  /// URL dasar API, dibaca dari kunci `BASE_URL`.
  static String get baseUrl {
    if (!dotenv.isInitialized) return _defaultBaseUrl;
    return dotenv.maybeGet('BASE_URL') ?? _defaultBaseUrl;
  }

  /// API key (dummy), dibaca dari kunci `API_KEY`.
  ///
  /// Nilai ini tidak boleh dicetak ke log.
  static String get apiKey {
    if (!dotenv.isInitialized) return '';
    return dotenv.maybeGet('API_KEY') ?? '';
  }

  /// `true` jika API key tersedia.
  static bool get hasApiKey => apiKey.isNotEmpty;
}
