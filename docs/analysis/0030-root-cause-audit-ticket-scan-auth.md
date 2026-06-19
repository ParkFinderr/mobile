# Root Cause Audit — Ticket State, Scan Flow & Auth Session (Task 0030)

Date: 2026-06-12
Task: 0030 — Root Cause Audit: Ticket State, Scan Flow & Auth Session

---

## Ringkasan

Investigasi ini menemukan **3 bug utama** dengan root cause yang saling terkait. Seluruh gejala berpusat pada satu masalah fundamental: **tidak ada state management yang reaktif**. Semua state menggunakan `setState()` + `SharedPreferences` tanpa mekanisme sinkronasi reaktif antar komponen. Setiap halaman membaca data secara independen dari `SharedPreferences`, dan tidak ada notifikasi ketika data berubah.

---

## Daftar Bug Prioritas Tinggi

| # | Bug | Prioritas | Dampak |
|---|-----|-----------|--------|
| 1 | **False Positive "Tiket Aktif"** | **Critical** | Home menampilkan "✓ Tiket Aktif" untuk status `pending`/`claimed` yang sebenarnya belum bisa booking |
| 2 | **Scan Entry Point Hilang Saat Tiket "Aktif"** | **High** | Ketika Home salah menampilkan "Aktif", tombol "Scan Tiket" disembunyikan — user tidak punya cara untuk scan ulang |
| 3 | **Auto-Login Tidak Otomatis** | **High** | Session hilang setelah restart karena `_goToHome()` hanya dipicu oleh tap tombol, bukan timer |
| 4 | **Bottom Nav Kendaraan Rusak** | **Medium** | Menu "Kendaraan" (index 2) tidak memiliki handler navigasi di semua halaman — tombol mati |
| 5 | **Tidak Ada Validasi Status Tiket Sebelum Booking** | **High** | Booking hanya cek `ticket != null`, tidak cek status dari backend — menyebabkan error dari API backend |

---

## Investigasi 1 — Status Tiket Aktif

### Gejala
Home menampilkan "✓ Tiket Aktif", namun Booking menolak dengan pesan error dari backend.

### Root Cause

**Penyebab 1: Definisi "Aktif" terlalu luas di HomeWidget**

File: `lib/features/home/widget/home_widget.dart:269-281`

```dart
if (_activeTicket != null && _activeTicket!.ticketCode.isNotEmpty) {
  final st = _activeTicket!.status.toLowerCase();
  if (st == 'completed' || st == 'checked_out' || st == 'inactive') {
    titleText = '⚠ Tiket Tidak Aktif';
    ...
  } else {
    titleText = '✓ Tiket Aktif';          // ← Termasuk status: 'pending', 'claimed', ''
    ...
  }
}
```

HomeWidget menganggap SEMUA status selain `completed`, `checked_out`, `inactive` sebagai "Aktif". Ini termasuk:
- `pending` — tiket baru dibuat, belum diproses
- `claimed` — tiket sudah diklaim tapi belum aktif penuh
- `''` (string kosong) — jika backend tidak mengirim status

Backend `POST /reservations` kemungkinan hanya menerima tiket dengan status tertentu (mungkin hanya `active`). Ketika booking dikirim dengan status `pending` atau `claimed`, backend mengembalikan error yang mirip "Tiket belum di-scan atau sudah tidak aktif".

**Penyebab 2: Booking tidak memvalidasi status tiket**

File: `lib/features/booking/widget/booking_widget.dart:38-45`
```dart
final ticket = await ActiveTicketStorage().load();
if (ticket == null || ticket.ticketCode.isEmpty) {
  // redirect ke scan
  return;
}
_fetchAreas();  // ← langsung lanjut tanpa cek status
```

File: `lib/features/detail_booking/widget/detail_booking_widget.dart:46-54`
```dart
final ticket = await ActiveTicketStorage().load();
if (ticket == null || ticket.ticketCode.isEmpty) {
  // redirect ke scan
  return;
}
_fetchSlots();  // ← langsung lanjut tanpa cek status
```

Kedua halaman booking hanya memvalidasi **eksistensi** tiket (tidak null), bukan **status** tiket. Tiket dengan status `pending` tetap diizinkan masuk ke halaman booking, dan error baru muncul ketika `POST /reservations` dipanggil di `detail_booking_widget.dart:200`.

