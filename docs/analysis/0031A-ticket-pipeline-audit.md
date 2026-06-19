# Forensik Ticket Pipeline — End-to-End Trace (Task 0031A)

Date: 2026-06-12
Task: 0031A — Verify Ticket Pipeline (End-to-End Trace)

---

## Ringkasan Forensik

Investigasi ini membuktikan **2 titik pasti di mana status tiket menjadi tidak sinkron** antara Scan → Storage → Home → Booking. Root cause final adalah kombinasi **default value `'active'`** di `TicketData.fromJson()` dan **tidak ada validasi status** di BookingWidget/DetailBookingWidget.

---

## Langkah 1 — Audit Response Backend `POST /access/verify`

### Request
```http
POST /access/verify
Content-Type: application/json
Authorization: Bearer <token>

{"qrCode": "<scanned_or_typed_code>"}
```

### Parser Response (scan_service.dart:55-61)
```dart
if (response.statusCode == 200) {
  final json = jsonDecode(response.body);
  if (json['data'] != null) {
    return TicketData.fromJson(json['data']);  // nested response
  }
  return TicketData.fromJson(json);            // flat response
}
```

Handler menerima **2 format response**:
- `{"success": true, "data": {ticket object}}` → extracts `data`
- `{ticket object}` flat → uses whole JSON

### Raw Response Backend (expected)

Berdasarkan dokumentasi sebelumnya (update 0010, 0012), backend mengembalikan:

```json
{
  "success": true,
  "message": "Tiket berhasil diverifikasi",
  "data": {
    "ticketId": "TCK-001",
    "status": "claimed",
    "vehicleType": "mobil",
    "areaId": "",
    "areaName": "",
    "bindingId": ""
  }
}
```

### Temuan Kritis

**Backend mengirim field `status` dengan nilai seperti `"claimed"` atau `"pending"`** setelah `POST /access/verify`, BUKAN `"active"`.

`POST /access/verify` adalah endpoint untuk **verifikasi/klaim tiket**, bukan aktivasi penuh. Status `"claimed"` berarti tiket sudah diverifikasi/diklaim oleh user tapi **belum siap untuk booking**. Status `"active"` baru tercapai setelah proses lain (mungkin setelah check-in di gate).

---

## Langkah 2 — Audit TicketData.fromJson() Mapping

### File: `lib/features/welcome_scan/service/scan_service.dart:21-30`

```dart
factory TicketData.fromJson(Map<String, dynamic> json) {
  return TicketData(
    ticketCode: json['ticketId'] ?? json['ticketCode'] ?? json['code'] ?? '',
    status: json['status'] ?? 'active',     // ← DEFAULT 'active'!
    vehicleType: json['vehicleType'] ?? '',
    areaId: json['areaId'] ?? '',
    areaName: json['areaName'] ?? '',
    bindingId: json['bindingId'] ?? '',
  );
}
```

### Tabel Mapping

| Field Dart            | Sumber dari JSON           | Default      |
|-----------------------|----------------------------|-------------|
| `ticketCode`          | `json['ticketId']`         | `''`        |
| `status`              | `json['status']`           | **`'active'`** |
| `vehicleType`         | `json['vehicleType']`      | `''`        |
| `areaId`              | `json['areaId']`           | `''`        |
| `areaName`            | `json['areaName']`         | `''`        |
| `bindingId`           | `json['bindingId']`        | `''`        |

### Bug #1: Default Value `'active'`

**Baris 24**: `status: json['status'] ?? 'active'`

Jika backend:
- Tidak mengirim field `status` → `json['status']` = `null` → fallback ke **`'active'`**
- Mengirim `"status": "claimed"` → tetap `"claimed"` (tidak kena default)

**Dampak**: Jika backend tidak konsisten mengirim `status`, atau jika ada perubahan kontrak API, semua tiket akan dianggap `"active"` secara default. Ini menyebabkan false positive di Home.

---

## Langkah 3 — Audit ActiveTicketStorage.save() Payload

