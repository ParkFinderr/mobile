# Task 0033 — Audit & Fix Ticket Activation Flow

Date: 2026-06-12
Task: 0033 — Audit & Fix Ticket Activation Flow

---

## Latar Belakang

Setelah Task 0032 memperbaiki klasifikasi status di Home dan Booking, ditemukan bahwa status tiket yang disimpan dari `POST /access/verify` adalah `claimed`, bukan `active`. Backend menyediakan endpoint `GET /access/activeTicket` untuk mendapatkan tiket yang benar-benar aktif, namun endpoint ini **tidak pernah dipanggil** oleh frontend.

---

## Root Cause

| # | Masalah | Detail |
|---|---------|--------|
| 1 | **Missing API call** | Frontend hanya memanggil `POST /access/verify` (kembali `claimed`) dan menyimpan hasilnya langsung. Tidak ada panggilan `GET /access/activeTicket` untuk mendapatkan status `active` yang sebenarnya. |
| 2 | **Wrong source of truth** | HomeScreen membaca status tiket hanya dari `ActiveTicketStorage` (local cache), tanpa pernah merefresh dari backend API |
| 3 | **`_hasActiveTicket` logic** | Boolean hanya cek `ticket != null && ticketCode.isNotEmpty`, bukan `ticket.status == 'active'` |
| 4 | **No API fallback** | Tidak ada mekanisme refresh data dari backend saat halaman di-load |

---

## Flow Lama (Bermasalah)

```
POST /access/verify {"qrCode": "TCK-001"}
  ↓
Response: {"status": "claimed", "ticketId": "TCK-001", ...}
  ↓ (langsung disimpan)
ActiveTicketStorage.save(ticket with status "claimed")
  ↓
Home._checkActiveTicket() → read from ActiveTicketStorage
  → ticket.status = "claimed"
  → not in [active] → "⚠ Tiket Belum Aktif" ❌

Booking._checkTicketAndFetch() → read from ActiveTicketStorage
  → ticket.status = "claimed" → ticket.status != "active"
  → redirect to scan ❌
```

**Masalah**: Backend mengirim `status: "claimed"` setelah `POST /access/verify`, tapi untuk booking diperlukan `status: "active"` yang hanya bisa didapat dari `GET /access/activeTicket`.

---

## Flow Baru (Diperbaiki)

```
POST /access/verify {"qrCode": "TCK-001"}
  ↓
Response: {"status": "claimed", "ticketId": "TCK-001", ...}
  ↓
GET /access/activeTicket (dipanggil setelah verify sukses)
  ↓
Response: {"status": "active", "ticketId": "TCK-001", ...}
  ↓
ActiveTicketStorage.save(ticket with status "active") ✅
  ↓
Home._checkActiveTicket()
  → GET /access/activeTicket (refresh dari API)
  → Update ActiveTicketStorage
  → ticket.status = "active"
  → "✓ Tiket Aktif" ✅

Booking._checkTicketAndFetch()
  → ticket.status = "active"
  → ALLOW booking ✅
```

---

## File yang Dibuat

| File | Deskripsi |
|------|-----------|
| `lib/features/access/service/access_service.dart` | Service baru untuk `GET /access/activeTicket` |

## File yang Diubah

| File | Perubahan |
|------|-----------|
| `lib/features/welcome_scan/widget/welcome_scan_widget.dart` | Setelah `POST /access/verify` sukses, panggil `GET /access/activeTicket` dan simpan hasilnya |
| `lib/features/home/widget/home_widget.dart` | `_checkActiveTicket()` panggil API dulu, fallback ke local; `_hasActiveTicket` cek `status == 'active'` |
| `lib/features/home/page/status_kendaraan_page.dart` | `_loadActiveTicket()` panggil API dulu, fallback ke local |

---

## Daftar Mock Data / Hardcoded yang Dihilangkan

| Sebelum | Sesudah | File |
|---------|---------|------|
| `_hasActiveTicket = ticket != null && ticket.ticketCode.isNotEmpty` | `_hasActiveTicket = ticket != null && ticket.ticketCode.isNotEmpty && ticket.status == 'active'` | `home_widget.dart:69` |
| Hanya baca dari `ActiveTicketStorage().load()` | Panggil `AccessService().getActiveTicket()` dulu, simpan, baru baca dari storage | `home_widget.dart:63-73`, `status_kendaraan_page.dart:46-54` |
| Scan flow langsung simpan hasil `verifyTicket` | Verify → `getActiveTicket` → simpan hasil `activeTicket` | `welcome_scan_widget.dart:77-84, 119-126` |

---

## Endpoint yang Digunakan

### POST /access/verify
```
URL: /access/verify
Method: POST
Auth: Bearer token
Body: {"qrCode": "TCK-001"}
Response 200: {"success":true,"data":{"ticketId":"...","status":"claimed",...}}
```

### GET /access/activeTicket (BARU — sebelumnya tidak dipakai)
```
URL: /access/activeTicket
Method: GET
Auth: Bearer token
Response 200: {"success":true,"data":{"ticketId":"...","status":"active",...}}
Response 404: {"success":false,"message":"No active ticket"}
```

---

## Hasil Pengujian

### Skenario A: Scan + Booking lengkap
```
1. Scan tiket → POST /access/verify → {"status":"claimed"}
2. GET /access/activeTicket → {"status":"active"}
3. Simpan ke ActiveTicketStorage
4. Home: "✓ Tiket Aktif" ✅
5. Booking: ALLOW ✅
```

### Skenario B: Refresh Home (app restart)
```
1. Home.initState() → _checkActiveTicket()
2. GET /access/activeTicket
3. Jika sukses → update storage → "✓ Tiket Aktif" ✅
4. Jika gagal (404/no ticket) → fallback ke storage → "⚠ Tiket Belum Aktif" ✅
```

### Skenario C: Booking setelah scan
```
1. BookingWidget._checkTicketAndFetch()
2. ActiveTicketStorage.load() → ticket.status == "active"
3. ALLOW booking ✅
```

---

## Build Validation

```
flutter analyze → 0 errors ✅
flutter build web → Built pwa ✅
```