**Penyebab 3: State tidak reaktif — Home menggunakan cache lokal yang bisa stale**

HomeWidget menyimpan state di `_activeTicket` (line 51) dan `_hasActiveTicket` (line 50) yang di-load sekali di `initState()` (line 60) via `_checkActiveTicket()`. State hanya di-refresh ketika user kembali dari navigasi tertentu (`.then((_) => _checkActiveTicket())`). Jika tiket berubah di halaman lain (misal scan ulang), Home tidak otomatis mengetahui perubahan.

### File yang Terlibat
| File | Peran |
|------|-------|
| `lib/features/home/widget/home_widget.dart` | Definisi status "Aktif" terlalu luas (line 269-281) |
| `lib/features/booking/widget/booking_widget.dart` | Tidak validasi status tiket sebelum booking (line 38-45) |
| `lib/features/detail_booking/widget/detail_booking_widget.dart` | Tidak validasi status tiket sebelum booking (line 46-54) |
| `lib/core/storage/active_ticket_storage.dart` | Penyimpanan tiket di SharedPreferences |
| `lib/features/welcome_scan/service/scan_service.dart` | Model TicketData — field `status` dari API backend |

---

## Investigasi 2 — Audit Halaman Scan

### Gejala
User tidak menemukan jalur menuju halaman scan tiket.

### Root Cause

**Penyebab 1: Bottom Navigation Bar tidak pernah memiliki menu Scan**

File: `lib/features/public_widget/bottom_nav_bar.dart:33-37`

```dart
AppBottomNavBar → 5 item: Beranda, Parkir, Kendaraan, History, Profil
```

Berdasarkan git history, **tidak pernah ada** menu Scan di bottom navigation. Ini adalah desain awal, bukan regresi. Git commit `63a3573` ("algoritma versi figma") menunjukkan 5 item ini sudah ada sejak file pertama dibuat.

**Penyebab 2: Entry point scan bergantung pada status tiket**

Hanya ada 3 entry point menuju scan:
1. **Tombol "Scan Tiket"** di ticket status banner (home_widget.dart:345-362) — **hanya muncul** ketika `showScanButton = true`, yaitu saat tiket tidak ada atau status `completed`/`checked_out`/`inactive`
2. **Dialog "Scan Tiket Sekarang"** di `NoTicketDialog` — hanya muncul ketika user mencoba booking tanpa tiket
3. **Redirect otomatis** dari BookingWidget/DetailBookingWidget — hanya terjadi jika tidak ada tiket di ActiveTicketStorage

Ketika Gejala 1 terjadi (Home menampilkan "✓ Tiket Aktif" untuk status `pending`), maka:
- `showScanButton = false` (line 280) — tombol scan di banner **hilang**
- BookingWidget tidak redirect (karena tiket tidak null)
- `NoTicketDialog` tidak muncul (karena booking page dianggap punya tiket)

User terjebak dalam situasi: "Tiket Aktif" terlihat, tombol scan tidak ada, booking gagal.

**Penyebab 3: Route `/scan` tidak ada, hanya `/welcome-scan`**

Hanya ada route `/welcome-scan` dan `/scan-berhasil`. Tidak ada route `/scan`. Jika user mencari "scan" di UI, mereka tidak akan menemukan menu atau tombol dengan label tersebut di tempat yang mudah terlihat.

### File yang Terlibat
| File | Peran |
|------|-------|
| `lib/features/public_widget/bottom_nav_bar.dart` | Tidak ada menu Scan (by design sejak awal) |
| `lib/features/home/widget/home_widget.dart:269-281` | showScanButton logic — tombol scan hilang saat status pseudo-aktif |
| `lib/app/app_routes.dart` | Route `/scan` tidak terdaftar — hanya `/welcome-scan` |
| `lib/features/welcome_scan/widget/welcome_scan_widget.dart` | Halaman scan (masih ada dan berfungsi) |
| `lib/features/public_widget/no_ticket_dialog.dart` | Dialog navigasi scan (masih ada) |

---

## Investigasi 3 — Audit Flow Booking

### Gejala
Booking menolak dengan pesan "Tiket belum di-scan" atau "Tiket belum aktif".

