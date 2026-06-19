# Task 0018B — Real Reservation Verification

## Tanggal
2026-06-10

## Status
✅ Selesai — Semua endpoint diverifikasi dengan reservation real.

---

## 1. VERIFY TICKET — POST /access/verify

**Request:**
```
POST /access/verify
Authorization: Bearer <JWT>
Content-Type: application/json

{"qrCode": "PF-1781060144742-738123ef"}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Tiket valid. Selamat datang di Jurusan Teknik Elektro Unila!",
  "data": {
    "ticketId": "fRsTQF6TF377f0W8orHA",
    "vehicleType": "mobil",
    "areaId": "BWOjPZoajWmF3kJA62Fe",
    "areaName": "Jurusan Teknik Elektro Unila",
    "userType": "registered",
    "bindingId": "YkcQhxw76LQPJeZQeAPT",
    "status": "claimed"
  }
}
```

### Field Analysis

| Field | Value | Notes |
|-------|-------|-------|
| `ticketId` | `fRsTQF6TF377f0W8orHA` | Firestore document ID — **ini yang harus dikirim sebagai `ticketId` ke POST /reservations** |
| `userType` | `registered` | Berbeda dengan task 0010 yang `"guest"` → bindingId = userID (bukan guest UUID) |
| `bindingId` | `YkcQhxw76LQPJeZQeAPT` | Langsung UserID (karena registered user) |
| `status` | `claimed` | Tiket sudah dipakai — one-time-use |

---

## 2. ActiveTicketStorage Audit

### Storage Mechanism
`lib/core/storage/active_ticket_storage.dart`: SharedPreferences → JSON encode/decode.

### Data Flow
```
POST /access/verify → response.data → TicketData.fromJson(json['data']) 
→ ActiveTicketStorage.save(ticketData) 
→ SharedPreferences.setString('active_ticket', jsonEncode(ticketData.toJson()))
```

### TicketData.toJson() Mapping

| Key | Source Field | Value |
|-----|-------------|-------|
| `ticketId` | `ticketCode` | `"fRsTQF6TF377f0W8orHA"` |
| `status` | `status` | `"claimed"` |
| `vehicleType` | `vehicleType` | `"mobil"` |
| `areaId` | `areaId` | `"BWOjPZoajWmF3kJA62Fe"` |
| `areaName` | `areaName` | `"Jurusan Teknik Elektro Unila"` |
| `bindingId` | `bindingId` | `"YkcQhxw76LQPJeZQeAPT"` |

### Gap: Naming Confusion
- `TicketData.ticketCode` menyimpan `ticketId` dari backend
- `TicketData.toJson()` mengirim ulang sebagai `ticketId`
- Ini menyebabkan kebingungan: di `detail_booking_widget.dart:185`, `ticketCode` digunakan sebagai `ticketId` untuk `POST /reservations` — **ini SUDAH BENAR** karena `ticketCode` berisi `ticketId` dari backend.

---

## 3. CREATE RESERVATION — POST /reservations

**Request:**
```
POST /reservations
Authorization: Bearer <JWT>
Content-Type: application/json

{
  "slotId": "3QHzrYhMBlPtpJ0xklOe",
  "ticketId": "fRsTQF6TF377f0W8orHA",
  "name": "Reservation Audit B",
  "plateNumber": "B 1000 RT"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Booking berhasil. Silakan menuju slot parkir.",
  "data": {
    "reservationId": "ufHzXKqCDrvorW4Gunpz",
    "status": "pending",
    "slotName": "A-01",
    "areaId": "BWOjPZoajWmF3kJA62Fe",
    "plateNumber": "B 1000 RT",
    "name": "Reservation Audit B",
    "ticketId": "fRsTQF6TF377f0W8orHA",
    "qrCode": "PF-1781060144742-738123ef",
    "expiryTime": "2026-06-10T03:28:41.672Z"
  }
}
```

### Verified Effects
| Effect | Before | After |
|--------|--------|-------|
| Slot `A-01` status | `"available"` | `"booked"` |
| Slot `A-01` `currentReservationId` | `null` | `"ufHzXKqCDrvorW4Gunpz"` |
| Reservation in history | ❌ Tidak ada | ✅ Muncul |

---

## 4. Reservation Persistence Audit — FRONTEND BUG

### Critical Finding: `reservationId` TIDAK Disimpan

**Lokasi bug:** `lib/features/booking/service/booking_service.dart:87-108`

```dart
Future<bool> createReservation(...) async {
    // ...
    if (response.statusCode == 200 || response.statusCode == 201) {
        return true;  // ← Hanya return bool! response.data diabaikan!
    }
    return false;
}
```

