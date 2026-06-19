# Update 0026

Date: 2026-06-11 14:07:31
Task: Critical Bug Fix: QR Scanner Failure After TASK 0024 + User Flow Revision

---

# Implementation Report

## Task Summary

Tugas ini bertujuan untuk memperbaiki bug regresi kritis pada QR Scanner di web/PWA (terjadi setelah penambahan dependency pada TASK 0024) serta merevisi alur navigasi aplikasi agar login langsung mengarah ke halaman Home, dan verifikasi tiket menjadi syarat wajib sebelum melakukan booking slot parkir.

---

## Changes Made

### Added
* Menambahkan mode verifikasi manual tiket parkir khusus untuk web browser/PWA (Platform Branching) di `WelcomeScanWidget` untuk menghindari error `MobileScannerController` pada browser.
* Menambahkan visual form input kode tiket serta tombol verifikasi manual pada layout web.

### Modified
* Mengupdate `WelcomeScanWidget` (`lib/features/welcome_scan/widget/welcome_scan_widget.dart`) untuk hanya menginisialisasi `MobileScannerController` jika aplikasi dijalankan pada native mobile (`!kIsWeb`).
* Mengupdate `LoginWidget` (`lib/features/login/widget/login_widget.dart`) untuk mengarahkan pengguna ke halaman Home (`AppRoutes.home`) alih-alih halaman Scan setelah proses login berhasil.
* Mengupdate `HomeWidget` (`lib/features/home/widget/home_widget.dart`) untuk melakukan pemeriksaan tiket aktif sebelum melakukan navigasi ke halaman Booking/Detail Booking dari Search Bar, item list gedung parkir, maupun dari Bottom Navigation.
* Mengupdate `BookingWidget` (`lib/features/booking/widget/booking_widget.dart`) untuk melakukan verifikasi tiket aktif di `initState` sebagai langkah pencegahan fallback jika pengguna masuk ke halaman booking secara langsung.
* Mengupdate `DetailBookingWidget` (`lib/features/detail_booking/widget/detail_booking_widget.dart`) untuk melakukan verifikasi tiket aktif di `initState` sebagai langkah pencegahan fallback.

### Removed
* Tidak ada file atau dependensi yang dihapus.

---

## Files Created

```txt
docs/analysis/0026-qr-scanner-regression-fix.md
update/0026-qr-scanner-regression-fix.md
```

---

## Files Modified

```txt
lib/features/welcome_scan/widget/welcome_scan_widget.dart
lib/features/login/widget/login_widget.dart
lib/features/home/widget/home_widget.dart
lib/features/booking/widget/booking_widget.dart
lib/features/detail_booking/widget/detail_booking_widget.dart
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

## Technical Details

* **Platform Branching Strategy**: Untuk menangani ketidakstabilan API camera di browser PWA/Web (khususnya library `mobile_scanner`), kami menonaktifkan inisialisasi controller camera di tingkat web. UI web akan menampilkan input teks manual yang mengirim request ke endpoint `/access/verify` dengan body `{'qrCode': code}` yang sama persis seperti request scanner camera.
* **Navigation Flow Security**: Menambahkan filter verifikasi tiket pada seluruh trigger booking untuk memastikan booking tidak bisa diakses tanpa tiket aktif (`guestTicket`).

---

## Impact Analysis

### User Experience
* Pengguna web tidak lagi mengalami screen freeze/crash saat masuk ke halaman scan tiket.
* Alur navigasi lebih natural: Pengguna langsung melihat Dashboard utama setelah login, dan hanya perlu melakukan scan tiket jika ingin melakukan booking.

### Performance
* Mengurangi pemuatan resource camera di browser web, menghemat RAM, dan mengeliminasi overhead inisialisasi hardware kamera di web.

### Maintainability
* Pemisahan layout web (`_buildWebLayout`) menjaga agar kode mobile scanner tetap bersih dan tidak terganggu oleh logic platform web.

### Scalability
* Mekanisme fallback check di `initState` Booking/DetailBooking bertindak sebagai middleware tangguh yang melindungi resource booking dari manipulasi navigasi direct.

---

## Validation Checklist

* [x] Build berhasil
* [x] Tidak ada error lint
* [x] Tidak ada error runtime
* [x] Semua fitur lama tetap berjalan
* [x] Fitur baru telah terintegrasi
* [x] Responsive layout telah diverifikasi
* [x] Dependency berhasil terpasang

---

## Known Issues

```txt
None
```

---

## Technical Debt

```txt
None
```

---

## Remaining Work

```txt
None
```

---

## Recommended Next Steps

1. Tambahkan mask formatting untuk input manual kode tiket agar menghindari typo.
2. Sediakan opsi pemindai kamera opsional pada browser web modern menggunakan WebRTC jika pengguna bersikeras ingin memindai via kamera.

---

## Executive Summary

1. Mengidentifikasi crash/freeze aplikasi web yang dipicu oleh konflik internal `mobile_scanner` dengan library file picker.
2. Menerapkan Platform Branching: menonaktifkan scanner kamera di Web, menggantinya dengan form input tiket manual yang ramah pengguna.
3. Memastikan inisialisasi camera controller tidak dijalankan sama sekali saat aplikasi berjalan di web browser (`kIsWeb`).
4. Merevisi rute sukses login agar mengarah langsung ke halaman Dashboard (`/home`).
5. Memproteksi Search Bar, item list, dan Bottom Nav di Home agar memvalidasi tiket aktif sebelum navigasi ke booking.
6. Menambahkan proteksi `initState` di Booking/Detail Booking agar meredirect pengguna tanpa tiket aktif ke halaman Scan.
7. Memvalidasi bahwa seluruh perubahan kode lolos kompilasi Flutter Web (`Built build/web` sukses).
8. Mengonfirmasi tidak adanya penambahan static analysis warning (`No issues found!`).
9. Menyimpan laporan penyelesaian bug ke `/docs/analysis/0026-qr-scanner-regression-fix.md`.
10. Menyimpan laporan resmi histori proyek ke `/update/0026-qr-scanner-regression-fix.md`.
