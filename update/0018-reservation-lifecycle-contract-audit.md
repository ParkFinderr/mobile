# Task 0018 — Reservation Lifecycle Contract Audit

## Tanggal
2026-06-10

## Status
✅ Selesai — Audit only, no code changes.

---

## 1. Ringkasan Eksekutif

| Aspek | Temuan |
|-------|--------|
| **Endpoint tersedia** | 6 endpoint lifecycle terverifikasi |
| **Frontend coverage** | 2/6 (33%) — hanya Create + CancelTicket |
| **Endpoint belum dipakai** | arrive, complete, history (API), detail |
| **History frontend** | 8 item hardcoded, tidak real |
| **Status timer** | Tidak jalan (setState increment biasa) |
| **Critical finding** | `cancelTicket` vs `complete` — kemungkinan duplicate/salah flow |
| **Testing blocker** | Tidak bisa buat reservation real — butuh valid `ticketId` dari admin QR generator |

---

## 2. Endpoint Verification

### 2.1 POST /reservations — Create Reservation

```
POST /reservations
Authorization: Bearer <JWT>
Content-Type: application/json
```

**Request Body** (dari frontend `booking_service.dart:91-96`):
```json
{
  "slotId": "3QHzrYhMBlPtpJ0xklOe",
  "ticketId": "r8an2ye14aN6dkZ1ifGW",
  "name": "Reservation Audit",
  "plateNumber": "B 1000 RT"
}
```

**Test Results:**

| Scenario | HTTP | Body |
|----------|------|------|
| No `ticketId` | 400 | `"Ticket ID wajib disertakan."` |
| With `vehicleType` field | 400 | `"vehicleType is not allowed"` |
| Invalid `ticketId` | 404 | `"Tiket tidak ditemukan."` |
| Valid request (untested) | 200 | **Unknown** — needs pre-existing ticket |

**Known fields from frontend contract:**

| Field | Required | Notes |
|-------|----------|-------|
| `slotId` | ✅ | Slot yang dipilih |
| `ticketId` | ✅ | Dari hasil scan QR (`ticketCode`) |
| `name` | ✅ | Dari user profile |
| `plateNumber` | ✅ | Dari kendaraan pertama user |
| `vehicleType` | ❌ | `"is not allowed"` — backend reject |

---

### 2.2 PATCH /reservations/{reservationId}/arrive — Arrive at Slot

| Aspek | Value |
|-------|-------|
| Method | `PATCH` |
| Auth | ❔ Tidak bisa diverifikasi (reservation tidak ditemukan dulu) |
| Success | Tidak bisa diverifikasi |
| Error (fake ID) | 404 `"Reservasi tidak ditemukan."` |
| Error (no auth) | 404 `"Reservasi tidak ditemukan."` (sama — tidak cek auth dulu) |

**Tidak bisa di-test sepenuhnya** karena butuh reservation valid yang memiliki status BOOKED.

---

### 2.3 PATCH /reservations/{reservationId}/complete — Complete Parking

| Aspek | Value |
|-------|-------|
| Method | `PATCH` |
| Auth | ❔ Tidak bisa diverifikasi |
| Success | Tidak bisa diverifikasi |
| Error (fake ID) | 404 `"Reservasi tidak ditemukan."` |

---

### 2.4 GET /users/{userId}/reservations — History

| Aspek | Value |
|-------|-------|
| Method | `GET` |
| Auth | ✅ Required |
| Success (empty) | 200 `{"success":true, "message":"Riwayat reservasi user berhasil diambil.", "data":[]}` |
| Success (with data) | Tidak bisa diverifikasi |
| Pagination | Tidak terlihat (data kosong) |

**Response Structure:**
```json
{
  "success": true,
  "message": "Riwayat reservasi user berhasil diambil.",
  "data": [
    // Array of reservation objects (unknown structure — no data)
  ]
}
```

---

### 2.5 GET /reservations/{reservationId} — Reservation Detail

| Aspek | Value |
|-------|-------|
| Method | `GET` |
| Auth | ✅ Required |
| Error (fake ID) | 404 `"Tidak ada tiket aktif"` |
| Catatan | Error message berbeda dari arrive/complete → mungkin lookup berbeda |

