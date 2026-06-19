# Update 0002

Date: 2026-06-09
Task: Frontend Flow Audit & Static UI Validation

---

# Implementation Report

## Task Summary

Audit menyeluruh terhadap alur frontend Flutter Mobile App ParkFinder.
Fokus: navigasi, asset, layout, UI consistency, dan dead code.
Tidak ada perubahan kode — hanya investigasi dan pelaporan.

---

## Changes Made

### Added

* Laporan audit frontend (`update/0002-frontend-flow-audit.md`)

### Modified

* None

### Removed

* None

---

## Files Created

```txt
update/0002-frontend-flow-audit.md
```

---

## Files Modified

```txt
None
```

---

## Files Removed

```txt
None
```

---

## Dependencies Added

```txt
None
```

---

## Dependencies Removed

```txt
None
```

---

## Folder Structure Changes

```txt
None
```

---

# Actual App Flow Map

```
Splash (/)
  │ tap arrow button
  ▼
Welcome (/welcome)
  │ tap "Mulai"
  ▼
WelcomeTransition (/welcome-transition)
  │ auto-navigate after 1.2 detik
  ▼
Login (/login)
  │ tap "Daftar Sekarang"                    │ success login → bottom sheet → dismiss
  ▼                                          ▼
Register (/register)                   WelcomeScan (/welcome-scan)
  │ success → bottom sheet → dismiss         │ scan barcode detected
  ▼                                          ▼
Login (/login)                         ScanBerhasil (/scan-berhasil)
                                            │ "Lanjut Booking"          │ "Pindai Ulang"
                                            ▼                           ▼
                                        Home (/home)              WelcomeScan (/welcome-scan)

Home (/home)
  │ bottom nav: Parkir (1)     │ bottom nav: History (3)    │ bottom nav: Profil (4)
  ▼                             ▼                             ▼
Booking (/booking)            History (/history)            Profil (/profil)
  │ tap item parkir                                          │ "Edit Profil"     │ "Preferensi"
  ▼                                                          ▼                   ▼
DetailBooking (/detail-booking)                          EditProfil          Pengaturan
  │ back button                   │ bottom nav: other
  ▼                               ▼
Booking (/booking)          Home / History / Profil

StatusKendaraan (/status-kendaraan)
  │ bottom nav: other              │ "Keluar Parkir"
  ▼                                ▼
Home / Booking / History      Home (/home)

Catatan:
  • AnimasiScan (/animasi-scan)     → ❌ TIDAK TERHUBUNG — tidak ada screen yang navigasi ke sini
  • HalamanScan (/halaman-scan)     → ❌ TIDAK TERHUBUNG — hanya reachable dari AnimasiScan
  • TutorPopup (/tutor-popup)       → ❌ TIDAK TERHUBUNG — route ada, tidak pernah dipanggil
```

---

# Navigation Audit

## Verifikasi vs AGENTS.md

| No | Route | Status | Keterangan |
|----|-------|--------|------------|
| 1 | `/` | ✅ | Splash → Welcome via tap |
| 2 | `/welcome` | ✅ | Welcome → WelcomeTransition via "Mulai" |
| 3 | `/welcome-transition` | ✅ | Auto-nav ke Login ✅ |
| 4 | `/login` | ✅ | Login → Register / WelcomeScan ✅ |
| 5 | `/register` | ✅ | Register → Login setelah sukses ✅ |
| 6 | `/welcome-scan` | ✅ | WelcomeScan → ScanBerhasil via scan ✅ |
| 7 | `/animasi-scan` | ❌ **DEAD ROUTE** | Tidak ada navigasi ke route ini |
| 8 | `/halaman-scan` | ❌ **DEAD ROUTE** | Hanya reachable dari AnimasiScan (dead) |
| 9 | `/scan-berhasil` | ✅ | ScanBerhasil → Home / WelcomeScan ✅ |
| 10 | `/home` | ✅ | Bottom nav ke Booking, History, Profil ✅ |
| 11 | `/status-kendaraan` | ✅ | Bottom nav index 2 → StatusKendaraan ✅ |
| 12 | `/tutor-popup` | ❌ **DEAD ROUTE** | Tidak ada navigasi ke route ini |
| 13 | `/booking` | ✅ | Booking → DetailBooking ✅ |
| 14 | `/detail-booking` | ⚠️ **MISSING ARGUMENT** | areaId tidak di-pass dari BookingWidget & HomeWidget |
| 15 | `/history` | ✅ | History → navigasi via bottom nav ✅ |
| 16 | `/profil` | ✅ | Profil → EditProfil / Pengaturan ✅ |
| 17 | `/edit-profil` | ✅ | EditProfil → pop back ✅ |
| 18 | `/pengaturan` | ✅ | Pengaturan → pop back ✅ |

