# Update 0007

Date: 2026-06-10
Task: End-to-End User Journey Audit

---

# Implementation Report

## Task Summary

Audit menyeluruh seluruh perjalanan pengguna ParkFinder dari awal hingga akhir. Mencakup 10 langkah proses bisnis: Register, Login, Scan QR, Verifikasi Tiket, Lihat Area Parkir, Pilih Slot, Booking Slot, Status Kendaraan Aktif, Keluar Parkir, dan Riwayat Penggunaan.

Tidak ada perubahan kode — hanya investigasi, dokumentasi, dan pelaporan.

---

## User Journey Overview

```
Register → Login → Scan QR → Verifikasi Tiket → Lihat Area → Pilih Slot
                                                      ↓
                                               Booking Slot
                                                      ↓
                                           Status Kendaraan Aktif
                                                      ↓
                                              Keluar Parkir
                                                      ↓
                                            Riwayat Penggunaan
```

---

## Step-by-Step Audit

### 1. Register

| Item | Detail |
|------|--------|
| **Screen** | RegisterPage / RegisterWidget |
| **Route** | `/register` |
| **Flow** | Login → tap "Daftar Sekarang" → Register → success → bottom sheet → pop ke Login |
| **API** | `POST /auth/login` ← auth_service.dart:28 |
| **Request** | `{name, email, phoneNumber, password, plateNumber}` |
| **Response** | `200/201` — success |
| **Auth** | ❌ No auth required |
| **Status** | ✅ **Fully Working** |

**Catatan**: Validasi form sudah ada (required fields). Error handling via snackbar. Register → success dialog → auto navigate ke Login.

---

### 2. Login

| Item | Detail |
|------|--------|
| **Screen** | LoginPage / LoginWidget |
| **Route** | `/login` |
| **Flow** | WelcomeTransition (auto) → Login → success → bottom sheet → WelcomeScan |
| **API** | `POST /auth/login` ← auth_service.dart:7 |
| **Request** | `{email, password}` |
| **Response** | `{token: string}` |
| **Auth** | ❌ No auth required |
| **Status** | ✅ **Fully Working** |

**Catatan**: JWT disimpan ke SharedPreferences via `ApiService.setToken()`. Login → WelcomeScan langsung (tidak melewati Welcome atau WelcomeTransition lagi).

---

### 3. Scan QR

| Item | Detail |
|------|--------|
| **Screen** | WelcomeScanPage / WelcomeScanWidget |
| **Route** | `/welcome-scan` |
| **Flow** | Login success → WelcomeScan → scan detected → ScanBerhasil |
| **API** | ❌ None — scan result (rawValue) tidak dikirim ke API |
| **Data yang discan** | Barcode raw value dari `mobile_scanner` |
| **Data yang diteruskan** | ❌ **Tidak di-pass** ke ScanBerhasil — hanya navigasi tanpa arguments |
| **Status** | ⚠️ **Partially Working** |

**Issues**:
1. **Scan result tidak di-pass** ke ScanBerhasilPage — navigasi via `pushReplacementNamed(context, AppRoutes.scanBerhasil)` tanpa arguments
2. **Tidak ada verifikasi API** — flow langsung ke ScanBerhasil tanpa panggil `POST /access/verify`
3. **ScanBerhasilPage tidak menerima parameter** — ticket code hardcoded `'TXT-20260302-0054'` (scan_berhasil_widget.dart:171)
4. **HalamanScan (dengan verifikasi API) sudah dihapus** di task 0006 — tidak ada alternatif yang panggil `/access/verify`

**Akibat**: QR code discan tapi tidak pernah diverifikasi ke backend. Ticket code yang ditampilkan selalu hardcoded.

---

### 4. Verifikasi Tiket

| Item | Detail |
|------|--------|
| **Screen** | ❌ **Tidak ada di active flow** |
| **Route** | ❌ Tidak ada route aktif untuk verifikasi |
| **API** | `POST /access/verify` — **tidak dipanggil di active flow** |
| **Request yang benar** | `{qrCode: string}` |
| **Response** | `200/201` — valid, lainnya — invalid |
| **Status** | 🚫 **Blocked by Backend / Missing** |

