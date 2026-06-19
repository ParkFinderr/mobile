# ParkFinder — Mobile App (Flutter) + PWA

## Deskripsi Project

**ParkFinder** adalah platform manajemen parkir yang memiliki **3 versi frontend**:

| Versi | Teknologi | Target Pengguna |
|-------|-----------|-----------------|
| **Mobile App (Flutter)** → juga sebagai **PWA** | Flutter (Dart) | **WAJIB LOGIN** — tidak ada guest, semua fitur untuk user terdaftar |
| Web User (Guest) | React + Vite | **TANPA LOGIN** — pengguna tamu murni, scan & booking instan |
| Web Admin | _(diabaikan)_ | Admin panel |
| Web QR Generator | _(diabaikan)_ | Generate QR code |

### Yang Akan Dijelaskan di Sini: **Mobile App (Flutter)** + **PWA**

Aplikasi **mobile/PWA** ini adalah versi **personal** dengan **WAJIB LOGIN**. Tidak ada mode guest/tamu — setiap pengguna harus melewati registrasi & login untuk mengakses seluruh fitur. Cocok untuk pengguna yang sering parkir dan butuh personalisasi (profil, kendaraan, notifikasi, riwayat, timer parkir aktif).

Sedangkan **Web User (Guest)** adalah versi **tamu tanpa login** — cocok untuk pengguna sekali pakai yang hanya butuh scan & booking cepat tanpa membuat akun.

### Target Platform
- Android (APK), iOS, Web (PWA), Linux, macOS, Windows

### Backend API
- Base URL: `https://backend-api-services-173368161554.asia-southeast2.run.app`
- Assets (gambar, ilustrasi): Google Cloud Storage `https://storage.googleapis.com/parkfinderbucket`

---

### Perbandingan Fitur: Web User (Guest) vs Mobile/PWA (User)

| Fitur | Web User (Guest) | Mobile/PWA (User) | Keterangan |
|-------|:---:|:---:|------------|
| Landing / Marketing | ✅ | ❌ | Web user punya halaman landing dengan fitur & stats |
| Scan QR Tiket | ✅ live camera + input manual | ✅ live camera | Sama-sama pakai `POST /access/verify` |
| Lihat Daftar Parkir | ✅ `GET /areas` | ✅ `GET /areas` | Sama |
| Pilih Slot per Lantai | ✅ layout 2 kolom + road | ✅ peta slot per lantai | Mobile lebih visual |
| Booking / Reservasi | ✅ `POST /reservations` | ✅ `POST /reservations` | Sama |
| Tukar Slot (Swap) | ✅ `PATCH /reservations/{id}/swap` | ❌ Belum ada | Web user lebih lengkap |
| Checkout / Keluar | ✅ `POST /access/cancelTicket` | ❌ Belum ada | |
| Riwayat Booking | ✅ lokal (localStorage) | ⚠️ hardcoded | Keduanya belum real dari API |
| Login / Register | ❌ | ✅ `POST /auth/login` & `/register` | **Pembeda utama** |
| Profil Pengguna | ❌ | ✅ `GET /users/profile` | |
| Edit Profil | ❌ | ⚠️ form saja, belum panggil API | |
| Kendaraan | ❌ | ✅ `GET /users/vehicles` | |
| Pengaturan (notif, tema) | ❌ | ✅ Toggle switches | |
| Timer Parkir Aktif | ❌ | ⚠️ ada UI tapi timer tidak jalan | |
| Notifikasi | ❌ | ✅ Pengaturan notifikasi (5 jenis) | |
| 3D Visualisasi | ✅ React Three Fiber | ❌ | |
| Download App CTA | ✅ landing page | ❌ | |

**Kesimpulan:** Mobile/PWA memiliki **14 fitur** vs Web User **9 fitur**. Web User unggul di swap & checkout (belum diimplementasi di mobile). Mobile unggul di personalisasi (auth, profil, kendaraan, notifikasi, timer).

---

## Struktur Folder