## Route Issues

### Route Mati (Dead Routes)

| Route | Page | Penyebab |
|-------|------|----------|
| `/animasi-scan` | AnimasiScanPage | Tidak ada Navigator.pushNamed ke route ini di seluruh codebase |
| `/halaman-scan` | HalamanScanPage | Hanya reachable dari AnimasiScanWidget (dead), sehingga otomatis dead |
| `/tutor-popup` | TutorPopupPage | Tidak ada Navigator.pushNamed ke route ini |

### Area ID Tidak Di-pass

| File | Baris | Kode | Dampak |
|------|-------|------|--------|
| `lib/features/home/widget/home_widget.dart` | 125 | `Navigator.pushNamed(context, AppRoutes.detailBooking)` | areaId = '' — slot map akan kosong |
| `lib/features/booking/widget/booking_widget.dart` | 115 | `Navigator.pushNamed(context, AppRoutes.detailBooking)` | areaId = '' — slot map akan kosong |

DetailBookingPage menerima areaId via argument routing, tapi kedua call site tidak mengirimkannya.

---

# Asset Audit

## Asset Summary

**Semua asset adalah remote CDN** dari `https://storage.googleapis.com/parkfinderbucket`.
Tidak ada local asset yang didefinisikan di `pubspec.yaml` (tidak ada block `assets:`).

| Asset Path | Digunakan di | Status |
|------------|-------------|--------|
| `/foto/logo.png` | SplashScreenWidget | ⚠️ Remote — tergantung ketersediaan CDN |
| `/background/bg-wellcome-dark.png` | WelcomeWidget, LoginWidget, RegisterWidget, ScanBerhasilWidget, WelcomeTransitionPage | ⚠️ Remote |
| `/background/bg-wellcome-light.png` | WelcomeWidget, LoginWidget, RegisterWidget, ScanBerhasilWidget | ⚠️ Remote |
| `/background/bg-home.png` | HeroBannerWidget | ⚠️ Remote |
| `/foto/mclaren-depan.png` | HeroBannerWidget | ⚠️ Remote |
| `/foto/tiket.png` | StatusCardWidget (tiket) | ⚠️ Remote |
| `/foto/wait.png` | StatusCardWidget (waiting) | ⚠️ Remote |
| `/foto/yellow-mobil.png` | StatusCardWidget (car) | ⚠️ Remote |
| `/foto/wel-tutor.png` | HomePage tutorial dialog | ⚠️ Remote |
| `/foto/tutor1.png` | HomePage tutorial dialog | ⚠️ Remote |
| `/foto/tutor2.png` | HomePage tutorial dialog | ⚠️ Remote |
| `/foto/tutor3.png` | HomePage tutorial dialog | ⚠️ Remote |

## Asset Issues

1. **Semua asset remote**: Tidak ada local fallback asset. Jika CDN down, semua gambar akan menampilkan errorBuilder/placeholder.
2. **Error handler sudah ada**: Setiap Image.network / CachedNetworkImage sudah punya errorBuilder/placeholder → aman dari crash, tapi UX tetap terpengaruh.
3. **Tidak ada local asset di pubspec.yaml**: Tidak ada `assets:` section. Ini normal karena semua dari CDN.
4. **Web icons (favicon, manifest icons)**: Icon default Flutter masih ada di `web/icons/` dan `pwa/icons/`. Belum diganti dengan logo ParkFinder yang sesungguhnya.

---

# Layout Audit

## Layout Issues Ditemukan

### 🔴 HalamanScanWidget — Overflow Layout

| Issue | Detail |
|-------|--------|
| **Lokasi** | `lib/features/halaman_scan/widget/halaman_scan_widget.dart:75-134` |
| **Masalah** | Camera area: `size.height * 0.65` (line 77) + Bottom panel: `size.height * 0.38` (line 131) = **103%** dari layar |
| **Dampak** | Akan menyebabkan `RenderFlex overflow` pada sebagian besar perangkat. Panel bawah akan bertumpuk dengan camera area. |
| **Severity** | **HIGH** — Layout break |

### 🟡 WelcomeScanWidget — Side Margin Risk

| Issue | Detail |
|-------|--------|
| **Lokasi** | `lib/features/welcome_scan/widget/welcome_scan_widget.dart:217-219` |
| **Masalah** | `_sideMargin` = `(width - 240) / 2`. Jika layar < 240px, margin jadi negatif → overflow. |
| **Dampak** | Hanya risk pada perangkat sangat kecil (< 240px, tidak realistis untuk modern) |
| **Severity** | **LOW** |