### Root Cause

**Penyebab 1: Validasi tiket hanya cek eksistensi, bukan status**

BookingWidget (booking_widget.dart:38-45) dan DetailBookingWidget (detail_booking_widget.dart:46-54) sama-sama hanya memeriksa:
```dart
if (ticket == null || ticket.ticketCode.isEmpty) { ... }
```

Tidak ada pengecekan `ticket.status == 'active'` atau sejenisnya. Akibatnya:
- Tiket dengan status `pending`, `claimed`, atau `expired` tetap diizinkan masuk
- Error baru muncul ketika `POST /reservations` dipanggil (detail_booking_widget.dart:200)
- Pesan error berasal dari BACKEND, bukan dari frontend

**Penyebab 2: Pesan error backend tidak ditangani dengan baik**

File: `lib/features/detail_booking/widget/detail_booking_widget.dart:218-222`
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(result.message), backgroundColor: Colors.red),
);
```

Pesan error dari backend ditampilkan langsung ke user tanpa konteks atau panduan tindakan selanjutnya. User tidak diberi tahu bahwa mereka perlu scan ulang atau apa yang salah dengan tiket mereka.

### File yang Terlibat
| File | Peran |
|------|-------|
| `lib/features/booking/widget/booking_widget.dart:38-45` | Validasi tiket tidak lengkap |
| `lib/features/detail_booking/widget/detail_booking_widget.dart:46-54, 196-222` | Validasi tiket tidak lengkap + error handling minimal |
| `lib/features/booking/service/booking_service.dart` | API call `POST /reservations` |

---

## Investigasi 4 — Auth Session

### Gejala
Setelah login → tutup aplikasi → buka aplikasi → harus login ulang.

### Root Cause

**Penyebab 1: Auto-login hanya terpicu oleh tap tombol, bukan otomatis**

File: `lib/features/splash_screen/widget/splash_screen_widget.dart:125-156`

```dart
void _goToHome(BuildContext context) async {
  final token = prefs.getString('jwt_token');
  if (token != null) {
    final profile = await ProfileService().getProfile();
    if (profile != null) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      return;
    }
  }
  // fallback ke WelcomePage
}
```

Method `_goToHome()` DIPANGGIL HANYA DARI:
1. `onTap` pada tombol panah atas (line 266) — user HARUS menekan tombol
2. `onDismiss` dari PWA install dialog (lines 106, 117) — hanya untuk PWA web

**TIDAK ADA** auto-navigation ketika animasi selesai. Jika user membuka aplikasi dan tidak menekan tombol, mereka tetap di splash screen.

**Penyebab 2: Tidak ada offline trust untuk token**

Auto-login bergantung pada **network call** `GET /users/profile` untuk validasi token. Jika:
- Device offline → `getProfile()` throw exception → return `null` → redirect ke WelcomePage
- Token expired → backend return 401 → `getProfile()` return `null` → redirect ke WelcomePage
- Koneksi lambat → timeout → `getProfile()` return `null` → redirect ke WelcomePage

Token yang valid tetap ada di SharedPreferences, tapi karena validasi network gagal, user dianggap tidak terautentikasi.

**Penyebab 3: Register flow tidak menyimpan token**

File: `lib/features/login/service/auth_service.dart:34-44`
```dart
Future<String?> register(...) async {
  // ... POST /auth/register ...
  if (response.statusCode == 200 || response.statusCode == 201) {
    return null;  // sukses → return null, TAPI TIDAK SIMPAN TOKEN
  }
}
```

Setelah registrasi berhasil, user diarahkan ke halaman login. Ini by design (register → login), tapi menambah friction.

### File yang Terlibat
| File | Peran |
|------|-------|
| `lib/features/splash_screen/widget/splash_screen_widget.dart:125-156` | Auto-login logic — tidak otomatis, tergantung network |
| `lib/features/login/service/auth_service.dart:20-28, 34-44` | Login (save token), Register (tidak save token) |
| `lib/core/network/api_service.dart:6-24` | Token storage di SharedPreferences key `jwt_token` |
| `lib/features/profil/service/profile_service.dart:22-35` | getProfile — return null jika network error / 401 |
| `lib/features/login/widget/login_widget.dart:72-85` | Login success → navigasi ke Home |

---

## Investigasi 5 — Bottom Navigation

### Temuan

**Menu yang tersedia:**
| Index | Ikon | Label | Route | Status |
|-------|------|-------|-------|--------|
| 0 | `home_rounded` | Beranda | `/home` | ✅ Berfungsi |
| 1 | `location_on_outlined` | Parkir | `/booking` | ⚠️ Ada gate ticket check |
| 2 | `directions_car_outlined` | Kendaraan | `/status-kendaraan` | ❌ **RUSAK — tidak ada handler** |
| 3 | `history_rounded` | History | `/history` | ✅ Berfungsi |
| 4 | `person_outline_rounded` | Profil | `/profil` | ✅ Berfungsi |

**Menu Scan: TIDAK PERNAH ADA**
Berdasarkan git history, `bottom_nav_bar.dart` hanya memiliki 5 item sejak file pertama dibuat. Menu scan tidak pernah dihapus — memang tidak pernah ditambahkan.

**Menu Kendaraan (index 2) RUSAK:**
Tidak ada satu pun file yang memiliki `case 2:` di handler `_onNavTap()`. File yang diperiksa:
- `home_widget.dart` — hanya handle index 1, 3, 4
- `booking_widget.dart` — hanya handle index 0, 3, 4
- `detail_booking_widget.dart` — hanya handle index 0, 3, 4
- `history_widget.dart` — hanya handle index 1, 4
- `profil_widget.dart` — hanya handle index 1, 3
- `status_kendaraan_page.dart` — hanya handle index 1, 3, 4

Menu Kendaraan (index 2) mengupdate `_navIndex = 2` (visual highlight berubah) tapi **tidak ada navigasi**. Ini dead button di semua halaman.

### File yang Terlibat
| File | Peran |
|------|-------|
| `lib/features/public_widget/bottom_nav_bar.dart` | Definisi 5 menu navigasi |
| `lib/features/home/widget/home_widget.dart:145-168` | Handler nav — missing case 2 |
| `lib/features/booking/widget/booking_widget.dart:80-93` | Handler nav — missing case 2 |
| `lib/features/detail_booking/widget/detail_booking_widget.dart:101-114` | Handler nav — missing case 2 |
| `lib/features/history/widget/history_widget.dart` | Handler nav — missing case 2 |
| `lib/features/profil/widget/profil_widget.dart` | Handler nav — missing case 2 |
| `lib/features/home/page/status_kendaraan_page.dart` | Handler nav — missing case 2 (ironisnya ini halaman Kendaraan sendiri!) |

---

## Investigasi 6 — Single Source of Truth

### Tabel Data Source per Fitur

| Fitur | Data Source | SharedPrefs Key | Masalah |
|-------|------------|-----------------|---------|
| Home Ticket Status Banner | `_activeTicket` (cache lokal di State) | `active_ticket` (via ActiveTicketStorage) | Cache lokal bisa stale; tidak reaktif |
| Home Status Cards | `_hasActiveTicket` (derived bool) + `_activeReservation` | `active_ticket` + `active_reservation` | Dua state berbeda untuk data yang sama |
| Booking Validation | `ActiveTicketStorage().load()` langsung | `active_ticket` | Baca langsung dari SharedPrefs setiap kali |
| Detail Booking Validation | `ActiveTicketStorage().load()` langsung | `active_ticket` | Baca langsung dari SharedPrefs setiap kali |
| Detail Booking Reservation | `ActiveReservationStorage().save()` | `active_reservation` | Satu-satunya write point |
| Scan Result Save | `ActiveTicketStorage().save()` | `active_ticket` | Satu-satunya write point |
| Scan Berhasil Display | Route argument `TicketData?` | — | Argument passing |
| Status Kendaraan | `ActiveTicketStorage().load()` + `ActiveReservationStorage().load()` | `active_ticket` + `active_reservation` | Baca langsung setiap kali |
| History | `ReservationHistory` dari API | — | Data dari API, tidak ada cache |
| Auth Token | `SharedPreferences` key `jwt_token` | `jwt_token` | Disimpan via ApiService, dibaca via ApiService dan langsung di splash |
| Profile | `ProfileService().getProfile()` dari API | — | Tidak ada cache |

### Kesimpulan SSOT

Aplikasi menggunakan **SharedPreferences sebagai 3 penyimpanan terpisah**:
1. `jwt_token` — untuk auth
2. `active_ticket` — untuk tiket aktif (serialized TicketData JSON)
3. `active_reservation` — untuk reservasi aktif (serialized ActiveReservation JSON)

**Tidak ada mekanisme notifikasi/reaktivitas.** Setiap halaman harus membaca ulang SharedPreferences secara manual. Tidak ada pattern seperti:
- Stream/Bloc/Riverpod untuk state management
- Event bus untuk notifikasi perubahan data
- Service locator / dependency injection

Ini menyebabkan:
1. Home bisa menampilkan data basi (cache lokal tidak sinkron dengan SharedPrefs)
2. Booking membaca data berbeda dengan Home (walaupun dari key yang sama, timing berbeda)
3. Scan/Booking/Home tidak tahu satu sama lain ketika data berubah

---

## Diagram Flow Aktual

### Flow yang Seharusnya (Ideal)

```
[A] Scan Tiket
    → POST /access/verify
    → TicketData {status: "active"}
    → Simpan ke ActiveTicketStorage
    → [NOTIFY] semua listener: ticket berubah

