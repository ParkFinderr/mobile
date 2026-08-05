/// AppConfig — Konfigurasi terpusat aplikasi ParkFinder.
///
/// Berisi Base URL backend dan konfigurasi environment.
/// Tidak ada URL yang boleh di-hardcode di luar file ini.
class AppConfig {
  AppConfig._();

  /// Base URL backend REST API.
  static const String baseUrl =
      'https://backend-api-services-173368161554.asia-southeast2.run.app';

  /// Base URL Google Cloud Storage untuk assets (gambar, ilustrasi).
  static const String storageUrl =
      'https://storage.googleapis.com/parkfinderbucket';

  /// Nama aplikasi
  static const String appName = 'ParkFinder';

  /// Versi aplikasi
  static const String appVersion = '1.0.0';
}
