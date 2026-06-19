# Update 0014 — Post-Integration Audit

## Tanggal
2026-06-10

## Status
✅ Audit Selesai — Tanpa perubahan kode

---

## Feature Status Table

| Feature | Screen | Status | Notes |
|---------|--------|--------|-------|
| Splash + Welcome | Splash → Welcome → WelcomeTransition | **Fully Real** | Animated logo, branding, auto-nav. No dummy data. |
| Login | LoginPage | **Fully Real** | `POST /auth/login` real API, form validation, error handling. |
| Register | RegisterPage | **Blocked Backend** | `POST /auth/register` exists, but plate validation always fails with "Plat Nomor wajib diisi." regardless of input. **Backend bug.** |
| Scan QR | WelcomeScanPage | **Fully Real** | Live camera, `POST /access/verify` real API, loading state, error → retry. Saves to `ActiveTicketStorage`. |
| Scan Result | ScanBerhasilPage | **Partially Real** | Ticket code + status dari API (real). Namun: `vehicleType`, `areaId`, `areaName`, `bindingId` tidak ditampilkan. Tombol "Lanjut Booking" salah navigasi ke `/home` (bukan `/booking`). Double fallback `'Aktif'` selalu muncul. |
| Home — Parking List | HomePage | **Fully Real** | `GET /areas` real API, loading/error/empty states, areaId passed correctly. ✅ |
| Home — Status Cards | HomePage | **Dummy** | 3 cards (`Status Tiket Aktif`, `Status Booking`, `Parkir Aktif`) — semua data hardcoded mock (`01:43:02`, `15 menit`, `A4 – Lantai 1`). Tidak ada API call. |
| Home — Tutorial | HomePage (overlay) | **Dummy** | 4 step tutorial dengan gambar, judul, deskripsi hardcoded. Tidak bisa diubah tanpa rebuild. |
| Booking List | BookingPage | **Fully Real** | `GET /areas` real API, search filter, occupancy calc. |
| Detail Booking — Slots | DetailBookingPage | **Fully Real** | `GET /areas/{id}/slots` real API, slot map visual. |
| Detail Booking — Area Info | DetailBookingPage | **Dummy** | `'Teknik Elektro Universitas Lampung'`, `'Zona A - Lantai 1'` — semua hardcoded. Tidak pakai `GET /areas/{id}`. |
| Detail Booking — Floor Tabs | DetailBookingPage | **Dummy** | `['Semua', 'Lantai 1', 'Lantai 2']` hardcoded. Tidak filter data. Cosmetic only. |
| Detail Booking — Booking Submit | DetailBookingPage | **Partially Real** | `POST /reservations` real API, ticketId dari `ActiveTicketStorage` real. Tapi: tidak ada error UI untuk no-ticket, fallback `'unknown'`, no retry. |
| Status Kendaraan — Active Ticket | StatusKendaraanPage | **Partially Real** | `vehicleType` dan `areaName` dari `ActiveTicketStorage` real. Timer mulai dari 0 setiap load (tidak sync backend). |
| Status Kendaraan — Keluar Parkir | StatusKendaraanPage | **Fully Real** | `POST /access/cancelTicket` real API, loading + error dialog + clear storage on success. ✅ |
| History | HistoryPage | **Dummy** | 8 item hardcoded identik (sama semua: `19:33`, `02 Maret 2026`, `Mall Bumi Kedaton`, `TXT-20260302-0054`, `D 12345 FE`). Tidak ada API call. Komentar `// Data model sementara (akan digantikan dari repository)`. |
| Profil — User Info | ProfilPage | **Fully Real** | `GET /users/profile` real API, name/email/phone. |
| Profil — Stats | ProfilPage | **Dummy** | `totalParkir: '0'`, `parkirAktif: '0'` — **hardcoded `'0'` selalu**. Tidak ada endpoint stats. |
| Profil — Vehicles | ProfilPage | **Fully Real** | `GET /users/vehicles` real API. |
| Edit Profil — Save | EditProfilPage | **Fully Real** | `PUT /users/profile` real API, name/email/phone saved correctly. ✅ |
| Edit Profil — Vehicle form fields | EditProfilPage | **Partially Real** | Initial values hardcoded (`'D 12345 FE'`, `'Honda'`, `'Civic'`), overwritten by API if available. Fields are read-only (`enabled: false`). Tidak bisa edit kendaraan. |
| Edit Profil — Photo | EditProfilPage | **Dummy** | Tombol "Ubah Foto" tidak punya `onTap`. Decorative only. |
| Edit Profil — Add Vehicle | EditProfilPage | **Dummy** | Tombol "+ Kendaraan" tidak punya `onPressed`. Decorative only. |
| Edit Profil — Secondary Vehicles | EditProfilPage | **Dummy** | Seluruh section "Kendaraan Sekunder" adalah UI static tanpa data. |
| Pengaturan — Notifications | PengaturanPage | **Dummy** | 5 toggle switches, semua state lokal (`setState`). Tidak ada persistensi, tidak ada API call, tidak ada SharedPreferences. Hilang setelah restart. |
| Pengaturan — Theme | PengaturanPage | **Dummy** | 3 opsi tema (Terang/Gelap/Otomatis). Tidak ada theme switching logic. Tidak ada efek. |
| Pengaturan — About | PengaturanPage | **Dummy** | `onTap: () {}` — no-op. |