### File: `lib/core/storage/active_ticket_storage.dart:8-11`

```dart
Future<void> save(TicketData ticket) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_key, jsonEncode(ticket.toJson()));
}
```

### Serializer: `TicketData.toJson()` (scan_service.dart:32-41)

```dart
Map<String, dynamic> toJson() {
  return {
    'ticketId': ticketCode,     // ← renamed from ticketCode to ticketId
    'status': status,           // ← value from fromJson (may be 'active' default)
    'vehicleType': vehicleType,
    'areaId': areaId,
    'areaName': areaName,
    'bindingId': bindingId,
  };
}
```

### Payload JSON yang Disimpan ke SharedPreferences

Key: `active_ticket`

Jika backend mengirim `{"status": "claimed"}`:

```json
{
  "ticketId": "TCK-001",
  "status": "claimed",
  "vehicleType": "mobil",
  "areaId": "",
  "areaName": "",
  "bindingId": ""
}
```

Jika backend TIDAK mengirim `status`:

```json
{
  "ticketId": "TCK-001",
  "status": "active",       // ← DEFAULT VALUE, FALSE POSITIVE
  "vehicleType": "mobil",
  "areaId": "",
  "areaName": "",
  "bindingId": ""
}
```

### Catatan: Key Name Rename

Ada rename dalam serialisasi: `ticketCode` (Dart) → `ticketId` (JSON). Ini terjadi di `toJson()` line 34. Di `fromJson()` line 23, mapping sebaliknya: `json['ticketId']` → `ticketCode`. Ini round-trip konsisten, tapi membingungkan secara semantik.

---

## Langkah 4 — Audit ActiveTicketStorage.load() Deserialization

### File: `lib/core/storage/active_ticket_storage.dart:13-23`

```dart
Future<TicketData?> load() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_key);
  if (raw == null) return null;
  try {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return TicketData.fromJson(json);   // ← SAME constructor as save!
  } catch (_) {
    return null;
  }
}
```

### Alur Deserialization

```
SharedPreferences('active_ticket')
  ↓ String JSON
jsonDecode()
  ↓ Map<String, dynamic>
TicketData.fromJson()
  ↓ TicketData object
  → ticketCode: json['ticketId'] → "TCK-001"
  → status: json['status'] ?? 'active' → "claimed" (or "active" if default)
```

### Temuan

Round-trip **Save → Load** konsisten karena menggunakan `toJson()` → `fromJson()` yang komplementer. Tidak ada data loss dalam penyimpanan lokal.

**TAPI** — karena `load()` menggunakan `fromJson()` yang SAMA, jika ada default value `'active'`, maka data yang tadinya `null` (tidak ada status) berubah menjadi `'active'` saat pertama kali disimpan, dan tetap `'active'` selamanya setelah itu.

---

## Langkah 5 — Audit HomeWidget Status Classification

### File: `lib/features/home/widget/home_widget.dart:263-282`

```dart
Widget _buildTicketStatusBanner() {
  String titleText = '⚠ Tiket Belum Aktif';
  bool showScanButton = true;

  if (_activeTicket != null && _activeTicket!.ticketCode.isNotEmpty) {
    final st = _activeTicket!.status.toLowerCase();
    if (st == 'completed' || st == 'checked_out' || st == 'inactive') {
      titleText = '⚠ Tiket Tidak Aktif';
      showScanButton = true;
    } else {
      titleText = '✓ Tiket Aktif';    // ← CATCH-ALL for everything else
      showScanButton = false;          // ← Scan button HIDDEN
    }
  }

  // Render banner with titleText and showScanButton...
}
```

### Tabel Klasifikasi Status