**Issues**:
1. **Tidak ada screen yang panggil `/access/verify`** di active flow. ScanService sudah dihapus bersama dead route `/halaman-scan`.
2. **WelcomeScan → ScanBerhasil langsung**, tanpa verifikasi. Artinya tiket parkir tidak pernah divalidasi.
3. Flow seharusnya: Scan QR → `POST /access/verify` → jika valid → ScanBerhasil. Saat ini: Scan QR → ScanBerhasil (skip verifikasi).

---

### 5. Lihat Area Parkir

| Item | Detail |
|------|--------|
| **Screen** | HomePage / HomeWidget + BookingPage / BookingWidget |
| **Route** | `/home` + `/booking` |
| **Flow** | Home (list) → tap item → DetailBooking. Booking (cari) → tap item → DetailBooking |
| **API** | `GET /areas` ← booking_service.dart:51 |
| **Request** | — (GET) |
| **Response** | `{success, data: [{id, name, totalSlots, availableSlots, address}]}` |
| **Auth** | ✅ Required |
| **Status** | ✅ **Fully Working** |

**Catatan**: Data real dari API (2 area: Teknik Elektro Unila, Masjid Teknik Unila). Loading/error/empty state ada. Area ID valid (bukan string kosong) — routing argument sudah diperbaiki di task 0003 dan 0004.

---

### 6. Pilih Slot

| Item | Detail |
|------|--------|
| **Screen** | DetailBookingPage / DetailBookingWidget |
| **Route** | `/detail-booking` |
| **Flow** | Home/Booking → tap area → DetailBooking → tap slot → booking |
| **API** | `GET /areas/{id}/slots` ← booking_service.dart:69 |
| **Request** | — (GET) |
| **Response** | `{success, data: [{id, slotName, appStatus, vehicleType}]}` |
| **Auth** | ✅ Required |
| **Status** | ✅ **Fully Working** (with caveats) |

**Caveats**:
1. **Title hardcoded**: AppBar title `'Teknik Elektro Universitas Lampung'` — tidak dinamis dari API
2. **Floor tabs hardcoded**: `['Semua', 'Lantai 1', 'Lantai 2']` — tidak dari data API
3. **Zone header hardcoded**: `'Zona A - Lantai 1'`

---

### 7. Booking Slot

| Item | Detail |
|------|--------|
| **Screen** | DetailBookingPage / DetailBookingWidget |
| **Route** | `/detail-booking` (sama dengan pilih slot) |
| **Flow** | Pilih slot kosong → loading → `POST /reservations` → snackbar sukses → refresh |
| **API** | `POST /reservations` ← booking_service.dart:87 |
| **Request** | `{slotId, ticketId, name, plateNumber}` |
| **Response** | `200/201` — success |
| **Auth** | ✅ Required |
| **Status** | ⚠️ **Partially Working** |

**Issues**:
1. **ticketId hardcoded**: `"ticket-user-123"` (detail_booking_widget.dart:183) — seharusnya dari active ticket API atau hasil scan
2. **Tidak ada konfirmasi dialog** — langsung booking setelah tap slot
3. **Success feedback**: Hanya snackbar, tidak ada navigasi ke status kendaraan

---

### 8. Status Kendaraan Aktif

| Item | Detail |
|------|--------|
| **Screen** | StatusKendaraanPage |
| **Route** | `/status-kendaraan` (bottom nav index 2) |
| **Flow** | Bottom nav → StatusKendaraan → timer berjalan → "Keluar Parkir" → Home |
| **API** | ❌ **None** — semua data hardcoded |
| **Auth** | ✅ Required (via ApiService) |
| **Status** | ⚠️ **Partially Working** |

| Data | Value di UI | Sumber | Status |
|------|------------|--------|--------|
| Nama kendaraan | `'McLaren Senna'` | Hardcoded (line 87) | ❌ |
| Plat nomor | `'D 12345 FE'` | Hardcoded (line 96) | ❌ |
| Slot parkir | `'A3'` | Hardcoded (line 148) | ❌ |
| Lantai | `'Lantai 1'` | Hardcoded (line 157) | ❌ |
| Timer | ✅ Real `Timer.periodic` | `_seconds++` (line 32-34) | ✅ **Sudah diperbaiki** |
| "Keluar Parkir" | Navigasi ke Home | Tidak panggil API | ❌ |

**Endpoint yang dibutuhkan**: `GET /access/active-session` atau serupa — **belum ada**.

---