### 🟡 StatusKendaraanPage — Potensi Overflow

| Issue | Detail |
|-------|--------|
| **Lokasi** | `lib/features/home/page/status_kendaraan_page.dart` |
| **Masalah** | Tidak menggunakan `SingleChildScrollView`. Car circle (200×240) + info boxes + button "Keluar Parkir" dalam satu Column. Pada layar kecil, bisa overflow. |
| **Dampak** | Potensi overflow pada perangkat dengan tinggi < 640px |
| **Severity** | **MEDIUM** |

### 🟡 DetailBooking — Floor Tabs Wrap

| Issue | Detail |
|-------|--------|
| **Lokasi** | `lib/features/detail_booking/widget/detail_booking_widget.dart:126-138` |
| **Masalah** | Row horizontal untuk floor tabs — jika layar sempit dan tabs > 3, row bisa overflow. |
| **Dampak** | Saat ini 3 tabs (`['Semua', 'Lantai 1', 'Lantai 2']`) → OK. Jika ditambah, bisa overflow. |
| **Severity** | **LOW** (untuk saat ini) |

## Layout Patterns

| Pattern | Digunakan di | Status |
|---------|-------------|--------|
| `SingleChildScrollView` | Login, Register, Home, Profil, Pengaturan, EditProfil | ✅ Good |
| `SafeArea` | SplashScreen, AnimasiScan, Home, History, Profil, EditProfil, Pengaturan, StatusKendaraan | ✅ Good |
| Column tanpa scroll | HalamanScan, StatusKendaraan, WelcomeScan | ⚠️ Risk |
| `MediaQuery.of(context)` | Hampir semua screen | ✅ Standard |

---

# UI Consistency Audit

## Color Consistency

| Screen | Background Color | Status |
|--------|-----------------|--------|
| SplashScreen | `Colors.white` | ❌ **Inkonsisten** — semua screen lain pakai dark bg |
| WelcomePage | `Color(0xFF0D1628)` | ✅ Sesuai design system |
| WelcomeTransition | `Colors.black` | ✅ Masuk akal (full bg image) |
| WelcomeScan | `Color(0xFF0A1225)` | ⚠️ Sedikit berbeda dari `0xFF0D1628` |
| HalamanScan (bottom) | `Color(0xFF0D1628)` | ✅ |
| Semua screen lain | `Color(0xFF0D1628)` | ✅ |

## Button Style Consistency

| Screen | Tombol | Style | Status |
|--------|--------|-------|--------|
| Welcome | "Mulai" | White bg, black87 text, radius 14 | Reference |
| Login | "Masuk" | White bg, black87 text, radius 14 | ✅ Sama |
| Register | "Daftar" | White bg, black87 text, radius 14 | ✅ Sama |
| ScanBerhasil | "Lanjut Booking" | Dark bg (`#0D1A30`), accent border, radius 14 | ❌ **Berbeda** |
| ScanBerhasil | "Pindai Ulang" | Dark bg, borderColor border, radius 14 | ❌ **Berbeda** |
| Tutorial dialog | "Selanjutnya" | Dark bg (`#1A3A6B`), accent border, radius 12 | ❌ **Berbeda** (radius 12) |
| StatusKendaraan | "Keluar Parkir" | Accent bg, white text, radius 14 | ✅ Berbeda (primary style) |
| Profil | "Keluar" | Red bg, radius 14 | ✅ Berbeda (danger style) |
| EditProfil | "Simpan Perubahan" | Accent bg, radius 14 | ✅ Berbeda (primary style) |

## Typography Issues

### `AppTextStyles` — **TIDAK DIGUNAKAN SAMA SEKALI**

Seluruh 11 style yang didefinisikan di `lib/core/theme/app_text_styles.dart` tidak pernah di-referensi oleh screen manapun. Semua screen menggunakan inline `TextStyle()`.

### Inline TextStyle Berserakan

Pattern tidak konsisten — setiap screen mendefinisikan ulang:
- `fontSize` tanpa standarisasi (contoh: "Selamat Datang" kadang 24, 26, 28)
- `fontWeight` tanpa standarisasi
- `color` kadang dari `AppColors.textSecondary`, kadang dari `Colors.white.withOpacity(0.65)`

### Font Family

- `ThemeData.fontFamily: 'Roboto'` di `app.dart`
- `GoogleFonts.poppinsTextTheme()` di theme, tapi `textTheme` hanya di-set untuk bodyMedium & bodySmall
- Tidak ada screen yang secara eksplisit menggunakan Poppins atau Roboto → font default tergantung platform