**Dampak:**
- `reservationId` (`ufHzXKqCDrvorW4Gunpz`) tidak pernah sampai ke frontend
- `detail_booking_widget.dart:188` hanya tahu success/fail
- `status_kendaraan_page.dart:91` menggunakan `ticketCode` untuk `cancelTicket`, bukan `reservationId` untuk `PATCH cancel`
- Arrive/complete flow tidak bisa diimplementasi tanpa `reservationId`

### File Impact

| File | Baris | Masalah |
|------|-------|---------|
| `booking_service.dart` | 87-108 | `createReservation()` return `bool`, tidak return response body |
| `detail_booking_widget.dart` | 188 | Tidak simpan `reservationId` |
| `status_kendaraan_page.dart` | 91 | Pakai `cancelTicket` (salah), harusnya `PATCH cancel` atau `PATCH complete` |
| `parking_service.dart` | 7-27 | Tidak ada method `cancelReservation(id)`, `arrive(id)`, `complete(id)` |

---

## 5. RESERVATION DETAIL — GET /reservations/{reservationId}

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Detail reservasi ditemukan.",
  "data": {
    "reservationId": "ufHzXKqCDrvorW4Gunpz",
    "ticketId": "fRsTQF6TF377f0W8orHA",
    "userId": "YkcQhxw76LQPJeZQeAPT",
    "slotId": "3QHzrYhMBlPtpJ0xklOe",
    "areaId": "BWOjPZoajWmF3kJA62Fe",
    "slotName": "A-01",
    "name": "Reservation Audit B",
    "plateNumber": "B 1000 RT",
    "status": "pending",
    "timestamps": {
      "created": "2026-06-10T02:58:41.672Z",
      "arrived": null,
      "completed": null
    },
    "history": []
  }
}
```

### All Available Fields

| Field | Type | Example | Frontend |
|-------|------|---------|----------|
| `reservationId` | string | `ufHzXKqCDrvorW4Gunpz` | ❌ Tidak disimpan |
| `ticketId` | string | `fRsTQF6TF377f0W8orHA` | ✅ Tersedia via ActiveTicketStorage |
| `userId` | string | `YkcQhxw76LQPJeZQeAPT` | ❌ Tidak dipakai |
| `slotId` | string | `3QHzrYhMBlPtpJ0xklOe` | ⚠️ Ada tapi tidak disimpan |
| `areaId` | string | `BWOjPZoajWmF3kJA62Fe` | ⚠️ Tersedia via scan |
| `slotName` | string | `A-01` | ⚠️ Tersedia |
| `name` | string | `Reservation Audit B` | ✅ Dari profile |
| `plateNumber` | string | `B 1000 RT` | ✅ Dari kendaraan |
| `status` | string | `pending` | ❌ Tidak dipakai |
| `timestamps.created` | ISO date | `2026-06-10T02:58:41.672Z` | ❌ Tidak dipakai |
| `timestamps.arrived` | ISO date/null | `null` | ❌ Tidak dipakai |
| `timestamps.completed` | ISO date/null | `null` | ❌ Tidak dipakai |
| `history` | array | `[]` | ❌ Tidak dipakai |

---

## 6. RESERVATION HISTORY — GET /users/{userId}/reservations

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Riwayat reservasi user berhasil diambil.",
  "data": [
    {
      "reservationId": "ufHzXKqCDrvorW4Gunpz",
      "ticketId": "fRsTQF6TF377f0W8orHA",
      "userId": "YkcQhxw76LQPJeZQeAPT",
      "slotId": "3QHzrYhMBlPtpJ0xklOe",
      "areaId": "BWOjPZoajWmF3kJA62Fe",
      "slotName": "A-01",
      "name": "Reservation Audit B",
      "plateNumber": "B 1000 RT",
      "status": "pending",
      "timestamps": {
        "created": "2026-06-10T02:58:41.672Z",
        "arrived": null,
        "completed": null
      },
      "history": [],
      "formattedDuration": "-"
    }
  ]
}
```

### Gap: Frontend History vs Backend Response

| Frontend Field | Backend Field | Status |
|----------------|---------------|--------|
| `dari` (waktu mulai) | `timestamps.created` (perlu format) | ❌ Hardcoded |
| `tglDari` (tanggal) | `timestamps.created` (perlu format) | ❌ Hardcoded |
| `hingga` (waktu selesai) | `timestamps.completed` | ❌ Hardcoded |
| `tglHingga` (tanggal) | `timestamps.completed` | ❌ Hardcoded |
| `slotParkir` | `slotName` + area name | ❌ Hardcoded |
| `idTiket` | `ticketId` | ❌ Hardcoded `TXT-...` |
| `kendaraan` | `plateNumber` | ❌ Hardcoded |

