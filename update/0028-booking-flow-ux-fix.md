# Update 0028

Date: 2026-06-12 08:05:00
Task: Task 0028 — Fix Booking Flow UX (Scan Redirect & User Guidance)

---

# Implementation Report

## Task Summary

Tugas ini bertujuan untuk memperbaiki alur pemesanan (booking flow) ketika pengguna belum memverifikasi tiket parkir mereka. Sebelumnya, jika pengguna mencoba membooking tanpa tiket aktif, sistem hanya menampilkan pesan kesalahan statis ("Tiket belum scan" / "Tiket belum aktif") dan berhenti (dead end).

Perbaikan yang diterapkan meliputi penambahan dialog konfirmasi kustom yang modern, spanduk status tiket interaktif pada halaman utama, panduan langkah demi langkah di halaman pemindaian tiket (Scan Page), serta pengalihan otomatis jika halaman booking diakses secara langsung.

---

## Changes Made

### Added
* Menambahkan class `NoTicketDialog` di `lib/features/public_widget/no_ticket_dialog.dart` sebagai dialog modern bertema gelap & glassmorphism yang memberi tahu pengguna tentang tiket yang belum terverifikasi dan mengarahkan mereka langsung ke halaman scan.
* Menambahkan spanduk status tiket interaktif (`_buildTicketStatusBanner`) di `lib/features/home/widget/home_widget.dart` dengan dua status:
  - **Aktif**: Menampilkan ikon centang neon cyan dengan teks `✓ Tiket Aktif`.
  - **Belum Aktif**: Menampilkan ikon peringatan merah, deskripsi, dan tombol aksi `[ Scan Tiket ]`.
* Menambahkan widget langkah demi langkah (Step 1 & Step 2) di halaman Scan (`WelcomeScanWidget`):
  - **Mobile Layout**: Ditampilkan secara ringkas di panel bawah untuk mencegah tabrakan visual dengan area pindai kamera.
  - **Web Layout**: Ditampilkan sebagai kartu detail yang mendeskripsikan langkah aktivasi sesi parkir sebelum melakukan booking.

### Modified
* Mengupdate `lib/features/home/widget/home_widget.dart` untuk memuat status tiket secara dinamis dari `ActiveTicketStorage` dan mencegah akses ke booking dengan menampilkan `NoTicketDialog`.
* Mengupdate `lib/features/welcome_scan/widget/welcome_scan_widget.dart` untuk menyertakan instruksi langkah baru bagi pengguna serta memperbarui tinggi overlay kamera mobile agar sejajar dengan tinggi panel yang baru.
* Mengupdate `lib/core/pwa/pwa_update_service_web.dart` dengan annotation `// ignore: unnecessary_null_comparison` untuk membersihkan laporan statis analyzer dari peringatan yang tidak perlu.

### Removed
* Tidak ada file yang dihapus.

---

## Files Created

```txt
lib/features/public_widget/no_ticket_dialog.dart
docs/analysis/0028-booking-flow-ux-fix.md
update/0028-booking-flow-ux-fix.md
```

---

## Files Modified

```txt
lib/features/home/widget/home_widget.dart
lib/features/welcome_scan/widget/welcome_scan_widget.dart
lib/core/pwa/pwa_update_service_web.dart
```

---

## Dependencies Added

```txt
None
```

---

## Technical Details

* **Dynamic Overlay Adjustment**: Menyesuaikan tinggi overlay kamera (dari `210` ke `265`) pada `WelcomeScanWidget` agar panel bawah yang berisi petunjuk langkah baru tidak menutupi kotak pembatas scanner (scan frame) di layar seluler.
* **Auto-Redirects**: Alur otomatis tetap dipertahankan pada `booking_widget.dart` dan `detail_booking_widget.dart` di mana `initState()` langsung memeriksa keberadaan tiket aktif. Jika kosong, pengguna langsung diarahkan ke halaman pindai tiket tanpa memicu dead-end.
* **Null Check Silence**: Menambahkan anotasi pengabaian analisis pada file service PWA web untuk memastikan output statis `flutter analyze` bersih dan siap diproduksi.

---

## Impact Analysis

### User Experience
* Menghilangkan dead-end pada alur pengguna dengan memberikan panduan yang jelas saat memesan slot tanpa tiket.
* Spanduk status di HomePage memberi pengingat visual yang kuat mengenai status parkir aktif/non-aktif pengguna.
* Alur pemindaian memiliki kejelasan operasional yang lebih baik dengan instruksi terstruktur untuk platform web maupun mobile native.

### Performance
* Penambahan elemen UI baru menggunakan widget standar Flutter yang ringan tanpa memberikan overhead kompilasi atau perlambatan rendering.

### Maintainability
* Penempatan dialog di `public_widget` memudahkan pemeliharaan kode dan penggunaan kembali di berbagai bagian aplikasi jika diperlukan di masa mendatang.

---

## Validation Checklist

* [x] Build berhasil (`Built build/web` sukses)
* [x] Berhasil menyalin hasil build web ke folder `pwa/`
* [x] Tidak ada error statis pada `flutter analyze`
* [x] Alur pengalihan ke halaman Scan berfungsi penuh
* [x] Glassmorphic dialog konfirmasi terintegrasi
* [x] Status banner interaktif di Home Dashboard terintegrasi
* [x] Panduan langkah-langkah di halaman Scan terintegrasi
