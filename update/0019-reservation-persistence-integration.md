# Task 0019 — Reservation Persistence Integration

## Tanggal
2026-06-10

## Status
✅ Selesai — `flutter analyze` 0 errors

---

## 1. Ringkasan

| Aspek | Sebelum | Sesudah |
|-------|---------|---------|
| `createReservation()` return type | `bool` | `ReservationResult {success, reservationId, status, message}` |
| `reservationId` disimpan? | ❌ Tidak | ✅ `ActiveReservationStorage` |
| `Keluar Parkir` endpoint | `cancelTicket` (salah) | ✅ Prioritaskan `cancelReservation` |
| `cancelTicket` fallback | — | ✅ Jika tidak ada reservation |
| `flutter analyze` | 1 warning | 1 warning (pre-existing) |

---

## 2. Files Changed

### 2.1 `lib/features/booking/service/booking_service.dart`

**Sebelum:**
```dart
Future<bool> createReservation(...) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
        return true;  // ← SEMUA response.data DIBUANG
    }
    return false;
}
```

**Sesudah:**
```dart
Future<ReservationResult> createReservation(...) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        return ReservationResult(
            success: true,
            reservationId: data['reservationId'] ?? '',
            status: data['status'] ?? 'pending',
            message: body['message'] ?? 'Booking berhasil.',
        );
    }
    // Parse error message from response
    return ReservationResult(
        success: false,
        message: body['message'] ?? 'Booking gagal.',
        ...
    );
}
```

### 2.2 `lib/core/storage/active_reservation_storage.dart` — NEW

```dart
class ActiveReservation {
  final String reservationId;
  final String status;
  final String slotId;
  final String slotName;
  final String areaId;
  final String ticketId;
}

class ActiveReservationStorage {
  save(ActiveReservation reservation) → SharedPreferences
  load() → ActiveReservation?
  clear()
}
```

### 2.3 `lib/features/detail_booking/widget/detail_booking_widget.dart`

**Sebelum:**
```dart
final success = await bookingService.createReservation(...);
if (success) { showSnackBar('Booking berhasil!'); }
```

**Sesudah:**
```dart
final result = await bookingService.createReservation(...);
if (result.success && result.reservationId.isNotEmpty) {
    await ActiveReservationStorage().save(ActiveReservation(
        reservationId: result.reservationId,
        status: result.status,
        slotId: slot.id,
        slotName: slot.label,
        areaId: widget.areaId,
        ticketId: ticketId,
    ));
    showSnackBar(result.message);  // real message from backend
}
```

### 2.4 `lib/features/home/service/parking_service.dart`

**Tambah method:**
```dart
Future<CancelResult> cancelReservation(String reservationId) async {
    // PATCH /reservations/{reservationId}/cancel
}
```

**Response backend:**
```json
{"success": true, "message": "Reservasi berhasil dibatalkan."}
```

### 2.5 `lib/features/home/page/status_kendaraan_page.dart`

**Sebelum:**
```dart
Future<void> _onKeluarParkir() async {
    final result = await service.cancelTicket(_activeTicket!.ticketCode);
    // ...
}
```

**Sesudah:**
```dart
Future<void> _onKeluarParkir() async {
    if (_activeReservation != null) {
        result = await service.cancelReservation(_activeReservation!.reservationId);
    } else if (_activeTicket != null) {
        result = await service.cancelTicket(_activeTicket!.ticketCode);
    }
    // Clear both storages on success
    await ActiveTicketStorage().clear();
    await ActiveReservationStorage().clear();
    // ...
}
```

---

## 3. Data Flow Diagram

```
── SEBELUM ─────────────────────────────────────────────────────
                                                                 
  POST /reservations ──→ 201 Created ──→ response.data DIBUANG
                                             │
                                             ▼
                                       bool {success: true}
                                             │
                                       reservationId HILANG
                                             │
                                       cancelTicket(wrong)
                                             
── SESUDAH ──────────────────────────────────────────────────────
                                                                 
  POST /reservations ──→ 201 Created ──→ ReservationResult
                                             │
                                    ┌────────┴────────┐
                                    ▼                 ▼
                           ActiveReservation       SnackBar
                           Storage.save()          message real
                                    │
                            reservationId
                            tersimpan
                                    │
                            ┌───────┴───────┐
                            ▼               ▼
                    PATCH /cancel   cancelTicket
                    (prioritas)     (fallback)
```

---

## 4. Verification with Real Data

### Test Ticket
```
PF-1781060558599-a09c316d
```

### Verify Response
```
ticketId:  s9kf1Z6CmBgfcNtL80ql
areaId:    BWOjPZoajWmF3kJA62Fe
areaName:  Jurusan Teknik Elektro Unila
status:    claimed
```

### Reservation Response
```
reservationId:  gFDwT9ZzjwUa5OEzqrqJ
status:         pending
slotName:       A-01
```

### Cancel Response
```
PATCH /reservations/gFDwT9ZzjwUa5OEzqrqJ/cancel
→ {"success": true, "message": "Reservasi berhasil dibatalkan."}
```

### Slot Verification
```
Setelah booking:   A-01 → "booked"
Setelah cancel:    A-01 → "available" ✅
```

---

## 5. Files Created/Modified

| File | Status | Description |
|------|--------|-------------|
| `lib/features/booking/service/booking_service.dart` | ✅ Modified | `createReservation()` → return `ReservationResult` |
| `lib/core/storage/active_reservation_storage.dart` | ✅ **NEW** | Save/load `ActiveReservation` to SharedPreferences |
| `lib/features/detail_booking/widget/detail_booking_widget.dart` | ✅ Modified | Save reservation after successful booking |
| `lib/features/home/service/parking_service.dart` | ✅ Modified | Added `cancelReservation()` method |
| `lib/features/home/page/status_kendaraan_page.dart` | ✅ Modified | Load reservation + use `cancelReservation` |

---

## 6. Validation Checklist

- [x] `createReservation()` return `ReservationResult` instead of `bool`
- [x] `reservationId` tersimpan ke `ActiveReservationStorage`
- [x] `ActiveReservationStorage` punya `save`, `load`, `clear`
- [x] `detail_booking_widget` save reservation + slot data setelah booking
- [x] `parking_service` punya `cancelReservation(reservationId)`
- [x] `status_kendaraan_page` load reservation dari storage
- [x] `_onKeluarParkir` prioritaskan `cancelReservation`
- [x] `_onKeluarParkir` fallback ke `cancelTicket` jika tanpa reservation
- [x] Kedua storage dibersihkan setelah cancel sukses
- [x] `flutter analyze` — 0 errors
