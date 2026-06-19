# Update 0025

Date: 2026-06-11 13:43:00
Task: Audit and Verify Profile Photo Upload Feature

---

# Implementation Report

## Task Summary

Tugas ini bertujuan untuk melakukan audit menyeluruh terhadap fitur upload foto profil (menggunakan endpoint backend `POST /users/profile/photo`), mendeteksi adanya bug/ketiadaan integrasi, memperbaiki masalah tersebut agar fitur upload foto profil dapat bekerja pada deployment PWA Flutter Web di Vercel, dan menyinkronkannya dengan endpoint backend ke seluruh antarmuka pengguna (UI).

---

## Changes Made

### Added
* Menambahkan package `image_picker` ke `pubspec.yaml` untuk memfasilitasi pengambilan file gambar secara lintas-platform.
* Menambahkan method `multipartPost` ke `ApiService` (`lib/core/network/api_service.dart`) untuk mendukung pengiriman file via `multipart/form-data` dengan format bytes (`Uint8List`) yang sepenuhnya kompatibel dengan Flutter Web.
* Menambahkan field `photoUrl` pada kelas model `ProfileData` (`lib/features/profil/service/profile_service.dart`) agar URL foto profil dari backend dapat dipetakan dan digunakan oleh UI.
* Menambahkan method `uploadPhoto` pada kelas `ProfileService` (`lib/features/profil/service/profile_service.dart`) untuk mengirim data gambar ke backend.

### Modified
* Mengupdate `ProfileAvatarWidget` (`lib/features/profil/widget/profile_avatar_widget.dart`) untuk menerima parameter `photoUrl` dan menggunakan `CachedNetworkImage` guna menampilkan foto dari internet dengan placeholder dan fallback error.
* Mengupdate `ProfilWidget` (`lib/features/profil/widget/profil_widget.dart`) untuk mengirim `photoUrl` ke `ProfileAvatarWidget`.
* Mengupdate `EditProfilPage` (`lib/features/profil/page/edit_profil_page.dart`) untuk:
  - Menyimpan status `_photoUrl` di dalam state.
  - Membungkus Avatar dan tombol "Ubah Foto" dengan `GestureDetector` agar dapat merespons interaksi tap.
  - Mengimplementasikan method `_pickAndUploadPhoto` untuk memilih gambar menggunakan `image_picker`, membacanya dalam bentuk array byte, lalu mengunggahnya ke backend menggunakan `ProfileService`.
  - Merender gambar profil pengguna secara dinamis menggunakan `CachedNetworkImage`.
* Mengupdate `UserHeaderWidget` (`lib/features/public_widget/user_header_widget.dart`) agar dapat menerima parameter opsional `photoUrl` dan menampilkan foto profil pengguna menggunakan `CachedNetworkImage` alih-alih ikon bawaan statis.
* Mengupdate `HomeWidget` (`lib/features/home/widget/home_widget.dart`) untuk memuat `photoUrl` pengguna dan meneruskannya ke `UserHeaderWidget` di halaman dashboard.
* Mengupdate `HistoryWidget` (`lib/features/history/widget/history_widget.dart`) untuk memuat `photoUrl` pengguna dan meneruskannya ke `UserHeaderWidget` di halaman riwayat.

### Removed
* Tidak ada file atau dependensi yang dihapus.

---

## Files Created

```txt
docs/analysis/0024-profile-photo-audit.md
update/0025-profile-photo-upload-feature.md
```

---

## Files Modified

```txt
pubspec.yaml
lib/core/network/api_service.dart
lib/features/profil/service/profile_service.dart
lib/features/profil/widget/profile_avatar_widget.dart
lib/features/profil/widget/profil_widget.dart
lib/features/profil/page/edit_profil_page.dart
lib/features/public_widget/user_header_widget.dart
lib/features/home/widget/home_widget.dart
lib/features/history/widget/history_widget.dart
```