### 9. Keluar Parkir

| Item | Detail |
|------|--------|
| **Screen** | StatusKendaraanPage + EndSessionDialogWidget (di Home) |
| **Route** | `/status-kendaraan` → button "Keluar Parkir" → Home |
| **Flow aktual** | Tap "Keluar Parkir" → `Navigator.pushReplacementNamed(context, AppRoutes.home)` — **tidak ada API call** |
| **API yang dibutuhkan** | `POST /access/cancelTicket` |
| **Auth** | ✅ Required |
| **Status** | ❌ **Missing** |

**Issues**:
1. **Tidak ada API call** — button hanya navigasi ke Home
2. **EndSessionDialog** (home_widget.dart:105-115) — data hardcoded (`'D 12345 FE'`, `'3 Jam 10 Menit'`), onConfirm hanya pop dialog
3. **Tidak ada konfirmasi ke backend** — sesi parkir tidak pernah diakhiri secara resmi

---

### 10. Riwayat Penggunaan

| Item | Detail |
|------|--------|
| **Screen** | HistoryPage / HistoryWidget |
| **Route** | `/history` (bottom nav index 3) |
| **Flow** | Bottom nav → History → scroll 8 item |
| **API** | ❌ **None** — semua data hardcoded |
| **Auth** | ✅ Required |
| **Status** | ⚠️ **Partially Working** |

| Data | Value | Status |
|------|-------|--------|
| Semua 8 item | Identik — `{19:33, 02 Maret 2026, 23:01, Mall Bumi Kedaton, TXT-20260302-0054, D 12345 FE}` | ❌ Hardcoded |
| User name | ✅ Real dari `GET /users/profile` | ✅ Sudah diperbaiki |
| Greeting | ✅ Real dari `greetingFromHour()` | ✅ Sudah diperbaiki |

**Endpoint yang dibutuhkan**: `GET /reservations` atau `GET /reservations/history` — **belum ada**.

---

## Master Table

| # | Step | Screen | Route | API | Data Dikirim | Data Diterima | Status | Notes |
|---|------|--------|-------|-----|-------------|---------------|--------|-------|
| 1 | Register | RegisterPage | `/register` | `POST /auth/register` | `{name, email, phoneNumber, password, plateNumber}` | `200/201` | ✅ Fully Working | Validasi form, error handling, auto-nav ke Login |
| 2 | Login | LoginPage | `/login` | `POST /auth/login` | `{email, password}` | `{token}` | ✅ Fully Working | JWT ke SharedPreferences, nav ke WelcomeScan |
| 3 | Scan QR | WelcomeScanPage | `/welcome-scan` | ❌ None | Barcode raw value | — | ⚠️ Partially Working | **Scan result tidak di-pass ke ScanBerhasil** |
| 4 | Verifikasi Tiket | ❌ None | ❌ None | `POST /access/verify` | `{qrCode}` | `200/201` | 🚫 Blocked / Missing | **Tidak ada active flow yang panggil API ini** |
| 5 | Lihat Area | HomePage + BookingPage | `/home` + `/booking` | `GET /areas` | — | `[{id, name, totalSlots, availableSlots, address}]` | ✅ Fully Working | Real API data, loading/error/empty state |
| 6 | Pilih Slot | DetailBookingPage | `/detail-booking` | `GET /areas/{id}/slots` | — | `[{id, slotName, appStatus, vehicleType}]` | ✅ Fully Working | **Title/floor/zone masih hardcoded** |
| 7 | Booking Slot | DetailBookingPage | `/detail-booking` | `POST /reservations` | `{slotId, ticketId, name, plateNumber}` | `200/201` | ⚠️ Partially Working | **ticketId hardcoded "ticket-user-123"** |
| 8 | Status Kendaraan | StatusKendaraanPage | `/status-kendaraan` | ❌ None | — | — | ⚠️ Partially Working | **Semua data hardcoded**, timer ✅ berfungsi |
| 9 | Keluar Parkir | StatusKendaraanPage | `/status-kendaraan` → `/home` | ❌ None | — | — | ❌ Missing | **Button hanya navigasi, tidak panggil API** |
| 10 | Riwayat | HistoryPage | `/history` | ❌ None | — | — | ⚠️ Partially Working | **8 item hardcoded**, user/greeting ✅ real |

---

