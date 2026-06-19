# Update 0031A

Date: 2026-06-12
Task: 0031A — Verify Ticket Pipeline (End-to-End Trace)

---

# Implementation Report

## Task Summary

Forensik pipeline tiket dari `POST /access/verify` → `TicketData.fromJson()` → `ActiveTicketStorage` → `HomeWidget` → `BookingWidget` → `POST /reservations`. Target: menemukan titik pasti di mana status tiket menjadi tidak sinkron.

---

## Changes Made

### Added
- `docs/analysis/0031A-ticket-pipeline-audit.md` — laporan forensik pipeline tiket

### Modified
- None (investigasi murni)

### Removed
- None

---

## Files Created

```
docs/analysis/0031A-ticket-pipeline-audit.md
```

---

## Files Modified

```
None
```

---

## Files Removed

```
None
```

---

## Dependencies Added

```
None
```

---

## Dependencies Removed

```
None
```

---

## Folder Structure Changes

```
None
```

---

## Technical Details

### 3 Titik Pasti Ketidaksesuaian Status Tiket

| Titik | File | Baris | Masalah |
|-------|------|-------|---------|
| **#1** | `scan_service.dart` | 24 | `status: json['status'] ?? 'active'` — default `'active'` menutupi ketiadaan data |
| **#2** | `home_widget.dart` | 270-280 | Catch-all `else` menganggap `pending`/`claimed`/`expired` sebagai "✓ Tiket Aktif" |
| **#3** | `booking_widget.dart` + `detail_booking_widget.dart` | 38-45, 46-54 | Hanya cek `ticket != null`, tidak ada validasi `ticket.status == 'active'` |

### Simulasi Data (4 Skenario)

| Status Backend | Home Output | Booking | Backend `POST /reservations` | Hasil |
|----------------|-------------|---------|------------------------------|-------|
| `active` | ✓ Tiket Aktif ✅ | ALLOW ✅ | ACCEPT ✅ | Sinkron |
| `pending` | ✓ Tiket Aktif ❌ | ALLOW ❌ | REJECT ❌ | **Tidak sinkron** |
| `claimed` | ✓ Tiket Aktif ❌ | ALLOW ❌ | REJECT ❌ | **Tidak sinkron** |
| (no status) | ✓ Tiket Aktif ❌ (dari default) | ALLOW ❌ | Mungkin REJECT | **Tidak sinkron** |

### Root Cause Final

**Primary**: `scan_service.dart:24` — Default `'active'` menyembunyikan status asli tiket.
**Secondary**: `home_widget.dart:270-280` — Hanya 3/7+ status dianggap tidak aktif.
**Tertiary**: `booking_widget.dart:38-45`, `detail_booking_widget.dart:46-54` — Tidak validasi status tiket.

Chain of failure: Backend kirim `status: "claimed"` → Home tampilkan "✓ Tiket Aktif" → Booking izinkan akses → `POST /reservations` ditolak backend → User lihat error kontradiktif.

---

## Impact Analysis

### User Experience
- User melihat indikator hijau "✓ Tiket Aktif" tapi booking selalu gagal
- Tombol "Scan Tiket" disembunyikan saat status pseudo-aktif
- User tidak punya jalan keluar dari kondisi error

### Performance
- Tidak ada dampak

### Maintainability
- 3 titik kerentanan teridentifikasi dengan line number presisi
- Default value pattern berbahaya untuk field yang menentukan logika bisnis

### Scalability
- Penambahan status backend baru (misal `validated`, `checking_in`) akan otomatis salah diklasifikasi oleh catch-all `else`

---

## Validation Checklist

- [x] Semua klaim diverifikasi dengan kode aktual (file + line number)
- [x] 4 simulasi data telah dilacak end-to-end
- [x] Mapping field telah diverifikasi
- [x] Round-trip serialisasi telah diverifikasi
- [x] Tidak ada perubahan kode — investigasi murni

---

## Known Issues

```
None
```

---

## Technical Debt

1. **Default value `'active'`** — `TicketData.fromJson()` menggunakan default yang menyesatkan (scan_service.dart:24)
2. **Catch-all status** — HomeWidget hanya filter 3 status, sisanya dianggap aktif (home_widget.dart:270-280)
3. **Missing status validation** — Booking pages tidak validasi status tiket (booking_widget.dart:38, detail_booking_widget.dart:46)
4. **Key rename `ticketCode` → `ticketId`** — Membingungkan secara semantik (scan_service.dart:34)
5. **Error handling pasif** — Pesan error backend ditampilkan tanpa aksi perbaikan

---

## Remaining Work

```
Perbaikan akan dilakukan di task terpisah.
File yang perlu diperbaiki:
  - lib/features/welcome_scan/service/scan_service.dart:24
  - lib/features/home/widget/home_widget.dart:269-282
  - lib/features/booking/widget/booking_widget.dart:38-45
  - lib/features/detail_booking/widget/detail_booking_widget.dart:46-54
```

---

## Recommended Next Steps

1. **Fix #1 (scan_service.dart:24)** — Hapus default `'active'`, gunakan `''` atau `'unknown'` agar status asli backend tidak tertutupi
2. **Fix #2 (home_widget.dart:269-282)** — Ganti filter menjadi allowlist: hanya `status == 'active'` yang dianggap "✓ Tiket Aktif"
3. **Fix #3 (booking_widget.dart:38-45, detail_booking_widget.dart:46-54)** — Tambah validasi `ticket.status == 'active'` sebelum izinkan akses ke booking
4. **Validasi backend contract** — Verifikasi nilai `status` apa saja yang dikirim backend untuk `POST /access/verify` dan `POST /reservations`

---

## Executive Summary

1. **3 titik pasti ketidaksesuaian** ditemukan dalam pipeline tiket
2. **Titik #1**: `scan_service.dart:24` — default `'active'` menyembunyikan status asli
3. **Titik #2**: `home_widget.dart:270-280` — catch-all menyebabkan false positive "✓ Tiket Aktif" untuk status `pending`, `claimed`, `expired`
4. **Titik #3**: `booking_widget.dart:38-45`, `detail_booking_widget.dart:46-54` — tidak validasi `ticket.status` sebelum booking
5. **Simulasi membuktikan**: Backend kirim `status: "claimed"` → frontend izinkan booking → backend tolak di `POST /reservations`
6. **4 simulasi** dilacak: A (active ✅), B (pending ❌), C (claimed ❌), D (no status ❌)
7. **Root cause final** adalah kombinasi 3 titik yang menciptakan chain of failure
8. **Efek user**: Lihat "✓ Tiket Aktif" → booking gagal → tidak ada tombol scan → tidak tahu harus apa
9. **Semua temuan** didukung oleh potongan kode aktual dengan line number spesifik
10. **Tidak ada perbaikan dilakukan** — task ini murni forensik untuk Task 0031B (implementasi fix)