> ⚠️ **Temuan**: Error message `"Tidak ada tiket aktif"` menunjukkan endpoint ini mungkin mencari **ticket aktif**, bukan reservation. Berbeda dengan arrive/complete yang bilang `"Reservasi tidak ditemukan."`.

---

### 2.6 POST /access/cancelTicket — Cancel / Exit

| Aspek | Value |
|-------|-------|
| Method | `POST` |
| Auth | ✅ Required |
| Error (invalid ticketId, with auth) | 404 `"Tiket tidak ditemukan."` |
| Error (no auth) | 401 `"Identitas pengguna tidak ditemukan."` |
| Success response | `CancelResult {success, message}` (dari `parking_service.dart`) |

**Request:**
```json
{
  "ticketId": "ticketCode_from_scanned_ticket"
}
```

---

## 3. Reservation Lifecycle

### 3.1 End-to-End Flow (Theoretical — Berdasarkan Endpoint)

```
 [Admin] QR Generator ──→ Tiket dibuat di database
                              │
 [User]  Scan QR ──→ POST /access/verify ──→ TicketData {ticketId, status:"claimed", ...}
                              │
 [User]  Pilih Slot ──→ POST /reservations {slotId, ticketId, ...} ──→ Reservation created
                              │
 [User]  Tiba di Slot ──→ PATCH /reservations/{id}/arrive ──→ status: ARRIVED
                              │
 [User]  Selesai Parkir ──→ PATCH /reservations/{id}/complete ──→ status: COMPLETED
                              │
 [User]  Lihat Riwayat ──→ GET /users/{userId}/reservations ──→ Array of reservations
```

### 3.2 Status Mapping (Estimated)

| Status | Deskripsi | Di-set oleh |
|--------|-----------|-------------|
| `claimed` | Tiket sudah dipakai (dari verify) | POST /access/verify |
| `active` / `booked` | Reservasi dibuat | POST /reservations |
| `arrived` | User tiba di slot | PATCH /arrive |
| `completed` | Selesai parkir | PATCH /complete |
| `cancelled` | Dibatalkan | POST /access/cancelTicket |

⚠️ **Ini estimasi** — tidak bisa diverifikasi karena tidak bisa membuat reservation real.

---

## 4. Critical Question: cancelTicket vs complete

| Aspek | `cancelTicket` | `PATCH complete` |
|-------|---------------|------------------|
| Endpoint | `POST /access/cancelTicket` | `PATCH /reservations/{id}/complete` |
| Input | `ticketId` | reservation ID (dari path) |
| Operasi | Cancel tiket | Complete reservasi |
| Dipakai frontend? | ✅ Ya (StatusKendaraan → Keluar Parkir) | ❌ Tidak |

### Temuan

- `cancelTicket` beroperasi di **ticket level** (membatalkan tiket)
- `PATCH complete` beroperasi di **reservation level** (menyelesaikan reservasi)
- Keduanya mungkin perlu dipanggil **berurutan**:
  1. `PATCH complete` → selesaikan reservasi, hitung biaya
  2. `POST /access/cancelTicket` → bebaskan tiket

Atau mungkin `cancelTicket` adalah satu-satunya exit flow jika backend tidak punya konsep "complete" terpisah. **Tidak bisa diverifikasi tanpa reservation real.**

### Rekomendasi

**Implementasi sementara**: Pertahankan `cancelTicket` sebagai exit flow (yang sekarang). Jika di task berikutnya ditemukan bahwa backend mengharuskan `PATCH complete`, ubah flow menjadi:

```
Keluar Parkir → PATCH /reservations/{id}/complete → POST /access/cancelTicket
```

---

## 5. Data Contract Verification

### 5.1 Postulated Reservation Fields

Berdasarkan endpoint structure dan kebutuhan frontend:

| Field | Sumber | Frontend | Status |
|-------|--------|----------|--------|
| `reservationId` | POST /reservations response | ❌ Tidak disimpan | 🔴 **Critical** — needed for arrive/complete |
| `ticketId` | POST /access/verify | ✅ `ticketCode` | ✅ |
| `slotId` | POST /reservations request | ✅ Dikirim | ✅ |
| `areaId` | POST /access/verify | ❌ Tidak dipakai | ⚠️ Tersedia |
| `areaName` | POST /access/verify | ❌ Tidak dipakai | ⚠️ Tersedia |
| `status` | Backend lifecycle | ❌ Tidak dipakai | ⚠️ Tersedia |
| `plateNumber` | POST /reservations request | ✅ Dikirim | ✅ |
| `vehicleType` | POST /access/verify | ✅ Dipakai display | ✅ |
| `createdAt` | POST /reservations response | ❌ Tidak dipakai | ⚠️ Tersedia |
| `arrivedAt` | PATCH arrive response | ❌ Tidak ada | 🔴 **Tidak ada di frontend** |
| `completedAt` | PATCH complete response | ❌ Tidak ada | 🔴 **Tidak ada di frontend** |

### 5.2 History Fields

Frontend `HistoryCardWidget` menampilkan:

| Field Display | Frontend Field | Backend Source | Status |
|---------------|---------------|----------------|--------|
| Waktu Dari | `dari`, `tglDari` | ❌ Hardcoded | ❌ |
| Waktu Hingga | `hingga`, `tglHingga` | ❌ Hardcoded | ❌ |
| Slot Parkir | `slotParkir` | ❌ Hardcoded | ❌ |
| ID Tiket | `idTiket` | ❌ Hardcoded `TXT-...` | ❌ |
| Kendaraan | `kendaraan` | ❌ Hardcoded | ❌ |

**Semua field hardcoded.** Tidak ada real data dari API.

---

## 6. Frontend Gap Analysis

### 6.1 Feature Coverage

| Feature | Backend | Frontend | File | Line |
|---------|---------|----------|------|------|
| **Create Reservation** | ✅ POST /reservations | ✅ `BookingService.createReservation()` | `booking_service.dart` | 87-108 |
| **Arrive at Slot** | ✅ PATCH /arrive | ❌ **Tidak ada** | — | — |
| **Complete Parking** | ✅ PATCH /complete | ❌ **Tidak ada** | — | — |
| **History (API)** | ✅ GET /users/{id}/reservations | ❌ **Hardcoded** | `history_widget.dart` | 64-75 |
| **Reservation Detail** | ✅ GET /reservations/{id} | ❌ **Tidak ada** | — | — |
| **Cancel Ticket** | ✅ POST /access/cancelTicket | ✅ `ParkingService.cancelTicket()` | `parking_service.dart` | 7-27 |

**Coverage: 2/6 = 33%**

### 6.2 Critical Gaps

| Gap | Dampak | Severity |
|-----|--------|----------|
| **No arrive flow** | User tidak bisa menandai kedatangan di slot. Backend mungkin tidak tahu status real-time. | 🔴 High |
| **No complete flow** | Backend slot mungkin tidak pernah dibebaskan (completedAt tidak pernah terisi) | 🔴 **Critical** |
| **Reservation ID not saved** | Tidak bisa panggil arrive/complete tanpa reservationId | 🔴 **Critical** |
| **History hardcoded** | User melihat data palsu | 🟡 Medium |
| **cancelTicket misuse** | Mungkin bukan exit flow yang benar | 🟡 Medium |

### 6.3 File Impact Analysis

Jika arrive/complete akan diimplementasi (di task berikutnya), file yang terdampak:

| File | Change |
|------|--------|
| `booking_service.dart` | Return `reservationId` dari response POST /reservations |
| `detail_booking_widget.dart` | Simpan `reservationId` setelah booking success |
| `status_kendaraan_page.dart` | Ganti flow: cancelTicket → arrive → complete → cancelTicket |
| `parking_service.dart` | Tambah method `arrive(reservationId)`, `complete(reservationId)` |
| `history_widget.dart` | Replace hardcoded data dengan panggilan API |
| `history_card_widget.dart` | Mungkin perlu refactor field mapping |
| `agenda.md` | Track lifecycle fitur baru |