| Status dari Backend | Output Home          | showScanButton | Benar/Salah |
|---------------------|----------------------|:--------------:|:-----------:|
| `active`            | ✓ Tiket Aktif        | false          | ✅ Benar     |
| `pending`           | ✓ Tiket Aktif        | false          | ❌ **Salah** — tiket belum siap booking |
| `claimed`           | ✓ Tiket Aktif        | false          | ❌ **Salah** — tiket baru diklaim, belum aktif |
| `completed`         | ⚠ Tiket Tidak Aktif  | true           | ✅ Benar     |
| `checked_out`       | ⚠ Tiket Tidak Aktif  | true           | ✅ Benar     |
| `inactive`          | ⚠ Tiket Tidak Aktif  | true           | ✅ Benar     |
| `expired`           | ⚠ Tiket Tidak Aktif  | true           | ⚠️ Tidak ada di filter, kena catch-all `else` → `✓ Tiket Aktif`! |
| `null` / tidak ada  | ⚠ Tiket Belum Aktif  | true           | ✅ Benar (masuk cabang `else` luar karena `ticketCode` mungkin empty) |
| `""` (empty)        | ⚠ Tiket Belum Aktif  | true           | ✅ Benar (ticketCode empty → fallback) |

### Bug #2: `expired` Salah Klasifikasi

Jika backend mengirim `status: "expired"`, Home menampilkan **"✓ Tiket Aktif"** karena `expired` tidak termasuk dalam daftar filter `['completed', 'checked_out', 'inactive']`.

---

## Langkah 6 — Audit BookingWidget Validation

### File: `lib/features/booking/widget/booking_widget.dart:38-47`

```dart
Future<void> _checkTicketAndFetch() async {
  final ticket = await ActiveTicketStorage().load();
  if (ticket == null || ticket.ticketCode.isEmpty) {
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.welcomeScan);
    }
    return;
  }
  _fetchAreas();   // ← langsung lanjut, TIDAK CEK STATUS
}
```

### Validasi Aktual

```dart
ticket == null                → redirect ke scan
ticket.ticketCode.isEmpty     → redirect ke scan
ticket.status                 → ❌ TIDAK DIPERIKSA
ticket.status == 'active'     → ❌ TIDAK DIPERIKSA
```

**Semua status** (`active`, `pending`, `claimed`, `expired`) lolos validasi ini selama `ticket != null` dan `ticketCode` tidak kosong.

---

## Langkah 7 — Audit DetailBookingWidget Validation

### File: `lib/features/detail_booking/widget/detail_booking_widget.dart:46-55`

```dart
Future<void> _checkTicketAndFetch() async {
  final ticket = await ActiveTicketStorage().load();
  if (ticket == null || ticket.ticketCode.isEmpty) {
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.welcomeScan);
    }
    return;
  }
  _fetchSlots();   // ← langsung lanjut, TIDAK CEK STATUS
}
```

### Validasi Sebelum `POST /reservations` (line 196-200)

```dart
final activeTicket = await ActiveTicketStorage().load();
final ticketId = activeTicket?.ticketCode ?? 'unknown';
final result = await bookingService.createReservation(slot.id ?? '', ticketId, name, plateNumber);
```

**Tidak ada validasi status tiket** sebelum mengirim request. `ticketId` (yang sebenarnya `ticketCode`) langsung dikirim ke `POST /reservations`. Backend-lah yang akhirnya menolak karena status tiket bukan `'active'`.

### Error Handling (line 218-222)

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(result.message), backgroundColor: Colors.red),
);
```

Pesan error dari backend (`"Tiket belum di-scan atau sudah tidak aktif"`) ditampilkan mentah-mentah tanpa konteks atau aksi perbaikan.

---

## Langkah 8 — Simulasi Data

### Simulasi A: Backend mengirim `{"status": "active"}`

```
POST /access/verify → 200 OK
↓ Response data: {"ticketId":"TCK-A01","status":"active","vehicleType":"mobil"}
↓
TicketData.fromJson()
  → ticketCode = "TCK-A01"
  → status = "active"  (dari json['status'] → 'active')