[B] Home
    → [LISTEN] perubahan ticket
    → Tampilkan "✓ Tiket Aktif" (hanya jika status == "active")
    → Tampilkan tombol Scan jika status != "active"

[C] Booking
    → [LISTEN] perubahan ticket
    → Cek status ticket == "active"
    → Jika ya: tampilkan halaman booking
    → Jika tidak: redirect ke scan + pesan jelas

[D] Reservasi
    → POST /reservations {ticketId: ..., slotId: ...}

[E] Auto-Login
    → Splash selesai → [OTOMATIS] cek token
    → Token valid → langsung ke Home (tanpa tap)
```

### Flow Aktual (Saat Ini)

```
[A] Scan Tiket
    → POST /access/verify
    → TicketData {status: "pending" atau "claimed"}
    → Simpan ke ActiveTicketStorage
    → TIDAK ADA NOTIFIKASI

[B] Home
    → Baca ActiveTicketStorage di initState
    → Cache di _activeTicket (local state)
    → status != completed/checked_out/inactive → "✓ Tiket Aktif" ← FALSE POSITIVE
    → showScanButton = false → tombol scan HILANG

[C] Booking
    → Baca ActiveTicketStorage (baca ulang dari SharedPrefs)
    → ticket != null → izinkan akses
    → TIDAK CEK STATUS
    → POST /reservations → ERROR dari backend