---

## Files Removed

```txt
update/0022-profile-photo-upload-feature.md
```

---

## Dependencies Added

```txt
image_picker: ^1.2.2
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

* **Cross-Platform Compatibility**: Untuk mendukung Flutter Web secara aman, kami menghindari ketergantungan pada `dart:io` dan manipulasi file path lokal yang akan memicu runtime error `Unsupported operation`. Pemilihan file dikelola oleh `image_picker` yang mengembalikan `XFile`, dan data gambar diunggah menggunakan `http.MultipartFile.fromBytes` via byte array memory (`Uint8List`).
* **Caching & Performance**: Menggunakan library `cached_network_image` untuk melakukan caching otomatis pada browser atau media penyimpanan lokal sehingga tidak memicu download berulang kali ke server CDN Google Cloud Storage.
* **Multipart Request**: Method `multipartPost` di `ApiService` dikonfigurasi untuk menyertakan Bearer Token autentikasi di header secara aman bersamaan dengan payload `multipart/form-data`.
* **Universal UI Sync**: Dengan menyuplai `photoUrl` ke `UserHeaderWidget`, foto profil terbaru disinkronkan secara instan di seluruh layar dashboard utama (`HomeWidget`) dan layar riwayat (`HistoryWidget`).

---

## Impact Analysis

### User Experience
* Pengguna sekarang dapat memilih dan mengunggah foto profil baru dari galeri/sistem file secara langsung.
* Perubahan foto profil langsung terefleksi di UI halaman Edit Profil, Halaman Profil Utama, Dashboard, dan Halaman Riwayat setelah upload berhasil tanpa perlu reload manual atau log out.

### Performance
* Menggunakan `CachedNetworkImage` meningkatkan efisiensi load gambar dari CDN storage dan mengurangi latensi visual dengan adanya loading progress indicator.

### Maintainability
* Struktur kode yang bersih dan tersegregasi antara UI, service layer, dan network client (`ApiService`) memudahkan pelacakan jika ada kendala koneksi di masa depan.

### Scalability
* Method `multipartPost` pada `ApiService` dirancang generic, sehingga dapat digunakan kembali oleh fitur upload file lain di masa depan tanpa modifikasi ulang.

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

1. Membatasi ukuran file yang diunggah di sisi client (misalnya maksimum 5MB) untuk mencegah bandwidth waste.
2. Menambahkan fitur crop gambar sebelum proses unggah agar foto profil terpusat rapi secara bulat.
3. Menambahkan shimmer skeleton placeholder saat data profil sedang di-load pertama kali.

---

## Executive Summary

1. Mengidentifikasi bahwa fitur upload foto profil belum diintegrasikan di sisi frontend meskipun backend endpoint sudah tersedia.
2. Mengintegrasikan package `image_picker` untuk memfasilitasi pengambilan gambar lintas-platform secara aman.
3. Memperluas class `ApiService` dengan method `multipartPost` menggunakan byte streaming untuk kompatibilitas Flutter Web & PWA.
4. Menambahkan field `photoUrl` ke model `ProfileData` dan memetakan datanya dari response backend.
5. Mengimplementasikan fungsi `uploadPhoto` di `ProfileService`.
6. Memperbarui widget `ProfileAvatarWidget` agar dapat memuat foto profil secara dinamis menggunakan `CachedNetworkImage`.
7. Menghubungkan visual avatar dan tombol "Ubah Foto" di `EditProfilPage` dengan fungsionalitas unggah baru.
8. Memperbarui `UserHeaderWidget` agar merender foto profil pengguna di layar utama dan layar riwayat.
9. Memvalidasi bahwa foto profil diperbarui secara asinkron di seluruh bagian UI begitu proses upload selesai.
10. Membuat laporan audit lengkap di `/docs/analysis/0024-profile-photo-audit.md` dan arsip update di `/update/0025-profile-photo-upload-feature.md`.
