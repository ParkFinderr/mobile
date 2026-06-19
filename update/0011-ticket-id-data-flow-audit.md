# Update 0011

Date: 2026-06-10
Task: Ticket ID Data Flow Audit — Scan → Booking

---

# Implementation Report

## Task Summary

Verifikasi apakah `ticketId` dari hasil scan QR benar-benar mengalir hingga ke `POST /reservations`. Jawaban: **TIDAK** — data putus di dua titik.

---

## Data Flow Diagram

### Actual Flow (Saat Ini)

```
WelcomeScan
  │ scan QR → POST /access/verify
  │ ↓
  │ TicketData { ticketCode: "r8an2ye14aN6dkZ1ifGW", areaName, areaId, ... }
  │ ↓ arguments
  ▼
ScanBerhasil ← menerima TicketData
  │ tampilkan ticketCode ✅
  │
  │ [Lanjut Booking]
  │ ↓ pushNamedAndRemoveUntil(home) — TANPA arguments
  ▼
Home ← TicketData DROP ❌
  │ tap area parkir → pushNamed(detailBooking, arguments: areaId)
  ▼
DetailBooking ← hanya terima areaId
  │ tap slot kosong
  │ ↓
  │ final ticketId = "ticket-user-123" ← HARDCODED ❌
  │ ↓
  ▼
POST /reservations { slotId, ticketId: "ticket-user-123", name, plateNumber }
```

### Titik Putus

| # | Titik | File | Baris | Masalah |
|---|-------|------|-------|---------|
| 1 | ScanBerhasil → Home | `scan_berhasil_widget.dart` | 244-248 | `pushNamedAndRemoveUntil(context, AppRoutes.home)` — **tanpa arguments** |
| 2 | DetailBooking → POST | `detail_booking_widget.dart` | 183 | `final ticketId = "ticket-user-123"` — **hardcoded** |

---

## Tracing Per File

### 1. WelcomeScan → ScanBerhasil ✅ (SUDAH BENAR)

`welcome_scan_widget.dart:66-71`

```dart
if (result != null) {
  Navigator.pushReplacementNamed(
    context, AppRoutes.scanBerhasil,
    arguments: result,  // ← TicketData dengan ticketCode = ticketId dari API
  );
}
```

**Status**: ✅ `TicketData` berhasil di-pass sebagai arguments.

### 2. ScanBerhasil → Tampilan ✅ (SUDAH BENAR)

`scan_berhasil_widget.dart:173-174`

```dart
Text(
  widget.ticketData?.ticketCode ?? 'TXT-00000000-0000',
```

**Status**: ✅ Ticket code tampil dari data real (bukan hardcoded).

### 3. ScanBerhasil → Home ❌ (DATA PUTUS)

`scan_berhasil_widget.dart:244-248`

```dart
onPressed: () => Navigator.pushNamedAndRemoveUntil(
  context,
  AppRoutes.home,
  (route) => false,
),
```

**Status**: ❌ Navigasi ke Home **tanpa membawa `TicketData`**. Semua data hasil scan hilang.

### 4. Home → DetailBooking ⚠️ (HANYA areaId)

`home_widget.dart:250-254`

```dart
Navigator.pushNamed(
  context,
  AppRoutes.detailBooking,
  arguments: item.id,  // ← hanya areaId
)
```

**Status**: ⚠️ Hanya areaId yang dikirim. TicketId tidak ada di state Home.

### 5. DetailBooking → POST /reservations ❌ (HARDCODED)

`detail_booking_widget.dart:181-183`

```dart
// Get ticketId (assuming from active ticket or dummy for now)
// Normally we should check active ticket. For now, use dummy "ticket-user-123"
final ticketId = "ticket-user-123";
```

**Status**: ❌ `ticketId` hardcoded `"ticket-user-123"`. Tidak ada hubungan dengan hasil scan.

---

## Root Cause

Ada **2 masalah** yang menyebabkan data tidak mengalir:

### Masalah 1: Tidak Ada State Management Global

`TicketData` hasil scan hanya diteruskan via route arguments ke ScanBerhasil. Setelah itu, tidak ada mekanisme untuk menyimpan data secara global (state management, SharedPreferences, atau local database) agar bisa diakses oleh screen lain.

Karena tidak ada state management, data hanya bisa di-pass via route arguments — dan ScanBerhasil tidak meneruskannya.

### Masalah 2: ScanBerhasil Tidak Meneruskan Data

`ScanBerhasilWidget` memiliki akses ke `widget.ticketData`, tapi tombol "Lanjut Booking" hanya navigasi ke Home tanpa arguments. Data tidak di-pass dan tidak disimpan.