### Ringkasan

| Kategori | Jumlah | Detail |
|----------|--------|--------|
| **Fully Real** | 9 | Splash/Welcome, Login, Scan QR, Home Parking List, Booking List, Detail Booking Slots, StatusKendaraan Keluar, Profil User Info, Profil Vehicles, Edit Profil Save |
| **Partially Real** | 4 | Scan Result (API real, display parsial), Booking Submit (API real, error handling kurang), StatusKendaraan Timer (data real, timer lokal), Edit Profil Vehicle fields (API real, form disable) |
| **Dummy** | 11 | Home Status Cards, Home Tutorial, Detail Booking Area Info, Detail Booking Floor Tabs, History (100%), Profil Stats, Edit Profil Photo, Edit Profil Add Vehicle, Edit Profil Secondary Vehicles, Pengaturan Notif, Pengaturan Theme |
| **Blocked Backend** | 1 | Register — `POST /auth/register` plate validation broken |

---

## Endpoint Utilization

| Endpoint | Used? | Purpose |
|----------|-------|---------|
| `POST /auth/login` | ✅ | Login |
| `POST /auth/register` | ✅ | Register (broken) |
| `POST /auth/logout` | ✅ | Logout |
| `GET /users/profile` | ✅ | Profil + Home header |
| `PUT /users/profile` | ✅ | Edit Profil |
| `GET /users/vehicles` | ✅ | Profil vehicles list |
| `POST /users/vehicles` | ❌ | **Add vehicle — not implemented** |
| `DELETE /users/vehicles/{id}` | ❌ | **Remove vehicle — not implemented** |
| `GET /areas` | ✅ | Home + Booking list |
| `GET /areas/{id}` | ❌ | **Area detail — not used (area name hardcoded)** |
| `GET /areas/{id}/slots` | ✅ | DetailBooking slot map |
| `POST /reservations` | ✅ | Booking submit |
| `GET /reservations` | ❌ | **Reservation list — not implemented** |
| `GET /reservations/history` | ❌ | **Reservation history — not implemented** |
| `POST /access/verify` | ✅ | Scan QR verification |
| `POST /access/cancelTicket` | ✅ | Keluar Parkir |
| `GET /access/active-session` | ❌ | **Active session — endpoint 404 (missing from backend)** |

**6 endpoints not used**: 3 because frontend feature missing (`POST /users/vehicles`, `DELETE /users/vehicles/{id}`, `GET /areas/{id}`), 2 because backend missing (`GET /reservations`, `GET /reservations/history`), 1 because backend 404 (`GET /access/active-session`).

---

## Top 10 Priorities (Business Impact)

