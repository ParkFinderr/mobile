# Audit & Mapping Redesign ParkFinder

Audit dilakukan 22 Juli 2026 sebelum perubahan UI. Aplikasi menggunakan arsitektur feature-based (`lib/features`), Provider sebagai state management, `AppRouter` untuk named route, dan `MockRouter` + `SharedPreferences` sebagai sumber data lokal. Tidak ada backend baru yang ditambahkan dalam redesign ini.

## Mapping screen

| Screen lama | Referensi `new-ui` | Status | Catatan |
| --- | --- | --- | --- |
| Splash | Splash Screen | Redesign | Tetap cek sesi lokal. |
| Welcome + welcome transition | Onboarding, Onboarding Tutorial 1–2 | Merge/Redesign | Tetap menuju login. |
| Login | Halaman Masuk | Redesign | Validasi dan autentikasi lokal dipertahankan. |
| Register | Halaman Daftar | Redesign | Validasi dan penyimpanan lokal dipertahankan. |
| Home | Dashboard Parkir | Redesign | Tetap memuat area dan status reservasi aktif. |
| Booking | Denah | Redesign | Menjadi daftar area/lokasi parkir. |
| Detail booking | Peta Parkir FT Unila + Konfirmasi Reservasi | Redesign | Pemilihan slot dan pembuatan reservasi tetap ada. |
| Status kendaraan | Status Parkir Aktif + Ringkasan Parkir Selesai | Redesign | Status, timer, QR/tiket, selesai dan batal tetap ada. |
| Welcome scan + scan berhasil | QR Scanner + Peringatan Salah Parkir | Redesign | Tetap validasi QR melalui mock lokal. |
| History | Riwayat Parkir | Redesign | Data history lokal dipertahankan. |
| Profile | Profil Pengguna | Redesign | Edit profil, kendaraan, preferensi, logout tetap tersedia. |
| Settings | Pengaturan | Redesign | Preferensi lokal dipertahankan. |
| Edit profile + vehicle management | Tidak ada mockup khusus | Reuse/Redesign ringan | Tetap dipertahankan karena masih berada dalam flow profil. |

## Temuan

- Routing lengkap untuk flow utama sudah ada; tidak ada route yang dihapus.
- `core/network/api_service.dart` mengarahkan operasi ke `MockRouter` ketika mock aktif; service tetap dipakai sebagai batas UI–data.
- Banyak layar lama memakai palette gelap secara hard-code. Tahap pertama redesign adalah token tema terang dan komponen bersama agar migrasi layar dapat dilakukan tanpa mengubah business logic.