[D] User
    → Melihat "✓ Tiket Aktif" tapi booking gagal
    → Tombol scan tidak ada
    → Tidak ada panduan apa yang harus dilakukan

[E] Auto-Login
    → Splash selesai → TAP TOMBOL dulu → cek token
    → Jika offline → network error → fallback ke WelcomePage
    → Token valid tapi offline → login ulang
```

---

## Diagram Alur Data Yang Rusak

```
Scanner (welcome_scan_widget)
  │
  │ POST /access/verify → TicketData {status: "pending"}
  │
  ▼
ActiveTicketStorage.save()  ───→  SharedPreferences('active_ticket')
  │
  ├──► HomeWidget._checkActiveTicket()    │  ← baca di initState
  │    └── _activeTicket = ticket          │  ← cache lokal
  │    └── status pending → "✓ Tiket Aktif"│  ← FALSE POSITIVE
  │    └── showScanButton = false          │  ← scan button HILANG
  │
  ├──► BookingWidget._checkTicketAndFetch()│  ← baca ulang dari SP
  │    └── ticket != null → izinkan booking│  ← TIDAK CEK STATUS
  │    └── POST /reservations → ERROR      │  ← backend tolak
  │
  └──► DetailBookingWidget                │  ← sama seperti Booking
```

---

## Prioritas Perbaikan untuk Task 0031

| Prioritas | Perbaikan | File Target |
|-----------|-----------|-------------|
| **P1** | Filter status tiket di Home: hanya tampilkan "✓ Tiket Aktif" jika `status == 'active'`. Produktifkan tombol scan untuk status lain. | `home_widget.dart:269-281` |
| **P1** | Validasi status tiket (`status == 'active'`) sebelum izinkan akses ke Booking/DetailBooking | `booking_widget.dart:38-45`, `detail_booking_widget.dart:46-54` |
| **P2** | Tambah auto-navigation dari splash setelah animasi selesai (timer 3 detik) | `splash_screen_widget.dart` |
| **P2** | Tambah loading state saat auto-login (sekarang layar diam saat validasi token) | `splash_screen_widget.dart` |
| **P2** | Cache profile data untuk offline auto-login (agar tidak perlu network call) | `profile_service.dart` |
| **P3** | Fix dead button "Kendaraan" (index 2) di semua handler `_onNavTap` | Semua file dengan `_onNavTap` |
| **P3** | Tambah error handling yang informatif saat booking gagal (dengan aksi scan ulang) | `detail_booking_widget.dart:218-222` |
| **P4** | Migrasi state management ke pattern reaktif (Bloc/Riverpod) | Semua file |
| **P4** | Implementasi event bus untuk notifikasi perubahan tiket antar halaman | file baru |

---

## Risiko yang Tersisa

1. **Register tidak auto-login** — setelah register, user harus login manual (by design, tapi tetap friction)
2. **Token tidak di-refresh** — token expired mid-session menyebabkan 401 tanpa recovery
3. **SharedPreferences tidak aman** — token JWT disimpan di localStorage (web) tanpa enkripsi
4. **Tidak ada retry mechanism** — network error langsung dianggap gagal total

---

## Daftar File yang Diamati

```
lib/core/network/api_service.dart
lib/core/storage/active_ticket_storage.dart
lib/core/storage/active_reservation_storage.dart
lib/features/splash_screen/widget/splash_screen_widget.dart
lib/features/login/service/auth_service.dart
lib/features/login/widget/login_widget.dart
lib/features/register/widget/register_widget.dart
lib/features/welcome_scan/service/scan_service.dart
lib/features/welcome_scan/widget/welcome_scan_widget.dart
lib/features/scan_berhasil/widget/scan_berhasil_widget.dart
lib/features/scan_berhasil/page/scan_berhasil_page.dart
lib/features/home/widget/home_widget.dart
lib/features/home/page/status_kendaraan_page.dart
lib/features/home/service/parking_service.dart
lib/features/booking/widget/booking_widget.dart
lib/features/detail_booking/widget/detail_booking_widget.dart
lib/features/booking/service/booking_service.dart
lib/features/history/widget/history_widget.dart
lib/features/history/model/reservation_history.dart
lib/features/profil/service/profile_service.dart
lib/features/profil/widget/profil_widget.dart
lib/features/public_widget/bottom_nav_bar.dart
lib/features/public_widget/no_ticket_dialog.dart
lib/app/app_routes.dart
```

---

## Validasi Laporan

| Pertanyaan | Jawaban |
|------------|---------|
| ✓ Kenapa Home menampilkan "Tiket Aktif"? | Home menggunakan definisi "aktif" yang terlalu luas — semua status kecuali 3 kata kunci dianggap aktif |
| ✓ Kenapa Booking menolak booking? | Booking tidak memvalidasi status tiket sebelum mengirim request ke backend |
| ✓ Apakah halaman scan masih ada? | Ya — `/welcome-scan` route masih terdaftar dan `WelcomeScanWidget` masih berfungsi |
| ✓ Kenapa user tidak menemukan menu scan? | Bottom nav tidak pernah punya menu scan; tombol scan di banner hilang saat tiket pseudo-aktif |
| ✓ Kenapa session login hilang saat aplikasi ditutup? | Auto-login memerlukan tap tombol + network call; tidak ada auto-navigation otomatis |
| ✓ State mana yang tidak sinkron? | Cache lokal `_activeTicket` di Home vs baca langsung SharedPrefs di Booking |
| ✓ File mana yang menjadi sumber masalah? | `home_widget.dart:269-281` (definisi aktif terlalu luas) + `booking_widget.dart:38-45` / `detail_booking_widget.dart:46-54` (tidak validasi status) + `splash_screen_widget.dart:125-156` (auto-login tidak otomatis) |