## User Journey Flow Map (Actual vs Ideal)

### Actual Flow (Saat Ini)

```
Register → Login → WelcomeScan → [SCAN] → ScanBerhasil → Home → Booking → DetailBooking → [BOOKING]
                                                                                            ↓
                                                                                     (snackbar sukses)
                                                                                            ↓
                                                                                    StatusKendaraan
                                                                                      (data dummy)
                                                                                            ↓
                                                                                  "Keluar Parkir" → Home
                                                                                      (no API call)
                                                                                            ↓
                                                                                     History
                                                                                    (data dummy)
```

### Issues di Actual Flow

```
[SCAN]    → Scan result tidak diverifikasi ke API
[BOOKING] → ticketId hardcoded, tidak dari active session
            → Tidak ada navigasi ke StatusKendaraan setelah booking sukses
            → StatusKendaraan data semua dummy
            → "Keluar Parkir" hanya navigasi, tidak akhiri sesi
            → History data dummy
```

### Ideal Flow (Seharusnya)

```
Register → Login → WelcomeScan → POST /access/verify{qrCode} → ScanBerhasil (ticketCode real)
                                                                    ↓
                                                            Home → GET /areas
                                                                    ↓
                                                            Booking → GET /areas
                                                                    ↓
                                                            DetailBooking → GET /areas/{id}/slots → POST /reservations{slotId, ticketId, name, plate}
                                                                    ↓
                                                            StatusKendaraan → GET /access/active-session (data real)
                                                                    ↓
                                                            POST /access/cancelTicket → "Selesai"
                                                                    ↓
                                                            History → GET /reservations/history (data real)
```

---

## Gap Analysis

### Flow yang Sudah Selesai (✅)

| Flow | Bukti |
|------|-------|
| Register → Login | `POST /auth/register` + `POST /auth/login` — API terintegrasi penuh |
| Login → WelcomeScan | JWT storage, navigasi benar |
| Home → GET /areas | Data real, loading/error/empty state |
| Booking → GET /areas | Sama dengan Home, reuse BookingService |
| DetailBooking → GET /areas/{id}/slots | Slot map real dari API |
| DetailBooking → POST /reservations | Booking berhasil ke backend |

### Flow yang Belum Selesai (⚠️)

| Flow | Masalah |
|------|---------|
| Scan QR → Verifikasi Tiket | Scan result tidak di-pass, tidak ada verifikasi API |
| Booking → StatusKendaraan | Tidak ada navigasi setelah booking sukses |
| StatusKendaraan | Semua data hardcoded kecuali timer |
| History | 8 item hardcoded |
| DetailBooking title/floor | Masih hardcoded |

### Flow yang Terblokir Backend (🚫)

| Flow | Endpoint Dibutuhkan | Status Backend |
|------|---------------------|----------------|
| Active Session Data | `GET /access/active-session` | ❌ Belum ada |
| End Parking Session | `POST /access/cancelTicket` | ✅ Ada di api.md |
| Reservation History | `GET /reservations` atau `GET /reservations/history` | ❌ Belum ada |
| Area Detail by ID | `GET /areas/{id}` | ❌ Belum ada |

### Flow yang Hanya Menggunakan Dummy Data

| Screen | Data Dummy | Baris Kode |
|--------|-----------|------------|
| ScanBerhasilWidget | Ticket code `'TXT-20260302-0054'` | scan_berhasil_widget.dart:171 |
| DetailBookingWidget | ticketId `"ticket-user-123"` | detail_booking_widget.dart:183 |
| DetailBookingWidget | Title `'Teknik Elektro Universitas Lampung'` | detail_booking_widget.dart:109 |
| DetailBookingWidget | Floor tabs `['Semua', 'Lantai 1', 'Lantai 2']` | detail_booking_widget.dart:84 |
| DetailBookingWidget | Zone `'Zona A - Lantai 1'` | detail_booking_widget.dart:142 |
| StatusKendaraanPage | Vehicle `'McLaren Senna'` | status_kendaraan_page.dart:87 |
| StatusKendaraanPage | Plate `'D 12345 FE'` | status_kendaraan_page.dart:96 |
| StatusKendaraanPage | Slot `'A3'` | status_kendaraan_page.dart:148 |
| StatusKendaraanPage | Floor `'Lantai 1'` | status_kendaraan_page.dart:157 |
| HomeWidget | EndSessionDialog `'D 12345 FE'`, `'3 Jam 10 Menit'` | home_widget.dart:109-110 |
| HomeWidget | StatusCards (3 card) | home_widget.dart:267-297 |
| HistoryWidget | Semua 8 item | history_widget.dart:64-75 |