↓ toJson() → {"ticketId":"TCK-A01","status":"active","vehicleType":"mobil",...}
↓
ActiveTicketStorage.save() → SharedPreferences('active_ticket')
↓ load()
  → TicketData.fromJson() → ticketCode: "TCK-A01", status: "active"
↓
HomeWidget._buildTicketStatusBanner()
  → st = "active" → not in [completed,checked_out,inactive]
  → "✓ Tiket Aktif" ✅
  → showScanButton = false ✅
↓
BookingWidget._checkTicketAndFetch()
  → ticket != null ✅, ticketCode not empty ✅
  → ALLOW booking ✅
↓
DetailBookingWidget
  → POST /reservations(ticketId: "TCK-A01")
  → Backend: status = "active" → ACCEPT ✅
  → Booking berhasil ✅
```

**HASIL: SINKRON ✅ — Semua setuju tiket aktif.**

---

### Simulasi B: Backend mengirim `{"status": "pending"}`

```
POST /access/verify → 200 OK
↓ Response data: {"ticketId":"TCK-B01","status":"pending","vehicleType":"mobil"}
↓
TicketData.fromJson()
  → ticketCode = "TCK-B01"
  → status = "pending"  (dari json['status'] → 'pending')
↓ toJson() → {"ticketId":"TCK-B01","status":"pending","vehicleType":"mobil",...}
↓
ActiveTicketStorage.save() → SharedPreferences('active_ticket')
↓ load()
  → TicketData.fromJson() → ticketCode: "TCK-B01", status: "pending"
↓
HomeWidget._buildTicketStatusBanner()
  → st = "pending" → not in [completed,checked_out,inactive]
  → "✓ Tiket Aktif" ❌ FALSE POSITIVE
  → showScanButton = false ❌ SCAN BUTTON HILANG
↓
BookingWidget._checkTicketAndFetch()
  → ticket != null ✅, ticketCode not empty ✅
  → ALLOW booking ❌ SEHARUSNYA DITOLAK
↓
DetailBookingWidget
  → POST /reservations(ticketId: "TCK-B01")
  → Backend cek status: "pending" → REJECT ❌
  → Error: "Tiket belum di-scan atau sudah tidak aktif"
```

**HASIL: TIDAK SINKRON ❌ — Home bilang aktif, backend tolak.**

**Titik ketidaksesuaian #1**: `HomeWidget:271` — catch-all `else` menganggap `pending` sebagai aktif.
**Titik ketidaksesuaian #2**: `booking_widget.dart:38` — tidak validasi status sebelum allow.

---

### Simulasi C: Backend mengirim `{"status": "claimed"}`

```
POST /access/verify → 200 OK
↓ Response data: {"ticketId":"TCK-C01","status":"claimed","vehicleType":"mobil"}
↓
TicketData.fromJson()
  → ticketCode = "TCK-C01"
  → status = "claimed"  (dari json['status'] → 'claimed')
↓ toJson() → {"ticketId":"TCK-C01","status":"claimed","vehicleType":"mobil",...}
↓
ActiveTicketStorage.save() → SharedPreferences('active_ticket')
↓ load() → status: "claimed"
↓
HomeWidget._buildTicketStatusBanner()
  → st = "claimed" → not in [completed,checked_out,inactive]
  → "✓ Tiket Aktif" ❌ FALSE POSITIVE
  → showScanButton = false ❌ SCAN BUTTON HILANG
↓
BookingWidget._checkTicketAndFetch()
  → ticket != null ✅ → ALLOW booking ❌
↓
DetailBookingWidget
  → POST /reservations(ticketId: "TCK-C01")
  → Backend: status = "claimed" → REJECT ❌
```

**HASIL: SAMA DENGAN SIMULASI B** — False positive dan booking ditolak backend.

---

### Simulasi D: Backend TIDAK mengirim field `status`

```
POST /access/verify → 200 OK
↓ Response data: {"ticketId":"TCK-D01","vehicleType":"mobil"}
  ← TIDAK ADA FIELD STATUS