---

## Dampak

| Dampak | Detail |
|--------|--------|
| **Booking gagal** | `POST /reservations` mengirim `ticketId: "ticket-user-123"` yang kemungkinan tidak valid di production |
| **Tidak ada traceability** | Tidak ada hubungan antara scan entry dan booking exit |
| **Hardcoded di production** | Jika tidak diperbaiki, semua booking akan menggunakan ticketId dummy yang sama |

---

## Skenario Perbaikan

### Opsi A: Simpan di SharedPreferences (Paling Sederhana)

Setelah scan berhasil, simpan `TicketData` ke SharedPreferences. DetailBooking baca dari SharedPreferences sebelum booking.

```
WelcomeScan → POST /access/verify
  → simpan ticketData ke SharedPreferences
  → navigasi ke ScanBerhasil
DetailBooking → baca ticketData dari SharedPreferences
  → POST /reservations dengan ticketId real
```

**Kelebihan**: Tidak perlu state management, langsung bisa diimplementasi.
**Kekurangan**: Tidak real-time, data bisa basi.

### Opsi B: Pass via Route Chain (Paling Cepat)

ScanBerhasil → navigasi ke Home dengan `TicketData` sebagai arguments. Home simpan di state. Home → DetailBooking dengan `TicketData` sebagai arguments tambahan.

```
ScanBerhasil → pushNamedAndRemoveUntil(home, arguments: ticketData)
Home → simpan ticketData di _state
Home → pushNamed(detailBooking, arguments: {areaId, ticketData})
DetailBooking → extract ticketData dari arguments → POST /reservations
```

**Kelebihan**: Tanpa dependency baru.
**Kekurangan**: Home jadi tergantung dengan data scan yang temporer.

### Opsi C: Implementasi State Management (Jangka Panjang)

Gunakan Provider/Riverpod/Bloc untuk menyimpan `TicketData` secara global.

**Kelebihan**: Solusi proper, scalable.
**Kekurangan**: Perlu refactor besar-besaran (seluruh app masih pakai `setState`).

---

## Recommended Fix

**Opsi B (Route Chain)** direkomendasikan karena:
1. Tanpa dependency baru
2. Cepat diimplementasi
3. Tidak mengubah arsitektur existing
4. Bisa diupgrade ke Opsi C nanti

Perubahan yang diperlukan:

| File | Perubahan |
|------|-----------|
| `scan_berhasil_widget.dart` | `pushNamedAndRemoveUntil(home, arguments: ticketData)` |
| `home_page.dart` / `home_widget.dart` | Terima `TicketData` dari arguments, simpan di state |
| `home_widget.dart` | Saat navigasi ke DetailBooking, kirim `TicketData` sebagai tambahan arguments |
| `detail_booking_widget.dart` | Terima `TicketData` dari arguments, gunakan `ticketCode` untuk booking |
| `app_routes.dart` | Update handler untuk Home dan DetailBooking jika perlu |

---

## Files Created

```txt
update/0011-ticket-id-data-flow-audit.md
```

---

## Files Modified

```txt
None (audit only)
```

---

## Known Issues

1. **Data putus di 2 titik**: ScanBerhasil → Home dan DetailBooking → POST
2. **Tidak ada state management**: Data tidak bisa diakses lintas screen tanpa route arguments
3. **HomeWidget tidak siap**: Tidak ada state untuk menyimpan `TicketData`

---

## Answer

**Apakah ticketId hasil scan benar-benar sampai ke POST /reservations?**

**TIDAK.**

TicketId (`r8an2ye14aN6dkZ1ifGW`) dari `POST /access/verify` ✅ sampai ke ScanBerhasil, tapi ❌ putus di navigasi `ScanBerhasil → Home` karena tidak di-pass sebagai arguments. Akibatnya `POST /reservations` selalu mengirim `ticketId: "ticket-user-123"` (hardcoded).

---

## Executive Summary

1. **Data flow scan → booking PUTUS** — ticketId dari API tidak mencapai `POST /reservations`
2. **2 titik putus**: ScanBerhasil→Home (no args) dan DetailBooking (hardcoded `"ticket-user-123"`)
3. **Akar masalah**: Tidak ada state management global — data hanya bisa di-pass via route arguments
4. **3 opsi perbaikan**: SharedPreferences (mudah), Route Chain (sedang), State Management (proper)
5. **Rekomendasi**: Opsi B (Route Chain) — paling cepat, tanpa dependency baru
6. **Dampak**: Semua booking menggunakan ticketId dummy yang sama
7. **Prioritas**: 🔴 Critical — harus diperbaiki sebelum production