```
lib/
  main.dart                     # Entry point + DevicePreview
  app/
    app.dart                    # MaterialApp, tema, routing
    app_routes.dart             # Semua route path + onGenerateRoute
  core/
    network/
      api_service.dart          # HTTP client (GET/POST/PUT/PATCH/DELETE), JWT via SharedPreferences
    theme/
      app_colors.dart           # 55+ warna & gradient
      app_text_styles.dart      # 12+ style teks (Poppins)
  features/
    <feature>/
      page/                     # Thin StatelessWidget wrapper
      widget/                   # StatefulWidget composer + UI
      service/                  # API service layer
```

---

## Feature & Status

| No | Route | Screen | Status | Catatan |
|----|-------|--------|--------|---------|
| 1 | `/` | SplashScreenPage | ✅ Selesai | Animated logo splash |
| 2 | `/welcome` | WelcomePage | ✅ Selesai | Branding + tombol Mulai |
| 3 | `/welcome-transition` | WelcomeTransitionPage | ✅ Selesai | Fade-in bg, auto-nav ke login |
| 4 | `/login` | LoginPage | ✅ Selesai | Form email/password, `POST /auth/login` |
| 5 | `/register` | RegisterPage | ✅ Selesai | Form lengkap, `POST /auth/register` |
| 6 | `/welcome-scan` | WelcomeScanPage | ✅ Selesai | Live scanner barcode |
| 7 | `/animasi-scan` | AnimasiScanPage | ⚠️ Perlu perbaikan | Data statis (3 item hardcoded) |
| 8 | `/halaman-scan` | HalamanScanPage | ⚠️ Issue API | `POST /access/verify` — lihat catatan |
| 9 | `/scan-berhasil` | ScanBerhasilPage | ⚠️ Perlu perbaikan | Ticket code **hardcoded**, belum dari hasil scan |
| 10 | `/home` | HomePage | ⚠️ Perlu perbaikan | List parkir masih **3 item hardcoded** |
| 11 | `/status-kendaraan` | StatusKendaraanPage | ⚠️ Perlu perbaikan | Timer **tidak berjalan** (elapsed time stuck) |
| 12 | `/tutor-popup` | TutorPopupPage | ❓ Tidak terpakai | Route ada tapi tidak dipanggil dari main flow |
| 13 | `/booking` | BookingPage | ✅ Selesai | `GET /areas`, search list |
| 14 | `/detail-booking` | DetailBookingPage | ✅ Selesai | Peta slot per lantai, `POST /reservations` |
| 15 | `/history` | HistoryPage | ⚠️ Perlu perbaikan | 8 item **hardcoded**, data tidak real |
| 16 | `/profil` | ProfilPage | ✅ Selesai | Data real dari API, stats, settings links |
| 17 | `/edit-profil` | EditProfilPage | ⚠️ Perlu perbaikan | Update tidak panggil API (hanya pop) |
| 18 | `/pengaturan` | PengaturanPage | ✅ Selesai | Toggle notifikasi, tema |

**Keterangan Status:**
- ✅ Selesai — fitur berfungsi dengan integrasi API
- ⚠️ Perlu perbaikan — ada issue / masih pake data statis / logic belum benar
- ❓ Tidak terpakai — kode ada tapi tidak dijalankan

---

## Arsitektur

- **State Management**: ❌ Belum ada — masih pakai `setState()` + `StatefulWidget`
- **DI / IoC**: ❌ Belum ada — service di-instantiate langsung (`BookingService()`)
- **ViewModel/Repository**: ❌ Belum ada — code comments bilang "akan digantikan ViewModel/Repository di fase berikutnya"
- **Local Database**: ❌ Belum ada — hanya `SharedPreferences` untuk JWT token
- **Testing**: ❌ 1 file test (`widget_test.dart`) kemungkinan **gagal** karena expect text "SplashScreen" yang tidak ada
- **Navigation**: `Navigator.pushNamed` / `pushReplacementNamed` — manual routing

---

## API Endpoints Terintegrasi

| Method | Endpoint | Auth | Feature |
|--------|----------|------|---------|
| POST | `/auth/login` | ❌ | Login |
| POST | `/auth/register` | ❌ | Register |
| POST | `/auth/logout` | ✅ | Logout |
| GET | `/users/profile` | ✅ | Profil |
| GET | `/users/vehicles` | ✅ | Kendaraan |
| GET | `/areas` | ✅ | Daftar parkir |
| GET | `/areas/{id}/slots` | ✅ | Slot per area |
| POST | `/reservations` | ✅ | Booking slot |
| POST | `/access/verify` | ✅ | Verifikasi tiket |

