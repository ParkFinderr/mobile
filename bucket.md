# Dokumentasi CDN Storage Bucket ParkFinder

Dokumen ini berisi rincian seluruh endpoint dan rute berkas aset gambar yang tersimpan pada **Google Cloud Storage Bucket CDN** aplikasi ParkFinder.

---

## Base Storage URL

```
https://storage.googleapis.com/parkfinderbucket
```

Semua aset di bawah ini dapat diakses secara publik dan dikonfigurasi secara terpusat pada `AppConfig.storageUrl` di `lib/core/config/app_config.dart`.

---

## Daftar Rute Berkas CDN Bucket

### 1. Logo Utama Aplikasi
- **URL**: `https://storage.googleapis.com/parkfinderbucket/logo.png`
- **Tipe**: PNG
- **Digunakan Pada**:
  - `SplashWidget` ([splash_widget.dart](file:///c:/programming/mobile-front/lib/features/splash/widgets/splash_widget.dart))
  - `WelcomeWidget` ([welcome_widget.dart](file:///c:/programming/mobile-front/lib/features/welcome/widgets/welcome_widget.dart))
  - `LoginWidget` ([login_widget.dart](file:///c:/programming/mobile-front/lib/features/auth/widgets/login_widget.dart))

---

### 2. Latar Belakang (Backgrounds)
- **URL Dark Mode**: `https://storage.googleapis.com/parkfinderbucket/background/bg-wellcome-dark.png`
- **URL Light Mode**: `https://storage.googleapis.com/parkfinderbucket/background/bg-wellcome-light.png`
- **Tipe**: PNG
- **Digunakan Pada**: Latar belakang halaman transisi & onboarding (`WelcomeTransitionPage`).

---

### 3. Onboarding & Panduan Fitur
- **URL Dark Mode**: `https://storage.googleapis.com/parkfinderbucket/onboarding/onboarding-dark.png`
- **URL Light Mode**: `https://storage.googleapis.com/parkfinderbucket/onboarding/onboarding-light.png`
- **Tipe**: PNG
- **Digunakan Pada**: Slide karusel panduan awal pengguna (`WelcomeWidget`).

---

### 4. Beranda (Home & Dashboard)
- **URL Dashboard Parkir**: `https://storage.googleapis.com/parkfinderbucket/home/dashboard_parkir.png`
- **Tipe**: PNG
- **Digunakan Pada**:
  - `HomeWidget` ([home_widget.dart](file:///c:/programming/mobile-front/lib/features/home/widgets/home_widget.dart))
  - `HeroBannerWidget` ([hero_banner_widget.dart](file:///c:/programming/mobile-front/lib/features/home/widgets/hero_banner_widget.dart))

---

### 5. Area & Denah Parkir (Parking)
- **URL Denah Parkir**: `https://storage.googleapis.com/parkfinderbucket/parking/denah_parkir.png`
- **URL Peta FT Unila**: `https://storage.googleapis.com/parkfinderbucket/parking/peta_parkir_ft_unila.png`
- **Tipe**: PNG
- **Digunakan Pada**:
  - `BookingWidget` ([booking_widget.dart](file:///c:/programming/mobile-front/lib/features/parking/widgets/booking_widget.dart))
  - `DetailBookingWidget` ([detail_booking_widget.dart](file:///c:/programming/mobile-front/lib/features/parking/widgets/detail_booking_widget.dart))

---

### 6. Pemindai & Tiket QR (Scan)
- **URL QR Scanner**: `https://storage.googleapis.com/parkfinderbucket/scan/qr_scanner.png`
- **Tipe**: PNG
- **Digunakan Pada**:
  - `WelcomeScanWidget` ([welcome_scan_widget.dart](file:///c:/programming/mobile-front/lib/features/scan/widgets/welcome_scan_widget.dart))
  - `ScanBerhasilWidget` ([scan_berhasil_widget.dart](file:///c:/programming/mobile-front/lib/features/scan/widgets/scan_berhasil_widget.dart))
  - Modal Scanner di `HomeWidget`.

---

### 7. Profil & Avatar Pengguna (Profile)
- **URL Avatar Default**: `https://storage.googleapis.com/parkfinderbucket/foto/mock-avatar.png`
- **URL Upload Foto User**: `https://storage.googleapis.com/parkfinderbucket/foto/{filename}.png` (diunggah via `POST /users/profile/photo`)
- **Tipe**: PNG / JPG / JPEG
- **Digunakan Pada**:
  - `ProfileAvatarWidget` ([profile_avatar_widget.dart](file:///c:/programming/mobile-front/lib/features/profile/widgets/profile_avatar_widget.dart))
  - `ProfilWidget` ([profil_widget.dart](file:///c:/programming/mobile-front/lib/features/profile/widgets/profil_widget.dart))
  - `EditProfilePage` ([edit_profile_page.dart](file:///c:/programming/mobile-front/lib/features/profile/pages/edit_profile_page.dart))

---

## Skema Fallback & Redundansi

Seluruh pemanggilan gambar pada kode Flutter menggunakan pola redundansi dua tingkat (*errorBuilder*):

```dart
Image.network(
  '${AppConfig.storageUrl}/path/to/image.png',
  fit: BoxFit.cover,
  errorBuilder: (_, __, ___) => Image.asset(
    'lib/assets/path/to/image.png',
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 48),
  ),
);
```
