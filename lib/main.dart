import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';

/// Titik masuk aplikasi: memuat konfigurasi `.env` lalu menjalankan [MyApp].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  runApp(const MyApp());
}

/// Membangun [ThemeData] terpusat yang dipakai seluruh layar.
ThemeData buildAppTheme() {
  const seed = Color(0xFF3F51B5);
  final scheme = ColorScheme.fromSeed(seedColor: seed);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

/// Widget root aplikasi.
///
/// [AppProviderWrapper] diletakkan di atas [MaterialApp] agar semua rute
/// (yang dibuat Navigator) dapat mengakses [AppProvider].
class MyApp extends StatelessWidget {
  /// Membuat [MyApp].
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviderWrapper(
      child: MaterialApp(
        title: 'Profil Mahasiswa',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