**Semua 7 field hardcoded** di `history_widget.dart:64-75`. Tidak ada data real.

---

## 7. Lifecycle Verification

### Complete Flow Diagram

```
── TIKET LIFECYCLE ─────────────────────────────────────────────
                                                                 
  [Admin] QR Generator ─────→ Tiket dibuat (status: "available")
                                  │
  POST /access/verify ───────────→ status: "claimed"
  (user scans QR code)            │ ticketId diperoleh
                                  │
── RESERVATION LIFECYCLE ────────────────────────────────────────
                                                                 
  POST /reservations ───────────→ status: "pending"
  {slotId, ticketId, name,       slot: "booked"
   plateNumber}                  reservationId diperoleh
                                  │
  PATCH /arrive ─────────────────→ status: "active"
  ⚠️ HANYA jika sensor           timestamps.arrived: ISO date
     mendeteksi kendaraan         │
                                  │
  PATCH /complete ───────────────→ status: "completed"
  ⚠️ HANYA jika status "active"   timestamps.completed: ISO date
                                  │ slot: "available"
                                  │
── ATAU ─────────────────────────────────────────────────────────
                                                                 
  PATCH /cancel ─────────────────→ status: "cancelled"
  {reservationId}                slot: "available"
                                  │
── TIKET EXIT ───────────────────────────────────────────────────
                                                                 
  POST /access/cancelTicket ─────→ HANYA jika tiket TIDAK punya
  ⚠️ GAGAL jika ada reservasi      reservasi aktif
     aktif: pesan minta "batal    (guest flow)
     reservasi" dulu
```

### Status Mapping (VERIFIED)

| Status | Arti | Set Oleh | Frontend? |
|--------|------|----------|-----------|
| `pending` | Menunggu kedatangan | POST /reservations | ❌ Tidak ditampilkan |
| `active` | Kendaraan terdeteksi sensor | PATCH /arrive (via sensor) | ❌ Tidak ada |
| `completed` | Selesai parkir | PATCH /complete | ❌ Tidak ada |
| `cancelled` | Dibatalkan | PATCH /cancel | ❌ Tidak ada |

---

## 8. Critical Question: cancelTicket vs PATCH complete

| Aspek | `cancelTicket` | `PATCH complete` | `PATCH cancel` |
|-------|---------------|------------------|----------------|
| Endpoint | `POST /access/cancelTicket` | `PATCH /reservations/{id}/complete` | `PATCH /reservations/{id}/cancel` |
| Operasi | Cancel tiket | Selesaikan parkir | Batalkan reservasi |
| Saat ada res. aktif | ❌ **GAGAL**: "Gunakan fitur batal reservasi" | ✅ Berfungsi | ✅ Berfungsi |
| Saat tiket tanpa res. | ✅ Berfungsi | ❌ Tidak relevan | ❌ Tidak relevan |
| Auth | ✅ JWT required | ✅ JWT required | ✅ JWT required |

### Jawaban

**Frontend flow saat ini SALAH.** `cancelTicket` hanya untuk guest/scan-only flow. Setelah booking, harusnya pakai `PATCH /reservations/{id}/cancel` untuk batal atau `PATCH /reservations/{id}/complete` (setelah sensor trigger).

**Rekomendasi flow yang benar:**
```
StatusKendaraan → "Keluar Parkir"
  ├── Jika tidak ada booking (guest scan) → POST /access/cancelTicket ✅
  └── Jika ada booking (reservationId tersimpan)
        ├── Jika sensor sudah trigger arrive → PATCH complete
        └── Jika belum arrive → PATCH cancel
```

---

## 9. Frontend Gap Analysis

### Summary Table

| Feature | Backend | Frontend | Gap | Severity |
|---------|---------|----------|-----|----------|
| Verify Ticket | ✅ POST /access/verify | ✅ ScanService.verifyTicket() | ✅ OK | - |
| Create Reservation | ✅ POST /reservations | ✅ BookingService.createReservation() | ⚠️ Return bool, response body dibuang | 🔴 **Critical** |
| Save reservationId | ✅ Ada di response | ❌ Tidak disimpan | 🔴 **Blocking arrive/complete** | 🔴 **Critical** |
| Arrive at Slot | ✅ PATCH /arrive | ❌ Tidak ada | Butuh reservationId + sensor trigger | 🟡 Medium |
| Complete Parking | ✅ PATCH /complete | ❌ Tidak ada | Butuh reservationId + sensor trigger | 🟡 Medium |
| Cancel Reservation | ✅ PATCH /cancel | ❌ Tidak ada | `cancelTicket` salah endpoint | 🔴 **High** |
| Reservation Detail | ✅ GET /reservations/{id} | ❌ Tidak ada | Halaman detail belum dibuat | 🟡 Medium |
| Reservation History | ✅ GET /users/{id}/reservations | ❌ Hardcoded | 8 item dummy | 🟡 Medium |