| # | Task | Screen | Dampak | Effort | Notes |
|---|------|--------|--------|--------|-------|
| 1 | **History API Integration** | History | User bisa lihat riwayat booking real. Saat ini 8 item hardcoded identik — tidak berguna. | Medium | Blocker: `GET /reservations` dan `GET /reservations/history` belum ada di backend. Perlu negotiate dengan backend team. |
| 2 | **Status Cards API Integration** | Home | 3 status cards saat ini mock semua — user tidak bisa lihat status tiket/booking/parkir aktif dari home. Core business value. | Medium | Butuh `GET /access/active-session` (backend 404) atau derive dari `GET /reservations`. |
| 3 | **Register Plate Fix** | Register | **Blocker utama akuisisi user.** Semua calon user gagal daftar karena validasi plate selalu reject. | Low | Validasi backend terlalu ketat atau bug. Backend fix. |
| 4 | **Pengaturan Persistence** | Pengaturan | 5 toggle notifikasi hilang setelah restart. User set preferences percuma. | Low | Simpan ke SharedPreferences (pola sama dengan `ActiveTicketStorage`). Tidak perlu backend. |
| 5 | **DetailBooking Area Name from API** | DetailBooking | `GET /areas/{id}` sudah ada di backend tapi tidak dipakai. Area name hardcoded. | Low | Panggil `GET /areas/{id}`, ganti hardcoded title + zone. |
| 6 | **DetailBooking Error/Empty States** | DetailBooking | Booking gagal silent (slot error, no ticket, no vehicle). Tidak ada feedback user. | Low | Tambah snackbar/dialog untuk setiap failure path. |
| 7 | **ScanBerhasil Display All Fields** | ScanBerhasil | 4 dari 6 field TicketData tidak ditampilkan (`vehicleType`, `areaId`, `areaName`, `bindingId`). Informasi berguna terbuang. | Low | Tambah UI cards untuk field tambahan. |
| 8 | **Edit Profil Vehicle Enable** | EditProfil | Vehicle fields read-only, tidak bisa edit kendaraan utama. User mungkin ganti kendaraan. | Medium | Backend perlu `PUT /users/vehicles/{id}` atau hapus disable pada form. |
| 9 | **Profil Stats from API** | Profil | `totalParkir: '0'` dan `parkirAktif: '0'` selalu — menurunkan kepercayaan user. | Medium | Blocker: Tidak ada endpoint stats. Bisa derive dari `GET /reservations`. |
| 10 | **Tutorial to API/CMS** | Home | 4 step tutorial hardcoded. Tidak bisa diubah tanpa rebuild. | High | Pindahkan ke API/CMS agar marketing bisa update konten tutorial. |

### Prioritas Berdasarkan Dampak Bisnis

```
HIGH BUSINESS IMPACT
├── #1 History API        — core feature mati total (dummy)
├── #2 Status Cards       — core feature mati total (dummy)
├── #3 Register Fix       — blokir akuisisi user
│
MEDIUM BUSINESS IMPACT
├── #4 Pengaturan         — user experience, retensi
├── #8 Edit Vehicle       — user kebutuhan riil
├── #9 Profil Stats       — kepercayaan user
│
LOW BUSINESS IMPACT (tapi gampang)
├── #5 Area Name API      — 1 endpoint call
├── #6 Error States       — polish
├── #7 ScanBerhasil fields — display only
│
LOW PRIORITY (effort besar)
└── #10 Tutorial CMS      — butuh infrastruktur
```

---

## Catatan Kritis

1. **Dummy terbanyak**: History (100%), Home Status Cards (100%), Pengaturan (100%). Tiga screen ini memberikan user experience palsu — data tidak real, tidak sinkron backend.

2. **Blocker backend terbanyak**: `GET /reservations`, `GET /reservations/history`, `GET /access/active-session`. Tiga endpoint ini diperlukan untuk fitur core (History, Home Status, StatusKendaraan timer). Tanpa ini, feature parity dengan Web User (Guest) tidak tercapai.

3. **Register broken = acquisition blocked**: Seluruh funnel akuisisi user berhenti di register. Ini adalah blocker #1 secara bisnis meskipun effort fix kecil (backend side).

4. **Belum ada state management**: Setelah 13 update, masih pakai `setState()` + `SharedPreferences`. Semakin banyak state yang perlu di-share antar screen, semakin besar pressure untuk migrasi ke state management (Riverpod/Bloc).
