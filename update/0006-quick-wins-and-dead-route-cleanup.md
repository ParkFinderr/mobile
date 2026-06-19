# Update 0006

Date: 2026-06-10
Task: Quick Wins Implementation & Dead Route Cleanup

---

# Implementation Report

## Task Summary

Mengimplementasikan Option 1 (Quick Wins) dari laporan 0005 dan memverifikasi ulang kontradiksi flow ScanBerhasil antara laporan 0003 dan 0005.

Quick Wins yang diidentifikasi di laporan 0005:
1. Fix timer di StatusKendaraanPage
2. Greeting dinamis dari DateTime.now().hour
3. Load profile data ke EditProfilPage dari ProfileService
4. Fetch real profile data untuk UserHeaderWidget
5. Hapus dead routes
6. Fix ScanService kirim qrCode (bukan ticketId)

Selain itu, dilakukan verifikasi kontradiksi ScanBerhasil antara report 0003 (active) dan 0005 (dead).

---

## Verifikasi ScanBerhasil

**Temuan**: Route `/scan-berhasil` adalah **ACTIVE**. Dipanggil dari `welcome_scan_widget.dart:55` via `Navigator.pushReplacementNamed(context, AppRoutes.scanBerhasil)`. Route `/welcome-scan` sendiri adalah route aktif yang digunakan di flow login.

**Kesimpulan**: Report 0003 ✅ benar (active via WelcomeScan). Report 0005 ❌ keliru (label "Dead" tidak akurat). Report 0005 mungkin menganggap ScanBerhasil dead karena parent `/halaman-scan` adalah dead route, tetapi lupa bahwa ada caller lain dari `/welcome-scan` yang masih aktif.

---

## Quick Wins — Status Verifikasi

| # | Quick Win | Status | Keterangan |
|---|-----------|--------|------------|
| 1 | Timer StatusKendaraanPage | ✅ Already Done | `Timer.periodic(1s)` sudah ada, `_seconds` ter-increment |
| 2 | Greeting dinamis | ✅ Already Done | `greetingFromHour()` sudah dipanggil di Home & History |
| 3 | EditProfil load profile | ✅ Already Done | `_loadProfile()` panggil `ProfileService().getProfile()` + `getVehicles()` |
| 4 | UserHeader real data | ✅ Already Done | `ProfileService().getProfile()` dipanggil di Home & History |
| 5 | Hapus dead routes | ✅ **Dikerjakan** | 3 folder fitur dihapus + routing dibersihkan |
| 6 | ScanService qrCode | ✅ Already Done | Body sudah `{'qrCode': qrCode}` sesuai backend contract |

---

## Changes Made

### Added

* None

### Modified

* `lib/app/app_routes.dart` — Dihapus 3 import, 3 route constants, dan 3 route case untuk dead routes

### Removed

* 3 dead route feature folders beserta seluruh isinya
* Route constants dan case handler dari `app_routes.dart`

---

## Files Created

```txt
update/0006-quick-wins-and-dead-route-cleanup.md
```

---

## Files Modified

```txt
lib/app/app_routes.dart
```

---

## Files Removed