---

## 7. Testing Limitation

### Root Cause: Tidak Bisa Membuat Reservation Real

**Blocking issue**: Semua lifecycle testing (`arrive`, `complete`, `detail`, `history`) membutuhkan reservation ID yang valid. Saya tidak bisa membuat reservation karena `POST /reservations` membutuhkan `ticketId` yang valid, dan ticket hanya bisa dibuat oleh **admin QR generator** (proyek terpisah).

### Yang Bisa Dilakukan Tanpa Reservation:

| Endpoint | Bisa Test? | Hasil |
|----------|-----------|-------|
| POST /reservations | ✅ (error only) | Contract terverifikasi |
| PATCH /arrive | ⚠️ Error only | 404 "Reservasi tidak ditemukan" |
| PATCH /complete | ⚠️ Error only | 404 "Reservasi tidak ditemukan" |
| GET /users/{id}/reservations | ✅ Empty | Struktur terverifikasi |
| GET /reservations/{id} | ⚠️ Error only | 404 "Tidak ada tiket aktif" |
| POST /access/cancelTicket | ⚠️ Error only | 404 "Tiket tidak ditemukan" |

### Unblock Strategy untuk Task 0019

Untuk bisa melakukan testing end-to-end penuh, diperlukan salah satu:

| Opsi | Cara | Kepastian |
|------|------|-----------|
| **A** | Minta admin generate ticket QR code untuk testing | Tertinggi |
| **B** | Temukan endpoint API yang bisa create ticket (admin endpoint belum ditemukan) | Menengah |
| **C** | Simulasikan response backend di frontend dengan mock data | Rendah (tidak real) |

---

## 8. Risiko Implementasi

| Risiko | Dampak | Mitigasi |
|--------|--------|----------|
| Backend punya lifecycle berbeda dari asumsi | Implementasi ulang arrive/complete | Verifikasi dengan ticket real di task berikutnya |
| `cancelTicket` sudah mencakup fungsi `complete` | Duplikasi effort | Tanya backend owner |
| Response `GET /reservations/{id}` tidak match field frontend | Refactor mapping | Dokumentasikan response saat ada data |
| Status values tidak match dengan asumsi | UI status salah | Dokumentasikan semua status values |
| Arrive/complete mungkin butuh request body khusus | Implementasi tidak lengkap | Test dengan reservation real |

---

## 9. Rekomendasi Task Berikutnya

| Priority | Task | Description |
|----------|------|-------------|
| 🔴 **P0** | **Unblock reservation testing** | Dapatkan valid ticketId dari admin QR generator atau endpoint create ticket |
| 🔴 **P1** | **Implement arrive flow** | `PATCH /reservations/{id}/arrive` setelah booking success |
| 🔴 **P1** | **Fix booking response handling** | Simpan `reservationId` dari response POST /reservations |
| 🔴 **P1** | **Implement complete flow** | `PATCH /reservations/{id}/complete` di Keluar Parkir |
| 🟡 **P2** | **Replace history hardcoded data** | `GET /users/{userId}/reservations` |
| 🟡 **P2** | **Add reservation detail page** | `GET /reservations/{id}` |
| 🟢 **P3** | **Verify cancelTicket vs complete** | Konfirmasi ke backend owner |

---

## Validasi Checklist

- [x] POST /reservations — request body verified (4 fields required, vehicleType rejected)
- [x] PATCH /reservations/{id}/arrive — 404 error verified
- [x] PATCH /reservations/{id}/complete — 404 error verified
- [x] GET /users/{userId}/reservations — 200 empty verified
- [x] GET /reservations/{id} — 404 verified (different msg from arrive/complete)
- [x] POST /access/cancelTicket — auth required, 404 ticket not found verified
- [x] TicketData model — all 7 fields from /access/verify mapped
- [x] Frontend gap analysis — 2/6 features covered
- [x] Lifecycle diagram — documented based on endpoint pattern
- [x] Critical question — cancelTicket vs complete documented
- [ ] ❌ End-to-end lifecycle — BLOCKED (no valid ticketId)
