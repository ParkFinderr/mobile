# Update 0027

Date: 2026-06-12 07:19:15
Task: Task 0027 — PWA Install Experience + Auto-Update System

---

Task 0027 — PWA Install Experience + Auto-Update System


# Implementation Report

## Task Summary

Tugas ini bertujuan untuk menambahkan pengalaman instalasi PWA kustom (Custom PWA Install Experience) dan sistem pemberitahuan pembaruan otomatis (Auto Update Notification) pada web/PWA ParkFinder, serta menyesuaikan alur pengguna agar tidak mewajibkan pemindaian tiket pasca login.

---

## Changes Made

### Added
* Menambahkan event listener `beforeinstallprompt` dan fungsi jembatan JS `triggerPWAInstall` pada `web/index.html`.
* Menambahkan deteksi update service worker melalui `updatefound` dan `statechange` di `web/index.html` untuk mengirim event `'pwa-update-ready'`.
* Menambahkan custom dialog modern bertema Dark & Glassmorphism (`PwaInstallDialog`) untuk memicu proses instalasi PWA.
* Menambahkan dialog panduan khusus perangkat Apple (`PwaSafariInstallDialog`) sebagai fallback Safari iOS.
* Menambahkan indikator status instalasi (`✓ Aplikasi Terinstal` dan `📲 Install Aplikasi`) di atas Hero Banner pada HomePage Dashboard.
* Menambahkan wrapper global `UpdateListenerWrapper` di `lib/app/app.dart` untuk memunculkan `MaterialBanner` ketika build/deploy baru terdeteksi.

### Modified
* Mengupdate `web/index.html` untuk menyertakan script pendukung instalasi dan pendeteksian update service worker.
* Mengupdate `lib/main.dart` untuk menginisialisasi `PwaInstallService` dan `PwaUpdateService` di tingkat platform web.
* Mengupdate `lib/app/app.dart` untuk menyertakan global `scaffoldMessengerKey` pada `MaterialApp` dan mendaftarkan wrapper pemantau update.
* Mengupdate `lib/features/home/widget/home_widget.dart` untuk mengintegrasikan check popup instalasi PWA otomatis sekali per sesi, menangani status dismiss di penyimpanan lokal (SharedPreferences), dan menampilkan chip aksi instalasi.

### Removed
* Tidak ada file yang dihapus.

---

## Files Created

```txt
lib/core/pwa/pwa_install_service.dart
lib/core/pwa/pwa_install_service_stub.dart
lib/core/pwa/pwa_install_service_web.dart
lib/core/pwa/pwa_update_service.dart
lib/core/pwa/pwa_update_service_stub.dart
lib/core/pwa/pwa_update_service_web.dart
lib/core/pwa/pwa_install_dialog.dart
docs/analysis/0027-pwa-install-and-auto-update.md
update/0027-pwa-install-and-auto-update.md
```

---

## Files Modified

```txt
web/index.html
lib/main.dart
lib/app/app.dart
lib/features/home/widget/home_widget.dart
```

---

## Dependencies Added

```txt
None
```

---

## Technical Details

* **Conditional Export Strategy**: PWA Service (`PwaInstallService` & `PwaUpdateService`) diimplementasikan dengan pemisahan stub & web target menggunakan `export ... if (dart.library.html) ...`. Hal ini mencegah kegagalan kompilasi (compile error) pada target mobile native (Android & iOS).
* **Global ScaffoldMessengerKey**: Menggunakan global key pada `MaterialApp` agar pemanggilan `showMaterialBanner` untuk notifikasi update dapat dilakukan dari tingkat wrapper global tanpa ketergantungan pada context spesifik di tingkat halaman.
* **Auto-Update Lifecycle**: Ketika browser mendeteksi Service Worker baru dalam status `installed`, system akan langsung mengirim CustomEvent ke window, ditangkap oleh Flutter PWA Stream, dan memicu MaterialBanner global. Menekan tombol "PERBARUI" akan me-reload halaman untuk mengaktifkan service worker baru secara instan.

---

## Impact Analysis

### User Experience
* Meningkatkan awareness instalasi PWA dengan dialog modern bertema gelap tanpa mengganggu UX dasar aplikasi.
* Pengguna Safari iOS mendapatkan panduan langkah demi langkah yang intuitif untuk menambahkan aplikasi ke Home Screen.
* Pengguna selalu menggunakan versi terbaru aplikasi yang di-deploy ke Vercel tanpa perlu melakukan hard reload manual.

### Performance
* Service baru diisolasi sepenuhnya dan hanya aktif di platform web browser, tanpa ada overhead kinerja pada native mobile build.

### Maintainability
* Pemisahan file platform-specific stub & web menjaga kebersihan kode dan meminimalkan keterikatan platform.

---

## Validation Checklist

* [x] Build berhasil (`Built build/web` sukses)
* [x] Tidak ada error lint/kompilasi
* [x] Tidak ada error runtime
* [x] Semua fitur lama tetap berjalan
* [x] Fitur baru telah terintegrasi
* [x] Responsive layout telah diverifikasi
* [x] PWA Custom Install Popup terintegrasi
* [x] Safari iOS Fallback terintegrasi
* [x] Status indicator terintegrasi
* [x] Auto Update global banner terintegrasi
