# Update 0020

Date: 2026-06-10 18:18:50
Task: History API Integration

---

# Implementation Report

## Task Summary

Menghapus data dummy/hardcoded pada fitur History dan mengintegrasikan halaman `HistoryPage` dengan data riwayat reservasi riil dari backend via API.

---

## Changes Made

### Added

* Model riil untuk parsing riwayat reservasi: [reservation_history.dart](file:///workspaces/mobile-front/lib/features/history/model/reservation_history.dart)
* Service untuk fetch data dari backend: [history_service.dart](file:///workspaces/mobile-front/lib/features/history/service/history_service.dart)

### Modified

* [profile_service.dart](file:///workspaces/mobile-front/lib/features/profil/service/profile_service.dart): Menambahkan properti `userId` pada `ProfileData` dan mapping dari json.
* [history_card_widget.dart](file:///workspaces/mobile-front/lib/features/history/widget/history_card_widget.dart): Menambahkan status parameter dan rendering badge status parkir berwarna dinamis (`pending`, `active`, `completed`, `cancelled`, `expired`).
* [history_widget.dart](file:///workspaces/mobile-front/lib/features/history/widget/history_widget.dart):
  * Melakukan load profil secara asinkron untuk memperoleh `userId`.
  * Melakukan load riwayat reservasi via `HistoryService` dan data area via `BookingService` secara paralel (`Future.wait`) untuk me-resolve `areaId` menjadi nama lokasi parkir yang ramah pengguna.
  * Mengatur state loading (indikator progres), empty (CTA redirect ke halaman booking), dan error (tombol retry).
  * Memformat timestamp ISO UTC dari backend menjadi format waktu (`HH:mm`) dan tanggal berbahasa Indonesia (`DD Bulan YYYY`) lokal.
* [login_widget.dart](file:///workspaces/mobile-front/lib/features/login/widget/login_widget.dart): Menghapus deklarasi variabel `size` yang tidak digunakan untuk menghilangkan warning saat analisis.

### Removed

* Data dummy/hardcoded sebanyak 8 item lama di `HistoryWidget`.

---

## Files Created

```txt
lib/features/history/model/reservation_history.dart
lib/features/history/service/history_service.dart
```

---

## Files Modified

```txt
lib/features/profil/service/profile_service.dart
lib/features/history/widget/history_card_widget.dart
lib/features/history/widget/history_widget.dart
lib/features/login/widget/login_widget.dart
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

* **Endpoint Discovery**:
  * `GET /reservations` -> 404 HTML (Tidak ada)
  * `GET /reservations/history` -> Memeriksa tiket aktif (Bukan list riwayat)
  * `GET /reservations/my` -> Memeriksa tiket aktif (Bukan list riwayat)
  * `GET /users/reservations` -> 403 Forbidden (Hanya Super Admin)
  * `GET /users/{userId}/reservations` -> **200 OK (Endpoint Riil Riwayat User)**
* **Arsitektur & Pola**: Menggunakan pola model-service terpisah. State management di-handle via `setState` pada widget composer `HistoryWidget` dengan conditional rendering untuk state-state aplikasi.
* **Resolusi ID Area**: Karena riwayat reservasi hanya menyimpan `areaId`, aplikasi memanggil `BookingService.getAreas()` secara paralel dengan `HistoryService.getHistory()` dan memetakan `areaId` ke `areaName` secara lokal di memori agar UI tetap menampilkan nama tempat parkir riil (seperti "Jurusan Teknik Elektro Unila").
* **Analisis Kode**: Analisis statis bersih dari error dan warning (`flutter analyze` = 0 errors & 0 warnings).

---

## Impact Analysis

### User Experience

* Pengguna kini dapat melihat riwayat reservasi riil mereka sendiri secara dinamis.
* Halaman memproses indikasi loading dengan spinner, penanganan galat koneksi dengan tombol coba lagi, serta petunjuk halaman kosong yang informatif apabila belum pernah melakukan parkir.
* Setiap kartu menunjukkan badge berwarna yang sesuai dengan status parkir saat ini (`pending`, `active`, `completed`, `cancelled`, dll).

### Performance

* API dipanggil secara efisien memanfaatkan `Future.wait` untuk mempercepat pemuatan asinkron paralel.

### Maintainability

* Kode terpisah bersih dalam file model dan service mandiri. Model memetakan langsung kontrak API yang sesungguhnya.

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

1. Buat halaman detail reservasi untuk melengkapi flow riwayat parkir apabila pengguna ingin melihat info struk lengkap/QR Code tiket lama.

---

## Executive Summary

1. **Discovery Endpoint**: Melakukan audit lengkap terhadap endpoint reservasi dan menemukan bahwa `GET /users/{userId}/reservations` adalah satu-satunya endpoint resmi untuk riwayat reservasi milik user.
2. **Model Baru**: Membuat model `ReservationHistory` dan `ReservationTimestamps` sesuai dengan format respons asli backend tanpa properti fiktif.
3. **Peningkatan ProfileData**: Menambahkan pembacaan `userId` pada respons `/users/profile` untuk mendukung dinamisasi endpoint riwayat.
4. **Pemusnahan Data Dummy**: Menghapus seluruh 8 baris data dummy statis dalam `HistoryWidget`.
5. **Integrasi Service**: Membuat kelas `HistoryService` untuk mengkonsumsi API riwayat dengan otentikasi Bearer JWT Token.
6. **State UI Komplet**: Mengimplementasikan visual state Loading, Empty (dengan tombol CTA ke halaman booking), dan Error (dengan retry button).
7. **Badge Status Dinamis**: Menambahkan status badge berwarna di kartu riwayat: Jingga (pending), Hijau (active/completed), Merah (cancelled), Kuning (claimed/expired).
8. **Resolusi Area**: Menggunakan pemetaan asinkron paralel untuk me-resolve kode area parkir menjadi nama area deskriptif di frontend.
9. **Kepatuhan Analisis Lint**: Memperbaiki kode `login_widget.dart` dengan membuang variabel mati `size` sehingga hasil audit analisis Flutter menghasilkan `0 errors` dan `0 warnings`.
10. **Arsip Update Terjaga**: Membuat dokumen `0020-history-api-integration.md` secara teratur tanpa mengganggu riwayat pembaruan yang lama.
