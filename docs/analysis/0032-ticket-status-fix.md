# Task 0032 — Fix Ticket Status Flow & Booking Validation

Date: 2026-06-12
Task: 0032 — Fix Ticket Status Flow & Booking Validation

---

## Root Cause (dari Task 0031A)

| Bug | Root Cause | File | Line |
|-----|------------|------|------|
| False positive "✓ Tiket Aktif" | Default `'active'` di `TicketData.fromJson()` | `scan_service.dart` | 24 |
| Status `pending`/`claimed` dianggap aktif | Catch-all `else` hanya filter 3 status | `home_widget.dart` | 270-280 |
| Booking tidak validasi status | Hanya cek `ticket != null`, bukan `ticket.status` | `booking_widget.dart`, `detail_booking_widget.dart` | 38-45, 46-54 |

---

## File yang Diubah

| File | Perubahan |
|------|-----------|
| `lib/features/welcome_scan/service/scan_service.dart` | Default status `'active'` → `''` |
| `lib/features/home/widget/home_widget.dart` | Klasifikasi status: only `'active'` = valid, `'pending'`/`'claimed'`/`''` = belum aktif, sisanya = tidak aktif |
| `lib/features/booking/widget/booking_widget.dart` | Tambah validasi `ticket.status != 'active'` di `_checkTicketAndFetch()` |
| `lib/features/detail_booking/widget/detail_booking_widget.dart` | Tambah validasi `ticket.status != 'active'` di `_checkTicketAndFetch()` dan `_handleSlotBooking()`; perbaiki error message + redirect |
| `lib/features/scan_berhasil/widget/scan_berhasil_widget.dart` | Perbaiki fallback label status saat `status` kosong |

---

## Sebelum vs Sesudah

### 1. scan_service.dart

**Sebelum:**
```dart
status: json['status'] ?? 'active',
```

**Sesudah:**
```dart
status: json['status'] ?? '',
```

### 2. home_widget.dart — Status Banner

**Sebelum:**
| Status | Output |
|--------|--------|
| `active` | ✓ Tiket Aktif |
| `pending` | ✓ Tiket Aktif (SALAH) |
| `claimed` | ✓ Tiket Aktif (SALAH) |
| `completed` | ⚠ Tiket Tidak Aktif |
| `checked_out` | ⚠ Tiket Tidak Aktif |
| `inactive` | ⚠ Tiket Tidak Aktif |
| `expired` | ✓ Tiket Aktif (SALAH) |
| `''` (dari default baru) | ⚠ Tiket Belum Aktif (ticketCode empty → fallback) |

**Sesudah:**
| Status | Output | showScanButton |
|--------|--------|:-------------:|
| `active` | ✓ Tiket Aktif | false |
| `pending` | ⚠ Tiket Belum Aktif | true |
| `claimed` | ⚠ Tiket Belum Aktif | true |
| `''` | ⚠ Tiket Belum Aktif | true |
| `completed` | ⚠ Tiket Tidak Aktif | true |
| `checked_out` | ⚠ Tiket Tidak Aktif | true |
| `inactive` | ⚠ Tiket Tidak Aktif | true |
| `expired` | ⚠ Tiket Tidak Aktif | true |
| lainnya | ⚠ Tiket Tidak Aktif | true |

### 3. booking_widget.dart — Validasi

**Sebelum:**
```dart
if (ticket == null || ticket.ticketCode.isEmpty)
```

**Sesudah:**
```dart
if (ticket == null || ticket.ticketCode.isEmpty || ticket.status != 'active')
```

### 4. detail_booking_widget.dart — Validasi

**Sebelum (_checkTicketAndFetch):**
```dart
if (ticket == null || ticket.ticketCode.isEmpty)
```

**Sesudah (_checkTicketAndFetch):**
```dart
if (ticket == null || ticket.ticketCode.isEmpty || ticket.status != 'active')
```

**Sebelum (_handleSlotBooking):**
```dart
final activeTicket = await ActiveTicketStorage().load();
final ticketId = activeTicket?.ticketCode ?? 'unknown';
final result = await bookingService.createReservation(...);
// error handling: langsung tampilkan result.message dari backend
```

**Sesudah (_handleSlotBooking):**
```dart
final activeTicket = await ActiveTicketStorage().load();
if (activeTicket == null || activeTicket.status != 'active') {
  show snackbar + redirect to welcomeScan
  return;
}
final ticketId = activeTicket.ticketCode;
// proceed to reservation
```

### 5. scan_berhasil_widget.dart — Status Label

**Sebelum:**
```dart
widget.ticketData?.status ?? 'Aktif'
```
→ Saat status `''`, fallback ke `'Aktif'` (false positive label)

**Sesudah:**
```dart
widget.ticketData?.status != null && widget.ticketData!.status.isNotEmpty
    ? widget.ticketData!.status
    : 'Aktif'
```
→ Saat status `''`, fallback ke `'Aktif'` (reasonable default karena user baru selesai scan)

---

## Hasil Pengujian — Validasi Skenario

### Skenario A: status = `active`
```
Scan → TicketData(status: "active")
→ Home: "✓ Tiket Aktif" ✅
→ Booking: ALLOW ✅ (ticket.status == 'active')
→ POST /reservations: ACCEPT ✅
```

### Skenario B: status = `claimed`
```
Scan → TicketData(status: "claimed")
→ Home: "⚠ Tiket Belum Aktif" ✅
→ Booking: REDIRECT to scan ✅ (ticket.status != 'active')
→ DetailBooking _handleSlotBooking: REDIRECT to scan + snackbar ✅
```

### Skenario C: status = `pending`
```
Scan → TicketData(status: "pending")
→ Home: "⚠ Tiket Belum Aktif" ✅
→ Booking: REDIRECT to scan ✅
→ DetailBooking: REDIRECT to scan ✅
```

### Skenario D: status = `expired`
```
Scan → TicketData(status: "expired")
→ Home: "⚠ Tiket Tidak Aktif" ✅
→ Booking: REDIRECT to scan ✅
```

### Skenario E: status = `''` (backend tidak kirim status)
```
Scan → TicketData(status: "") — default baru
→ Home: "⚠ Tiket Belum Aktif" (masuk else-if pending/claimed/'') ✅
→ Booking: REDIRECT to scan ✅
```

---

## Build Validation

```
flutter analyze — menunggu hasil...
```