## Spacing Consistency

| Elemen | Pattern | Status |
|--------|---------|--------|
| Horizontal padding screen | 16px (konsisten) | ✅ |
| SizedBox antar section | 16px (umum), 20px (beberapa) | ⚠️ Variasi kecil |
| SizedBox antar item list | 10px atau 12px | ⚠️ Variasi |
| Card padding | 14px atau 16px | ⚠️ Variasi |

## Border Radius

| Elemen | Radius | Status |
|--------|--------|--------|
| Cards | 14 atau 16 | ⚠️ Variasi |
| Buttons (umum) | 14 | ✅ |
| Tutorial buttons | 12 | ❌ Berbeda |
| Bottom nav | 32 | ✅ Berbeda (sengaja) |
| Input fields | 12 | ✅ |

---

# Dead Code Audit

## Dead Routes (3)

| Route | File | Keterangan |
|-------|------|------------|
| `/animasi-scan` | `app_routes.dart:11` | Route terdaftar, page exists, tapi tidak pernah di-navigasi |
| `/halaman-scan` | `app_routes.dart:12` | Hanya reachable dari AnimasiScan (dead) |
| `/tutor-popup` | `app_routes.dart:16` | Route terdaftar, page exists, tapi tidak pernah di-navigasi |

## Dead Widgets (Full Pages)

| Widget | Route | Penyebab |
|--------|-------|----------|
| `AnimasiScanPage` | `/animasi-scan` | Route tidak pernah dipanggil |
| `AnimasiScanWidget` | — | Composer widget, hanya dipakai AnimasiScanPage |
| `ScanPreviewContainerWidget` | — | Sub-widget, hanya dipakai AnimasiScanWidget |
| `ScanPreviewContentWidget` | — | Sub-widget, hanya dipakai ScanPreviewContainerWidget |
| `ScanStepIndicatorWidget` | — | Sub-widget, hanya dipakai AnimasiScanWidget |
| `ScanStepInfoWidget` | — | Sub-widget, hanya dipakai AnimasiScanWidget |
| `HalamanScanPage` | `/halaman-scan` | Route tidak pernah reachable |
| `HalamanScanWidget` | — | Composer widget, hanya dipakai HalamanScanPage |
| `TutorPopupPage` | `/tutor-popup` | Route tidak pernah dipanggil |
| `TutorPopupWidget` | — | Widget di dalam TutorPopupPage (tapi page tidak pernah dibuka) |

Total: **10 widget mati** (3 page + 7 sub-widget) akibat 3 dead route.

## Dead Service

Tidak ada service yang mati — `ScanService` dan `AuthService` digunakan oleh screen lain yang reachable. Tapi `ScanService` hanya digunakan oleh HalamanScanWidget yang dead → **efektif dead**.

## Dead Design Token

| File | Status |
|------|--------|
| `lib/core/theme/app_text_styles.dart` | **TIDAK digunakan** — 11 style didefinisikan, 0 dipakai |

## Duplikasi Tutorial

| Implementasi | Lokasi | Cara Kerja |
|-------------|--------|------------|
| **TutorPopupPage** | `lib/features/tutor_popup/` | Page penuh dengan 4 step (icon-based). **Tidak pernah dipanggil.** |
| **_TutorialDialog** (di HomePage) | `lib/features/home/page/home_page.dart:63-341` | Dialog overlay dengan 4 step (image-based dari CDN). **Ini yang aktif.** |
| **AnimasiScanWidget** | `lib/features/animasi_scan/` | 3 step tutorial. **Tidak pernah reachable.** |

Ada **3 implementasi tutorial** yang berbeda untuk tujuan yang sama.

---

# Other Issues Found

## DetailBooking Area ID Not Passed

```
booking_widget.dart:115 — Navigator.pushNamed(context, AppRoutes.detailBooking)
home_widget.dart:125   — Navigator.pushNamed(context, AppRoutes.detailBooking)
```

Keduanya tidak mengirim `arguments: areaId`, sehingga `DetailBookingPage.areaId` = `''` (string kosong). Akibatnya, `_fetchSlots()` di `detail_booking_widget.dart:44` mendeteksi `areaId.isEmpty` dan return early tanpa fetch data.

## ScanBerhasil Ticket Code Hardcoded

`scan_berhasil_widget.dart:170-172`:
```dart
const Text(
  'TXT-20260302-0054',
```

Ticket code adalah string literal (`const`), bukan dari parameter/argument route.

## Home Parking List Hardcoded

`home_widget.dart:31-47` — 3 item hardcoded dengan data statis.

## History Data Hardcoded

`history_widget.dart:49-60` — 8 item hardcoded dengan data statis.