---

## Issue / Technical Debt

1. **API Contract Mismatch** (`scan.md`): Backend `POST /access/verify` menerima `qrCode`, tapi mobile mengirim `ticketId`. Perlu diselaraskan.
2. **No State Management**: Semua state pakai `setState()` — rawan bug dan sulit di-scale.
3. **No Error Handling**: Try/catch minimal, tidak ada user-friendly error message.
4. **No Loading States**: Sebagian besar screen tidak punya shimmer/skeleton loading.
5. **Hardcoded Data**: Home, History, AnimasiScan, ScanBerhasil masih pakai dummy data.
6. **Timer Tidak Berjalan**: StatusKendaraanPage tidak increment timer.
7. **Edit Profile Tidak Save**: Form edit profil hanya pop tanpa panggil API.
8. **Test Rusak**: 1 test yang ada expect widget text yang tidak ada di aplikasi.
9. **Tidak Terpakai**: Route `/tutor-popup` ada tapi tidak digunakan.
10. **Duplikasi Tutorial**: `TutorPopupPage` dan tutorial di `HomePage` adalah 2 implementasi berbeda untuk fitur yang sama.

---

## PWA Architecture (Flutter Web → PWA)

### Target
Aplikasi ini juga akan dijadikan **Progressive Web App (PWA)** melalui target web Flutter. Saat ini `web/` sudah ada dengan konfigurasi dasar (manifest, icons).

### Status Web Saat Ini
| Komponen | Status | Catatan |
|----------|--------|---------|
| `web/manifest.json` | ⚠️ Default | Nama masih "frontmob", deskripsi default, warna masih `#0175C2` (bukan tema app) |
| `web/index.html` | ⚠️ Default | Meta tags masih "A new Flutter project.", tidak ada service worker registration |
| `web/icons/` | ⚠️ Default | 4 icon default Flutter, belum pakai logo ParkFinder |
| Service Worker | ❌ Belum | Flutter build akan generate `flutter_service_worker.js`, tapi belum ada custom strategy |
| Offline Support | ❌ Belum | Tidak ada caching custom atau offline fallback |
| Responsive Layout | ⚠️ Sebagian | Ada `MediaQuery.of(context)` di beberapa screen, tapi belum ada `LayoutBuilder` untuk breakpoint web |

### Arsitektur PWA — Layer Diagram

```
flutter build web
       │
       ▼
   ┌──────────────────────────────────────────────┐
   │              CDN / Hosting                    │
   │  (Firebase / Cloudflare / Vercel / Nginx)     │
   └──────────┬───────────────────────────────────┘
              │ HTTP/2 + HTTPS (wajib)
     ┌────────┴────────────┐
     │                     │
     ▼                     ▼
  index.html          flutter_service_worker.js
  manifest.json       (auto-generated by Flutter)
  flutter.js
  main.dart.js
  assets/*
     │                     │
     └────────┬────────────┘
              │
     ┌────────┴──────────────────────────────────┐
     │         Browser / PWA Shell               │
     │  - Install prompt (manifest)              │
     │  - Standalone mode (display: standalone)  │
     │  - Offline app shell (service worker)     │
     │  - Background sync (future)               │
     └───────────────────────────────────────────┘
              │
     ┌────────┴──────────────────────────────────┐
     │         Flutter App (CanvasKit / HTML)     │
     │  - Platform detection (kIsWeb)             │
     │  - Adaptive UI (mobile vs desktop web)     │
     │  - Camera: mobile_scanner (WebRTC)         │
     │  - Storage: SharedPreferences (localStorage)│
     └───────────────────────────────────────────┘
              │
     ┌────────┴──────────────────────────────────┐
     │         Backend REST API                   │
     │  baseUrl (production)                      │
     │  Endpoints: /auth, /users, /areas, ...     │
     └───────────────────────────────────────────┘
```

### PWA Checklist & Rencana Implementasi

