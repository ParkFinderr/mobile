# Update 0027b

Date: 2026-06-12 07:35:00
Task: Revisi Task 0027 — Ubah Entry Point Install PWA ke Onboarding (Splash Screen)

---

# Implementation Report

## Task Summary

Revisi ini memindahkan pemicu dialog instalasi PWA otomatis dari halaman Home (pasca login) ke Splash Screen (pra-login onboarding stage). Langkah ini dilakukan untuk meningkatkan tingkat konversi instalasi PWA serta menjaga halaman utama tetap bebas dari gangguan (distraction-free).

---

## Changes Made

### Added
* Menambahkan logika pengecekan masa dismiss (7 hari) menggunakan timestamp `pwa_install_popup_last_dismiss` di `SharedPreferences` pada Splash Screen.
* Menambahkan pemicu otomatis dialog kustom (`PwaInstallDialog`/`PwaSafariInstallDialog`) pada `SplashScreenWidget` dengan callback penutupan (`onDismiss`) yang mengarah ke `WelcomePage`.

### Modified
* Mengupdate `PwaInstallDialog` dan `PwaSafariInstallDialog` untuk menyertakan tombol `[ Lanjut ke Login ]` dan `[ Install Sekarang ]` serta memproses penyimpanan timestamp 7 hari.
* Mengupdate `home_widget.dart` dengan menghapus pemicu pengecekan otomatis PWA, serta menyesuaikan pemanggilan manual dialog agar menyuplai callback penutupan yang sesuai.
* Mengupdate `splash_screen_widget.dart` untuk mengimpor dan memanggil pendeteksian serta penampilan dialog onboarding PWA.

### Removed
* Menghapus pemicu `_checkPwaInstallPopup` otomatis dari `home_widget.dart`.

---

## Files Created

```txt
docs/analysis/0027b-pwa-install-and-auto-update.md
update/0027b-pwa-install-and-auto-update.md
```

---

## Files Modified

```txt
lib/core/pwa/pwa_install_dialog.dart
lib/features/splash_screen/widget/splash_screen_widget.dart
lib/features/home/widget/home_widget.dart
```

---

## Technical Details

* **Onboarding Integration**: Dengan menempatkan pengecekan di `SplashScreenWidget`, kita memastikan pengguna langsung menyadari fitur PWA. Callback `onDismiss` memastikan alur tidak tertahan: setelah install prompt selesai (baik diterima atau ditolak) atau tombol "Lanjut ke Login" ditekan, pengguna langsung diantar ke menu utama Welcome/Login.
* **7-Day Dismissal Logic**: Menggunakan SharedPreferences untuk mencatat epoch milliseconds terakhir kali ditutup. Cek dilakukan dengan membandingkan selisih hari `< 7`.

---

## Impact Analysis

### User Experience
* Onboarding yang lebih intuitif: Pengguna mendapatkan kesempatan menginstal PWA di awal tanpa mengganggu alur kerja di dalam Dashboard Home.
* Dialog manual instalasi tetap tersedia di dashboard Home sebagai jalan alternatif jika sewaktu-waktu pengguna ingin menginstal aplikasi.

---

## Validation Checklist

* [x] Build berhasil (`Built build/web` sukses)
* [x] Tidak ada error lint/kompilasi
* [x] Tidak ada regression terhadap fitur login, booking, maupun scan
* [x] PWA Onboarding Install Popup terintegrasi di Splash Screen
* [x] Aturan Local Storage 7 hari dismissal aktif
* [x] Deteksi standalone mode aktif
* [x] Fallback Safari iOS 3-langkah terintegrasi
