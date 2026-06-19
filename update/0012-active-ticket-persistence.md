# Update 0012 — Active Ticket Persistence (SharedPreferences)

## Tanggal
2026-06-10

## Status
✅ Selesai — 0 errors, 0 warnings (flutter analyze)

## Perubahan

### 1. `lib/features/welcome_scan/service/scan_service.dart`
- **TicketData model diperluas**: tambah field `vehicleType`, `areaId`, `areaName`, `bindingId` dari API response.
- Tambah `toJson()` method untuk serialisasi ke SharedPreferences.
- `fromJson()` mapping: `ticketId` (backend) → `ticketCode` (frontend).

### 2. `lib/core/storage/active_ticket_storage.dart` (BARU)
- Class `ActiveTicketStorage` dengan 3 method:
  - `save(TicketData)` — serialize ke JSON, simpan di SharedPreferences key `active_ticket`.
  - `load()` — baca dari SharedPreferences, parse JSON → `TicketData?`.
  - `clear()` — hapus key `active_ticket`.
- Persisten app restart (SharedPreferences = disk).

### 3. `lib/features/welcome_scan/widget/welcome_scan_widget.dart`
- Setelah `scanService.verifyTicket()` sukses, panggil `ActiveTicketStorage().save(result)` **sebelum** navigasi ke ScanBerhasil.
- Import `ActiveTicketStorage`.

### 4. `lib/features/detail_booking/widget/detail_booking_widget.dart`
- **Hapus hardcoded** `final ticketId = "ticket-user-123"` (line 183).
- Ganti dengan: `final activeTicket = await ActiveTicketStorage().load(); final ticketId = activeTicket?.ticketCode ?? 'unknown';`
- Import `ActiveTicketStorage`.

### 5. `lib/features/home/page/status_kendaraan_page.dart`
- Tambah state `TicketData? _activeTicket`, load dari `ActiveTicketStorage` di initState.
- **Ganti hardcoded**:
  - `'McLaren Senna'` → `_activeTicket?.vehicleType.toUpperCase() ?? 'KENDARAAN'`
  - `'D 12345 FE'` → `_activeTicket?.areaName ?? '—'`
  - `'A3'` (slot) → `'Lokasi Parkir'` dengan value `_activeTicket?.areaName`
  - `'Lantai 1'` → `'Tipe Kendaraan'` dengan value `_activeTicket?.vehicleType.toUpperCase()`
- **Keluar Parkir**: sekaligus `await ActiveTicketStorage().clear()` sebelum navigasi Home.
- Import `ActiveTicketStorage`, `TicketData` (dari scan_service.dart).
- Hapus unused import `ApiService`.

## Dampak

| Sebelum | Sesudah |
|---------|---------|
| ticketId hardcoded `"ticket-user-123"` di booking | ticketId real dari hasil scan |
| StatusKendaraan: data statis (McLaren, D 12345 FE, A3, Lantai 1) | StatusKendaraan: data dari active ticket (areaName, vehicleType) |
| Keluar Parkir: hanya navigasi, tidak cleanup | Keluar Parkir: hapus active ticket + navigasi |
| Tidak ada persistence antar session | Active ticket tersimpan di SharedPreferences (tahan restart app) |
| ScanBerhasil → Home: ticketId hilang | Ticket tersimpan di SharedPreferences, bisa dibaca kapan saja |

## Data Flow

```
WelcomeScan (scan QR)
  → POST /access/verify → TicketData
  → ActiveTicketStorage.save(ticket)
  → Navigasi ke ScanBerhasil (show ticket)

DetailBooking (booking slot)
  → ActiveTicketStorage.load() → ticketId real
  → POST /reservations(slotId, ticketId, ...)

StatusKendaraan
  → ActiveTicketStorage.load() → areaName, vehicleType
  → Tampilkan data real (bukan hardcoded)

Keluar Parkir
  → ActiveTicketStorage.clear()
  → Navigasi ke Home
```

## Catatan
- `POST /access/verify` masih `requireAuth: true` — perlu diubah ke `false` jika ingin guest scan. Namun berdasarkan testing task 0010, endpoint ini bekerja tanpa auth.
- `GET /access/active-session` belum ada di backend — StatusKendaraan tidak bisa dapat data real-time (timer, slot, floor). Data saat ini hanya dari hasil scan.
- `POST /access/cancelTicket` sudah ada di backend tapi belum diintegrasikan di tombol Keluar Parkir — saat ini hanya clear lokal.
