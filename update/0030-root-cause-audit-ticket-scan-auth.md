# Update 0030

Date: 2026-06-12
Task: 0030 — Root Cause Audit: Ticket State, Scan Flow & Auth Session

---

# Implementation Report

## Task Summary

Investigasi mendalam untuk menemukan root cause dari 3 gejala utama:
1. Home menampilkan "Tiket Aktif" tapi Booking menolak
2. User tidak menemukan jalur menuju halaman scan
3. Session login hilang setelah aplikasi ditutup

Task ini adalah **investigasi murni** — tidak ada perbaikan kode yang dilakukan.

---

## Changes Made

### Added
- `docs/analysis/0030-root-cause-audit-ticket-scan-auth.md` — laporan investigasi lengkap

### Modified
- None (investigasi murni, tidak ada perubahan kode)

### Removed
- None

---

## Files Created

```
docs/analysis/0030-root-cause-audit-ticket-scan-auth.md
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
docs/analysis/
  └── 0030-root-cause-audit-ticket-scan-auth.md  (NEW)
```

---

## Technical Details

### Metodologi Investigasi

1. **Membaca dokumentasi sebelumnya**: docs/analysis/0029, 0028, 0027, 0026, 0024, 0020 + docs/updates/0029, 0023
2. **Membaca seluruh kode sumber** yang terkait dengan 6 area investigasi
3. **Mencari semua keyword**: activeTicket, ActiveTicketStorage, hasTicket, ticketStatus, guestTicket, currentTicket, TicketData, ticketId
4. **Melacak alur data** dari scan → penyimpanan → pembacaan → validasi

### Root Cause Findings

| # | Bug | Root Cause | File Kunci |
|---|-----|------------|------------|
| 1 | False Positive "Tiket Aktif" | Definisi "aktif" terlalu luas — semua status kecuali 3 kata kunci dianggap aktif | `home_widget.dart:269-281` |
| 2 | Scan entry point hilang | Bottom nav tidak punya menu scan; tombol scan banner hilang saat pseudo-aktif | `bottom_nav_bar.dart`, `home_widget.dart:280` |
| 3 | Booking tetap diizinkan | Validasi hanya cek `ticket != null`, tidak cek `ticket.status == 'active'` | `booking_widget.dart:38-45`, `detail_booking_widget.dart:46-54` |
| 4 | Auto-login tidak otomatis | `_goToHome()` hanya dipicu oleh tap tombol, bukan timer | `splash_screen_widget.dart:125-156` |
| 5 | Tidak ada offline trust | Auto-login dependen pada network call yang bisa gagal | `splash_screen_widget.dart:130` |
| 6 | Bottom nav "Kendaraan" mati | Tidak ada `case 2:` handler di semua file | 6 file berbeda |
| 7 | Tidak ada state management | Semua state pakai `setState()` + SharedPreferences tanpa reaktivitas | Seluruh codebase |

---

## Impact Analysis

### User Experience
- **Saat ini**: User melihat kontradiksi (Home bilang "Aktif", Booking bilang tidak bisa)
- **Setelah fix nanti**: Konsistensi antara indikator visual dan fungsi aktual

### Performance
- Tidak ada dampak (investigasi murni)

### Maintainability
- **Ditemukan**: 7 bug + 10 inkonsistensi yang didokumentasikan
- **Ditemukan**: 1 dead feature (route `/tutor-popup` tidak terpakai)
- **Ditemukan**: 1 dead menu (Kendaraan tidak bisa dinavigasi)

### Scalability
- Tidak ada state management pattern — setiap fitur baru akan menambah kompleksitas

---

## Validation Checklist

- [x] Build berhasil — tidak ada perubahan kode
- [x] Tidak ada error lint — tidak ada perubahan kode
- [x] Semua fitur lama tetap berjalan — tidak ada perubahan kode
- [x] Laporan investigasi telah diverifikasi dengan kode aktual
- [x] Semua klaim di laporan didukung oleh potongan kode dan line number

---

## Known Issues

```
None (investigasi murni)
```

---

## Technical Debt

1. **Tidak ada state management** — seluruh aplikasi menggunakan `setState()` + SharedPreferences
2. **Error handling minimal** — try/catch menelan semua detail error
3. **Token tidak di-refresh** — expired token menyebabkan 401 tanpa recovery
4. **Base URL hardcoded** — tidak bisa diganti per environment tanpa rebuild
5. **SharedPreferences tidak aman** — token JWT di localStorage (web) tanpa enkripsi
6. **Register tidak auto-login** — friction tambahan untuk user baru
7. **Route `/tutor-popup` tidak terpakai** — dead code
8. **Menu Kendaraan (index 2) rusak** — dead UI element

---

## Remaining Work

```
Tidak ada — task ini murni investigasi.
Perbaikan akan dilakukan di Task 0031.
```

---

## Recommended Next Steps

1. **Task 0031** — Perbaiki bug prioritas tinggi:
   - Filter status tiket di Home (`status == 'active'`)
   - Validasi status tiket sebelum booking
   - Auto-navigation dari splash screen (timer-based)
2. **Task 0032** — Fix dead menu Kendaraan + cleanup dead route `/tutor-popup`
3. **Task 0033** — Implementasi state management (Bloc/Riverpod) untuk reactive ticket state
4. **Task 0034** — Error handling overhaul (tampilkan pesan backend ke user)
5. **Task 0035** — Implementasi offline auto-login (cache profile + skip validation jika offline)

---

## Executive Summary

1. **3 bug utama ditemukan**: False positive "Tiket Aktif", scan entry point hilang, session login tidak persist
2. **Semua bug saling terkait** — Gejala 1 menyebabkan Gejala 2, dan Gejala 3 independent
3. **7 root cause spesifik** teridentifikasi dengan file dan line number yang jelas
4. **Penyebab paling kritis**: HomeWidget `home_widget.dart:269-281` mendefinisikan "aktif" terlalu luas
5. **Penyebab kedua**: Booking tidak validasi status tiket (`booking_widget.dart:38-45`)
6. **Penyebab ketiga**: Auto-login tidak otomatis (`splash_screen_widget.dart:125-156`)
7. **Masalah fundamental**: Tidak ada state management reaktif — semua state manual via `setState()`
8. **10 inkonsistensi** tambahan ditemukan (status display, SharedPreferences vs cache, dll)
9. **1 dead feature**: route `/tutor-popup` terdaftar tapi tidak pernah dipanggil
10. **1 dead menu**: "Kendaraan" di bottom nav tidak memiliki handler navigasi