| No | Item | Prioritas | Detail |
|----|------|-----------|--------|
| 1 | **Update Manifest** | Tinggi | Ganti `name: "ParkFinder"`, `short_name: "ParkFinder"`, `description`, `theme_color: #00D2FF`, `background_color: #0D1628` |
| 2 | **Update Icons** | Tinggi | Ganti icon default Flutter dengan logo ParkFinder (192, 512, maskable) |
| 3 | **Service Worker Registration** | Sedang | Register `flutter_service_worker.js` di `index.html` dengan scope yang benar |
| 4 | **Offline Fallback Page** | Rendah | Tampilkan halaman "Tidak ada koneksi" saat offline (gunakan `navigator.onLine` atau package `connectivity_plus`) |
| 5 | **API Response Caching** | Rendah | Cache response GET (`/areas`, `/users/profile`) di Cache Storage untuk akses offline terbatas |
| 6 | **Responsive Layout** | Sedang | Tambahkan `LayoutBuilder` di screen utama (Home, Booking, History) untuk breakpoint web (> 768px → grid/list multi-kolom) |
| 7 | **Platform Branching** | Sedang | Sembunyikan fitur scanner (mobile_scanner) di web — ganti dengan input kode manual atau redirect ke web user |
| 8 | **Update Meta Tags** | Sedang | `index.html`: update description, apple-mobile-web-app-title, Open Graph tags |
| 9 | **HTTPS Wajib** | Tinggi | Pastikan deployment menggunakan HTTPS (wajib untuk service worker, camera API, PWA install) |
| 10 | **Build Optimization** | Rendah | Gunakan `flutter build web --web-renderer canvaskit` untuk rendering konsisten; optimasi asset tree shaking |

### Platform Branching Strategy

Untuk mengakomodasi PWA (web) tanpa merusak pengalaman mobile:

```
lib/
  core/
    platform/
      platform_helper.dart       # kIsWeb + custom feature flags
      responsive_helper.dart     # Breakpoints (mobile < 600, tablet 600-1024, desktop > 1024)

  features/
    <feature>/
      page/                      # Tetap StatelessWidget, inject dependencies
      widget/
        mobile/                  # Widget spesifik mobile (jika berbeda)
        desktop/                 # Widget spesifik web/desktop (jika berbeda)
        shared/                  # Widget yang digunakan bersama
```

Contoh branching yang diperlukan:

- **Scanner (halaman-scan)**: Di mobile → `mobile_scanner` live kamera. Di web → sembunyikan menu scan, redirect ke web-user scan atau input kode manual
- **Bottom Navigation**: Di mobile → bottom nav bar. Di web → sidebar navigasi (opsional, untuk layar lebar)
- **Booking Map**: Di mobile → scroll vertikal. Di web → grid multi-kolom dengan lebih banyak informasi per slot

### Dependencies yang Akan Ditambahkan (Roadmap)

| Package | Untuk |
|---------|-------|
| `connectivity_plus` | Deteksi status online/offline |
| `url_launcher` | Buka link external / call / email |
| `universal_platform` | Deteksi platform yang lebih granular (opsional) |

### Build & Deploy PWA

```bash
# Build production
flutter build web --web-renderer canvaskit --release

# Output di: build/web/ → pindahkan/rename ke: pwa/
# Isi folder pwa/:
#   pwa/
#     index.html
#     manifest.json
#     flutter.js
#     main.dart.js
#     assets/
#     icons/

# Deploy isi folder pwa/ ke hosting statis (Firebase / Vercel / Cloudflare / Nginx)
# Pastikan redirect fallback ke index.html untuk SPA routing
```

**Konfigurasi Nginx (contoh):**
```nginx
location / {
  try_files $uri $uri/ /index.html;
}
```

**Konfigurasi Firebase Hosting:**
```json
{
  "hosting": {
    "public": "build/web",
    "rewrites": [{ "source": "**", "destination": "/index.html" }]
  }
}
```

---

## Environment

- **Flutter SDK**: `>=3.1.4 <4.0.0`
- **Dependencies utama**: `mobile_scanner`, `cached_network_image`, `google_fonts`, `shared_preferences`, `http`, `device_preview`
- **Dev**: `flutter_lints`