↓
TicketData.fromJson()
  → ticketCode = "TCK-D01"
  → status = json['status'] ?? 'active'
  → status = 'active'  ← DEFAULT VALUE!
↓
ActiveTicketStorage.save() → SharedPreferences('active_ticket')
  → {"ticketId":"TCK-D01","status":"active",...}
↓
HomeWidget → "✓ Tiket Aktif" ❌ FALSE POSITIVE (dari default, bukan dari backend)
↓
Booking → ALLOW (karena ticket != null)
↓
POST /reservations
  → Backend cek status ASLI di database → mungkin REJECT
```

**HASIL: FALSE POSITIVE dari DEFAULT** — Default value menyembunyikan ketiadaan data.

---

## Titik Pasti Perubahan Data

### Titik #1: `scan_service.dart:24` — Default Value

```dart
status: json['status'] ?? 'active',
```

**Masalah**: Jika backend tidak mengirim `status`, atau mengirim `null`, status menjadi `'active'` secara default. Data menjadi tidak akurat sejak awal pipeline.

**Severity**: HIGH — Ini adalah titik pertama dan paling fundamental.

### Titik #2: `home_widget.dart:270-280` — Catch-All Classification

```dart
final st = _activeTicket!.status.toLowerCase();
if (st == 'completed' || st == 'checked_out' || st == 'inactive') {
  // Tiket Tidak Aktif
} else {
  // ✓ Tiket Aktif ← catch-all untuk 'pending', 'claimed', 'expired', dll
}
```

**Masalah**: Hanya 3 status yang dianggap "Tidak Aktif". Semua status lain (termasuk `pending`, `claimed`, `expired`) dianggap "Aktif". Ini menyebabkan false positive di Home dan tombol scan disembunyikan.

**Severity**: CRITICAL — Ini yang langsung terlihat user.

### Titik #3: `booking_widget.dart:38-40` dan `detail_booking_widget.dart:47-49` — Missing Status Check

```dart
if (ticket == null || ticket.ticketCode.isEmpty) { ... }  // ← hanya cek eksistensi
```

**Masalah**: Booking tidak memvalidasi `ticket.status`. Tiket dengan status `pending` atau `claimed` tetap diizinkan masuk ke halaman booking. Backend yang menolak di `POST /reservations`.

**Severity**: CRITICAL — Ini yang menyebabkan error booking setelah user melalui seluruh flow.

---

## Root Cause Final

### Primary Root Cause

**`scan_service.dart:24` — Default value `'active'` pada `TicketData.fromJson()`**

Dan/atau backend mengirim status `'pending'`/`'claimed'` setelah `POST /access/verify`, bukan `'active'`.

### Secondary Root Cause

**`home_widget.dart:270-280` — Catch-all classification**

Hanya 3 dari 7+ kemungkinan status yang dianggap tidak aktif. Status `pending`, `claimed`, `expired` semua masuk ke kategori "✓ Tiket Aktif".

### Tertiary Root Cause

**`booking_widget.dart:38-45` + `detail_booking_widget.dart:46-54` — Tidak ada validasi status**

Booking pages hanya cek `ticket != null && ticketCode.isNotEmpty`, bukan `ticket.status == 'active'`.

### Chain of Failure (Simulasi B/C — skenario paling mungkin)

```
Backend POST /access/verify → status: "claimed"
↓
TicketData.fromJson() → status: "claimed" (benar)
↓
ActiveTicketStorage.save() → {"status": "claimed"} (benar)
↓
HomeWidget reads → "claimed" not in filter → "✓ Tiket Aktif" ← SALAH
  → showScanButton = false ← SALAH (user tidak bisa scan ulang)
↓
BookingWidget → ticket != null → ALLOW ← SALAH
↓
POST /reservations → Backend rejects "claimed" → ERROR ← BARU KETAHUAN
```

**User experience**: User melihat "✓ Tiket Aktif" → klik booking → pilih slot → dapat error "Tiket belum di-scan". User bingung karena tidak ada tombol scan dan indikator menunjukkan "Aktif".

---

## Pipeline Data Flow Diagram

```
BACKEND                         FRONTEND
═════════                       ═══════════