### Root Cause: `booking_service.dart` Return Type

**File:** `lib/features/booking/service/booking_service.dart:87-108`
```dart
Future<bool> createReservation(...) async {
```
Return `bool` → semua informasi response hilang. Harusnya return object dengan `reservationId`, `status`, dll.

### File Impact Analysis

| File | Baris | Perubahan Diperlukan |
|------|-------|---------------------|
| `booking_service.dart` | 87-108 | `createReservation()` → return `ReservationResult {reservationId, status, success, message}` |
| `detail_booking_widget.dart` | 188 | Simpan `reservationId` setelah booking sukses |
| `storage/active_reservation_storage.dart` | **BARU** | Storage untuk reservationId (mirip ActiveTicketStorage) |
| `parking_service.dart` | 7-50 | Tambah `cancelReservation(id)`, `arrive(id)`, `complete(id)` |
| `status_kendaraan_page.dart` | 80-123 | Ganti `cancelTicket` → `cancelReservation` atau `complete` |
| `history_widget.dart` | 64-75 | Replace hardcoded → panggil `GET /users/{id}/reservations` |

---

## 10. Validation Checklist

- [x] Ticket `PF-1781060144742-738123ef` berhasil diverifikasi → 200 OK ✅
- [x] `ticketId: fRsTQF6TF377f0W8orHA` diperoleh ✅
- [x] Reservation berhasil dibuat → 201 Created ✅
- [x] `reservationId: ufHzXKqCDrvorW4Gunpz` diperoleh ✅
- [x] Reservation detail berhasil dibaca → 200 OK ✅
- [x] Reservation muncul di history → 200 OK (1 item) ✅
- [x] Tidak ada dummy data ✅
- [x] Tidak ada mock response ✅
- [x] `PATCH /arrive` → 400 (butuh sensor) ⚠️
- [x] `PATCH /complete` → 400 (butuh status active) ⚠️
- [x] `cancelTicket` → 400 (reservasi aktif) ⚠️
- [x] `PATCH /cancel` → 200 OK ✅
- [x] Slot kembali available setelah cancel ✅
- [ ] ❌ Frontend tidak simpan `reservationId` → blocking arrive/complete

---

## 11. Root Cause Analysis

### Blocker Task 0018 (sebelumnya)
Tidak bisa membuat reservation karena tidak punya valid ticketId.

### Bloker Task 0018B (sekarang — sudah teratasi)
Ticket `PF-1781060144742-738123ef` valid. Reservation berhasil dibuat.

### Bloker ARRIVE/COMPLETE
`PATCH /arrive` membutuhkan **deteksi sensor fisik** (`"Kendaraan belum terdeteksi oleh sensor"`). Tidak bisa di-simulasi dari API. Flow ini adalah hardware-triggered.

`PATCH /complete` membutuhkan status `"active"` yang hanya bisa dicapai melalui `PATCH /arrive` via sensor.

### Frontend Bug Utama
`createReservation()` return `bool` → `reservationId` tidak pernah disimpan → `cancelTicket` salah endpoint digunakan.

---

## 12. Recommended Next Steps

| Priority | Task | Description |
|----------|------|-------------|
| 🔴 **P0** | Fix `booking_service.dart` | `createReservation()` return `ReservationResult` with `reservationId`, `status`, `message` |
| 🔴 **P0** | Save `reservationId` to storage | Buat `ActiveReservationStorage` simpan `reservationId` + `status` |
| 🔴 **P1** | Add `PATCH /cancel` to `parking_service.dart` | Method `cancelReservation(reservationId)` |
| 🔴 **P1** | Fix `status_kendaraan_page.dart` | Ganti `cancelTicket` → `cancelReservation` |
| 🟡 **P2** | Replace hardcoded history | `GET /users/{userId}/reservations` → `HistoryWidget` |
| 🟡 **P2** | Add arrive/complete methods | Untuk integrasi sensor nanti |
| 🟢 **P3** | Add reservation detail page | `GET /reservations/{id}` → UI detail |