```txt
lib/features/animasi_scan/page/animasi_scan_page.dart
lib/features/animasi_scan/widget/animasi_scan_widget.dart
lib/features/animasi_scan/widget/scan_preview_container_widget.dart
lib/features/animasi_scan/widget/scan_preview_content_widget.dart
lib/features/animasi_scan/widget/scan_step_indicator_widget.dart
lib/features/animasi_scan/widget/scan_step_info_widget.dart
lib/features/halaman_scan/page/halaman_scan_page.dart
lib/features/halaman_scan/widget/halaman_scan_widget.dart
lib/features/halaman_scan/service/scan_service.dart
lib/features/tutor_popup/page/tutor_popup_page.dart
lib/features/tutor_popup/widget/tutor_popup_widget.dart
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

3 folder fitur dihapus:

```txt
lib/features/
├── animasi_scan/          ← HAPUS (6 file)
├── halaman_scan/          ← HAPUS (3 file)
└── tutor_popup/           ← HAPUS (2 file)
```

---

## Technical Details

### 1. Dead Route Cleanup

**Latar belakang**: Report 0003 mengidentifikasi 3 route yang tidak pernah dipanggil:
- `/animasi-scan` — Tidak ada `Navigator.pushNamed` ke route ini di seluruh codebase
- `/halaman-scan` — Hanya dipanggil dari `/animasi-scan` (dead parent) → recursively dead
- `/tutor-popup` — Tidak ada `Navigator.pushNamed` ke route ini; halaman hanya defines navigasi *keluar*

**Perubahan di `app_routes.dart`**:
- 3 imports dihapus (line 3, 5, 17)
- 3 route constants dihapus: `animasiScan`, `halamanScan`, `tutorPopup`
- 3 case di `onGenerateRoute` dihapus
- Route constant untuk `scanBerhasil`, `home` tetap dipertahankan

### 2. Quick Wins — Codebase Audit

Setelah dilakukan audit pada kode aktual, ditemukan bahwa 5 dari 6 Quick Wins sudah terimplementasi:

1. **Timer**: `status_kendaraan_page.dart:32-34` — `Timer.periodic(const Duration(seconds: 1), ...)` sudah aktif
2. **Greeting**: `home_widget.dart:46` dan `history_widget.dart:55` — memanggil `greetingFromHour(context)` dari `core/utils/date_utils.dart`
3. **EditProfil**: `edit_profil_page.dart:28-43` — `_loadProfile()` fetch dari `ProfileService`, dan `_saveProfile()` panggil `PUT /users/profile`
4. **UserHeader**: Kedua screen sudah fetch `ProfileService().getProfile()` di `initState`
5. **ScanService**: `scan_service.dart:10` — body sudah `{'qrCode': qrCode}`

Ini menunjukkan bahwa laporan 0005 ditulis berdasarkan snapshot kode yang lebih lama, dan beberapa perbaikan sudah dilakukan di task 0004 (home-api-integration).

---

## Impact Analysis

### User Experience

- ✅ Tidak ada perubahan UX untuk fitur yang masih digunakan
- ✅ Dead route tidak lagi membebani daftar route yang tidak berguna
- ❌ Jika ada deep link ke route yang dihapus, akan tampil "Halaman tidak ditemukan"

### Performance

- Tidak ada dampak signifikan — hanya 11 file Dart dan 3 route handler dihapus
- Binary size berkurang sedikit (dead code removal)

### Maintainability

- ✅ Codebase lebih bersih tanpa dead code
- ✅ Developer tidak perlu bingung dengan route yang tidak terpakai
- ✅ `app_routes.dart` lebih ringkas

### Scalability

- ✅ Tidak ada dampak negatif
- ✅ Dead route removal memudahkan navigasi kode untuk pengembangan selanjutnya

---

## Validation Checklist

* [x] Build berhasil — `flutter analyze` 0 errors
* [x] Tidak ada error lint — 0 errors, hanya pre-existing info-level issues
* [x] Tidak ada error runtime — penghapusan hanya pada route yang tidak pernah dipanggil
* [x] Semua fitur lama tetap berjalan — tidak ada fitur aktif yang tersentuh
* [x] Fitur baru telah terintegrasi — N/A (cleanup only)
* [x] Tidak ada referensi tersisa ke file yang dihapus — dikonfirmasi via grep

---

## Known Issues

1. Jika ada deep link eksternal ke `/animasi-scan`, `/halaman-scan`, atau `/tutor-popup`, akan tampil halaman "Halaman tidak ditemukan". Ini acceptable karena route tersebut tidak pernah digunakan.
2. 5 dari 6 Quick Wins sudah diimplementasi sebelum task ini — laporan 0005 mungkin perlu diperbarui statusnya.

---

## Technical Debt

1. `ScanService` masih ada (sebagai file yang dihapus). Jika scan flow melalui `WelcomeScan → ScanBerhasil` membutuhkan verifikasi API, perlu service baru atau integrasi ulang.
2. `EditProfilPage` masih punya `_showSuccess()` yang hanya pop tanpa refresh data di halaman profil.

---

## Remaining Work

1. Implementasi API untuk area detail `GET /areas/{id}` — agar title DetailBooking dinamis
2. Implementasi history dari API `GET /reservations` — ganti 8 item hardcoded
3. Implementasi active session API — ganti data hardcoded di StatusKendaraanPage
4. Integrasi scan result ke ScanBerhasilPage — ticket code masih hardcoded `'TXT-20260302-0054'`

---

## Recommended Next Steps

1. **Home data API** — HomeWidget sudah fetch `GET /areas` tapi masih ada data hardcoded di status cards dan EndSessionDialog
2. **History API integration** — Cari endpoint history (`GET /reservations` atau `GET /reservations/history`) dan ganti data hardcoded
3. **DetailBooking dinamis** — Fetch `GET /areas/{id}` untuk title dan floor tabs yang dinamis
4. **StatusKendaraan real data** — Integrasikan dengan active session API

---

## Executive Summary

1. **ScanBerhasil verified**: Route ACTIVE via WelcomeScan — report 0003 benar, 0005 keliru
2. **Quick Wins audit**: 5/6 sudah terimplementasi di kode saat ini (timer, greeting, EditProfil API, UserHeader data, ScanService contract)
3. **Dead route cleanup**: 3 route + 11 file dihapus — `animasi-scan`, `halaman-scan`, `tutor-popup`
4. **app_routes.dart**: Bersih dari dead imports, constants, dan case handler
5. **Build**: `flutter analyze` — 0 errors, 0 warnings dari perubahan
6. **Tidak ada fitur aktif yang terganggu** — hanya dead code yang dihapus
7. **ScanService dihapus** — karena merupakan bagian dari dead route `halaman-scan`. Jika scan flow butuh API verification, perlu implementasi baru
8. **Laporan 0005 outdated**: Beberapa item di quick wins sudah diperbaiki di task sebelumnya (0004)