---

## Summary Statistics

| Metrik | Jumlah |
|--------|--------|
| ✅ Fully Working | 4 dari 10 step (Register, Login, Lihat Area, Pilih Slot) |
| ⚠️ Partially Working | 4 dari 10 step (Scan QR, Booking Slot, Status Kendaraan, Riwayat) |
| ❌ Missing | 1 dari 10 step (Keluar Parkir) |
| 🚫 Blocked by Backend | 1 dari 10 step (Verifikasi Tiket) |
| Endpoint API terintegrasi | 7 endpoint |
| Endpoint dibutuhkan (missing) | 4 endpoint |
| Data hardcoded (total) | 16+ nilai di 6 screen |

---

## Known Issues

1. **Scan flow broken** — ScanService dihapus di task 0006, tidak ada alternatif verifikasi
2. **ticketId hardcoded** di DetailBooking — `"ticket-user-123"` bukan real dari active session
3. **StatusKendaraan hanyalah UI** — tidak ada data real, tidak ada interaksi backend
4. **Keluar Parkir tidak fungsional** — button hanya navigasi ke Home
5. **History tidak berguna** — 8 item duplikat hardcoded
6. **DetailBooking title tidak dinamis** — area name dari `/areas/{id}` tidak di-fetch

---

## Technical Debt

1. **Scan flow perlu redesign**: WelcomeScan → API verify → ScanBerhasil (pass ticket code)
2. **Booking flow perlu post-booking navigation**: Booking sukses → StatusKendaraan (dengan data real)
3. **Missing API endpoints**: active-session, cancelTicket, reservation history, area detail
4. **StatusKendaraan bukan sekadar UI**: perlu integrasi penuh dengan active session API
5. **History perlu backend**: 8 item hardcoded tidak scalable

---

## Remaining Work

1. Fix scan flow: pass barcode result ke ScanBerhasil, panggil POST /access/verify
2. Ganti ticketId hardcoded dengan real data (dari scan atau active ticket API)
3. Implementasi StatusKendaraan dengan real API data
4. Implementasi Keluar Parkir dengan POST /access/cancelTicket
5. Implementasi History dari GET /reservations
6. Buat DetailBooking dinamis: title, floor tabs dari API

---

## Recommended Next Steps

1. **🔴 Critical** — Fix scan flow: integrasikan `POST /access/verify` di WelcomeScan + pass ticket code ke ScanBerhasil
2. **🔴 Critical** — Implementasi active session API: `GET /access/active-session` dan `POST /access/cancelTicket`
3. **🟡 Medium** — Implementasi history API: `GET /reservations`
4. **🟡 Medium** — Buat DetailBooking dinamis dengan `GET /areas/{id}`
5. **🟡 Medium** — Post-booking navigation: Booking sukses → StatusKendaraan
6. **🟢 Low** — Hapus dummy data dari EndSessionDialog dan StatusCards di Home

---

## Executive Summary

1. **4 dari 10 step user journey fully working**: Register, Login, Lihat Area, Pilih Slot
2. **4 step partially working**: Scan QR (no verify), Booking (hardcoded ticketId), StatusKendaraan (all dummy), History (8 dummy items)
3. **1 step missing**: Keluar Parkir — button hanya navigasi tanpa API call
4. **1 step blocked**: Verifikasi Tiket — `POST /access/verify` tidak dipanggil di active flow
5. **7 endpoint API terintegrasi**, **4 endpoint dibutuhkan** (active-session, cancelTicket, history, area detail)
6. **16+ nilai hardcoded** tersebar di 6 screen yang berbeda
7. **Scan flow rusak** setelah dead route cleanup task 0006 — ScanService dihapus tanpa alternatif
8. **Booking flow putus**: booking sukses → snackbar → tidak ada navigasi ke StatusKendaraan
9. **StatusKendaraan hanyalah UI shell**: timer ✅, data ❌, keluar ❌
10. **Prioritas tertinggi**: Verifikasi tiket via API + integrasi active session endpoint