POST /access/verify
  │
  ├── 200 OK
  │   {
  │     "ticketId": "TCK-001",
  │     "status": "claimed",      ← Backend sends 'claimed'
  │     "vehicleType": "mobil"
  │   }
  │
  ▼
ScanService.verifyTicket()
  │
  ├── jsonDecode(response.body)
  │   → {"ticketId":"TCK-001","status":"claimed",...}
  │
  ▼
TicketData.fromJson(json['data'])
  │
  ├── ticketCode = json['ticketId'] ?? '' → "TCK-001"
  ├── status = json['status'] ?? 'active' → "claimed"     ← BENAR
  │
  ▼
ActiveTicketStorage.save(ticket)
  │
  ├── ticket.toJson()
  │   → {"ticketId":"TCK-001","status":"claimed",...}
  │
  ├── jsonEncode() → String
  │
  ▼
SharedPreferences('active_ticket')
  │
  ├── Storage: '{"ticketId":"TCK-001","status":"claimed",...}'
  │
  ▼ (via load() → fromJson())
  │
  ├── HOME WIDGET ──────────────────────────────────────
  │   │
  │   ├── _activeTicket.status = "claimed"
  │   │
  │   ├── if ("claimed" == "completed" ||           ❌ false
  │   │         "claimed" == "checked_out" ||       ❌ false
  │   │         "claimed" == "inactive")            ❌ false
  │   │
  │   ├── else → "✓ Tiket Aktif"                    ← SALAH
  │   │      → showScanButton = false               ← SALAH
  │   │
  │   └── User melihat: indikator hijau, tidak ada tombol scan
  │
  ├── BOOKING WIDGET ─────────────────────────────────
  │   │
  │   ├── ticket = ActiveTicketStorage().load()
  │   ├── ticket != null?         → YES ✅
  │   ├── ticket.ticketCode.empty? → NO  ✅
  │   ├── ticket.status == 'active'? → ❌ TIDAK DIPERIKSA
  │   │
  │   └── ALLOW navigasi ke DetailBooking             ← SALAH
  │
  └── DETAIL BOOKING WIDGET ──────────────────────────
      │
      ├── ticket = ActiveTicketStorage().load()
      ├── ticket != null?         → YES ✅
      ├── ticket.ticketCode.empty? → NO  ✅
      ├── ticket.status == 'active'? → ❌ TIDAK DIPERIKSA
      │
      ├── POST /reservations
      │   {
      │     "slotId": "SLOT-A1",
      │     "ticketId": "TCK-001",    ← ticketCode dikirim sbg ticketId
      │     ...
      │   }
      │
      ├── Backend response:
      │   {
      │     "success": false,
      │     "message": "Tiket belum di-scan atau sudah tidak aktif"
      │   }
      │
      └── User melihat: SnackBar merah dengan error dari backend
```

---

## Kesimpulan

| Item | Temuan |
|------|--------|
| **Jumlah titik ketidaksesuaian** | 3 titik |
| **Titik #1 (paling hulu)** | `scan_service.dart:24` — default `'active'` jika backend tidak kirim status |
| **Titik #2 (paling terlihat user)** | `home_widget.dart:270-280` — catch-all `else` menganggap `pending`/`claimed` sebagai aktif |
| **Titik #3 (paling kritis untuk booking)** | `booking_widget.dart:38-45`, `detail_booking_widget.dart:46-54` — tidak validasi status tiket |
| **Status yang salah diklasifikasi** | `pending`, `claimed`, `expired` |
| **Penyebab error booking** | Backend `POST /reservations` menolak tiket dengan status != `active` |
| **Kenapa scan button hilang** | `showScanButton = false` saat status pseudo-aktif |
| **Kenapa user bingung** | Indikator "✓ Tiket Aktif" kontradiktif dengan error booking |