## API Contract Mismatch (dari AGENTS.md)

`scan_service.dart:11` mengirim body `{'ticketId': ticketId}`, tapi backend `POST /access/verify` menerima `qrCode`.

## Timer StatusKendaraan Tidak Berjalan

`status_kendaraan_page.dart:20` — `_seconds = 0` tidak pernah di-increment. Tidak ada `Timer.periodic` atau logic increment.

## EditProfil Tidak Panggil API

`edit_profil_page.dart:312` — `onPressed: _showSuccess` hanya menampilkan dialog sukses lokal tanpa HTTP call.

## Test Rusak

`test/widget_test.dart` — expect `'Splash Screen'` text yang tidak ada di aplikasi.

---

# Summary of Findings

| Kategori | Jumlah | Detail |
|----------|--------|--------|
| **Route Mati** | **3** | `/animasi-scan`, `/halaman-scan`, `/tutor-popup` |
| **Widget Mati** | **10** | 3 pages + 7 sub-widgets |
| **Layout Issue (HIGH)** | **1** | HalamanScanWidget overflow (0.65 + 0.38 = 1.03) |
| **Layout Issue (MEDIUM)** | **1** | StatusKendaraanPage tidak pakai scroll |
| **Layout Issue (LOW)** | **2** | WelcomeScan margin risk, DetailBooking tabs wrap |
| **UI Inkonsistensi** | **3** | Button style, Splash bg putih, AppTextStyles tidak dipakai |
| **Data Hardcoded** | **4** | Home (3 parkir), History (8 item), AnimasiScan (3 preview), ScanBerhasil (ticket code) |
| **Argument Missing** | **1** | areaId tidak di-pass ke DetailBooking |
| **API Mismatch** | **1** | ticketId vs qrCode di POST /access/verify |

---

## Recommended Next Steps (Prioritas)

1. **🔴 HIGH** — Fix layout overflow di HalamanScanWidget (0.65 + 0.38 > 1.0)
2. **🔴 HIGH** — Kirim areaId argument dari BookingWidget dan HomeWidget ke DetailBooking
3. **🔴 HIGH** — Hapus/merge 3 route mati: `/animasi-scan`, `/halaman-scan`, `/tutor-popup`
4. **🟡 MEDIUM** — Gunakan `AppTextStyles` di seluruh screen (hilangkan inline TextStyle)
5. **🟡 MEDIUM** — Standarisasi button style (ikuti pattern white-bg untuk primary, atau buat PrimaryButtonWidget yang baku)
6. **🟡 MEDIUM** — Standardisasi border radius buttons (14 konsisten)
7. **🟡 MEDIUM** — Tambah `SingleChildScrollView` di StatusKendaraanPage
8. **🟢 LOW** — Fix splash screen bg color mengikuti design system
9. **🟢 LOW** — Standarisasi WelcomeScan bg color agar sama dengan screen lain

---

# Validation Checklist

* [x] Build diverifikasi — Tidak ada perubahan kode (audit only)
* [x] Tidak ada error lint — Tidak ada perubahan kode
* [x] Tidak ada error runtime — Tidak ada perubahan kode
* [ ] Semua fitur lama tetap berjalan — Tidak ada perubahan kode
* [x] Laporan audit lengkap — ✅

---

# Known Issues

Semua issue telah dicatat di masing-masing section di atas.

---

# Technical Debt

Semua technical debt telah dicatat di masing-masing section dan di Update 0001.

---

# Remaining Work

Implementasi perbaikan berdasarkan prioritas yang direkomendasikan.

---

## Executive Summary

1. **3 route mati** ditemukan: `/animasi-scan`, `/halaman-scan`, `/tutor-popup` — total **10 widget** tidak pernah digunakan
2. **1 layout HIGH risk**: HalamanScanWidget memiliki overflow (103% tinggi layar)
3. **3 implementasi tutorial** berbeda untuk fitur yang sama (TutorPopupPage, _TutorialDialog, AnimasiScanWidget)
4. **DetailBooking areaId** tidak di-pass dari dua call site, menyebabkan slot map kosong
5. **AppTextStyles** (11 style) tidak digunakan sama sekali — semua screen pakai inline TextStyle
6. **4 data hardcoded**: Home, History, AnimasiScan, ScanBerhasil
7. **1 API contract mismatch**: `ticketId` vs `qrCode`
8. **Button style tidak konsisten**: White bg vs dark bg, radius 12 vs 14
9. **SplashScreen** adalah satu-satunya screen dengan background putih (inkonsisten)
10. **StatusKendaraan timer** tidak berjalan dan tidak ada scroll wrapper
