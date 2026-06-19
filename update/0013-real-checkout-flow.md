# Update 0013 — Real Checkout Flow (POST /access/cancelTicket)

## Tanggal
2026-06-10

## Status
✅ Selesai — 0 errors, 0 new warnings (flutter analyze)

## Audit Endpoint

### `POST /access/cancelTicket`

| Item | Hasil |
|------|-------|
| URL | `POST /access/cancelTicket` |
| Body field | `ticketId` (wajib) — maps ke `TicketData.ticketCode` |
| Auth | ✅ Wajib (`requireAuth: true`) — tanpa auth: `"Identitas pengguna tidak ditemukan"`, token invalid: `"Token tidak valid."` |
| Status code | 200 success |
| Response format | `{"success": bool, "message": string, "data": null}` |

## Perubahan

### 1. `lib/features/home/service/parking_service.dart` (BARU)
- Class `ParkingService` dengan method `cancelTicket(String ticketId)`.
- Method: `POST /access/cancelTicket` dengan body `{'ticketId': ticketId}`, `requireAuth: true`.
- Mengembalikan `CancelResult { success, message }`.
- Error handling: try/catch, parse JSON, fallback message jika gagal.

### 2. `lib/features/home/page/status_kendaraan_page.dart`
- Tambah state `bool _isCancelling` untuk loading state.
- Tambah method `Future<void> _onKeluarParkir()` sebagai handler tombol.
- **Flow baru**:
  1. Cek `_activeTicket != null` — jika null, langsung clear lokal + Home.
  2. Set `_isCancelling = true` → button disabled + spinner.
  3. Panggil `ParkingService().cancelTicket(ticketCode)`.
  4. **Sukses**: clear `ActiveTicketStorage` → snackbar hijau → Home.
  5. **Gagal**: jangan hapus storage → dialog error merah → user bisa coba lagi.
- Button disabled saat `_isCancelling` dengan `CircularProgressIndicator`.

## Flow Diagram

```
Sebelum:
  Keluar Parkir → ActiveTicketStorage.clear() → Home

Sesudah:
  Keluar Parkir
    → loading state (button disabled + spinner)
    → POST /access/cancelTicket {ticketId}
    ├── sukses: clear storage → snackbar sukses → Home
    └── gagal:  dialog error → storage tetap → user bisa retry
```

## Validation

| Requirement | Status | Cara |
|-------------|--------|------|
| Ticket aktif dicancel via backend | ✅ | `ParkingService.cancelTicket()` call API |
| Backend menerima request | ✅ | Body `{'ticketId': ticket.ticketCode}`, auth JWT |
| Storage hanya dihapus jika API sukses | ✅ | `ActiveTicketStorage.clear()` hanya di branch `result.success` |
| Restart app tidak kembalikan ticket yg sudah dicancel | ✅ | Storage sudah di-clear sebelum navigasi Home |

## Error States

| State | UI |
|-------|----|
| **loading** | Button disabled, `CircularProgressIndicator` putih di dalam button |
| **success** | Snackbar hijau dengan message dari API, navigasi ke Home |
| **API error** | `AlertDialog` dengan judul "Gagal", pesan error, tombol "Tutup" — storage tidak dihapus |
| **no ticket** | Fallback: clear storage langsung + Home (safety net) |
