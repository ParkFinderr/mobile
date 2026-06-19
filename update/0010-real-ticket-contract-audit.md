# Update 0010

Date: 2026-06-10
Task: Real Ticket Verification Audit

---

# Implementation Report

## Task Summary

Verifikasi response aktual backend `POST /access/verify` menggunakan ticket code real `PF-1781053819508-cdecb9f9`. Dokumentasi seluruh field response dan mapping ke kebutuhan frontend.

---

## Test Execution

### Request

```
POST /access/verify
Content-Type: application/json

{
  "qrCode": "PF-1781053819508-cdecb9f9"
}
```

**Tanpa auth** — endpoint bekerja untuk guest scan tanpa JWT.

### Full Response (200 OK)

```json
{
  "success": true,
  "message": "Tiket valid. Selamat datang di Jurusan Teknik Elektro Unila!",
  "data": {
    "ticketId": "r8an2ye14aN6dkZ1ifGW",
    "vehicleType": "mobil",
    "areaId": "BWOjPZoajWmF3kJA62Fe",
    "areaName": "Jurusan Teknik Elektro Unila",
    "userType": "guest",
    "bindingId": "guest-0cae4153-bdc2-4b71-a316-2feae2245a8d",
    "status": "claimed"
  }
}
```

### Auth Behavior

| Auth | Response | Keterangan |
|------|----------|------------|
| ❌ Tanpa auth | ✅ **200** — data lengkap | Endpoint bisa diakses tanpa login |
| ✅ Dengan JWT valid | ✅ **200** — data lengkap | (diasumsikan sama) |
| ⚠️ Token kadaluarsa | ❌ **401** — `"Sesi kadaluarsa. Silakan login kembali atau scan sebagai tamu."` | Token expired handling |

**Temuan penting**: Endpoint dapat digunakan TANPA autentikasi. Service layer di frontend (`ScanService`) mengirim `requireAuth: true`, tapi backend tetap return 200 tanpa token. Ini berarti `requireAuth: false` juga akan berfungsi.

---

## Field Analysis

| # | Field | Tipe Data | Value Contoh | Dipakai Frontend? | Bisa Dipakai Untuk |
|---|-------|-----------|-------------|-------------------|-------------------|
| 1 | `ticketId` | `string` | `"r8an2ye14aN6dkZ1ifGW"` | ❌ | 🔥 **Menggantikan ticketId hardcoded** `"ticket-user-123"` di DetailBooking saat booking |
| 2 | `vehicleType` | `string` | `"mobil"` | ❌ | Menampilkan tipe kendaraan di ScanBerhasil / StatusKendaraan |
| 3 | `areaId` | `string` | `"BWOjPZoajWmF3kJA62Fe"` | ❌ | Navigasi langsung ke DetailBooking dengan areaId valid |
| 4 | `areaName` | `string` | `"Jurusan Teknik Elektro Unila"` | ❌ | 🔥 **Menggantikan title hardcoded** `"Teknik Elektro Universitas Lampung"` di DetailBooking |
| 5 | `userType` | `string` | `"guest"` | ❌ | Informasi tipe user (guest vs registered) |
| 6 | `bindingId` | `string` | `"guest-0cae4153-bdc2-4b71-a316-2feae2245a8d"` | ❌ | Session binding identifier |
| 7 | `status` | `string` | `"claimed"` | ❌ | Status tiket — bisa menggantikan status hardcoded `"Aktif"` |

**Total**: 7 field — **0 field dipakai frontend saat ini**, **2 field kritis** untuk menggantikan hardcoded data.

---

## Field Status Mapping

### `status` — Nilai yang Mungkin

| Nilai | Arti | Visual |
|-------|------|--------|
| `claimed` | Tiket sudah dipakai/di-claim | Kuning/Orange |
| `active` | Tiket aktif | Hijau |
| `expired` | Tiket kadaluarsa | Merah |
| `pending` | Tiket menunggu aktivasi | Abu-abu |

Frontend saat ini cuma handle `status == 'active'` → hijau "Aktif". Perlu diperluas.

---

## Gap Analysis: Frontend vs Backend Response

### Data Hardcoded yang Bisa Digantikan

| Lokasi | Hardcoded Saat Ini | Field Response | Prioritas |
|--------|-------------------|----------------|-----------|
| `scan_berhasil_widget.dart:174` | Ticket code | `ticketId` — **SUDAH diimplementasi** di task 0009 🎉 | ✅ Done |
| `scan_berhasil_widget.dart:201-216` | Status "Aktif" | `status` | 🟡 Medium |
| `detail_booking_widget.dart:109` | Title `"Teknik Elektro Universitas Lampung"` | `areaName` | 🟡 Medium |
| `detail_booking_widget.dart:183` | ticketId `"ticket-user-123"` | `ticketId` | 🔴 High |
| `status_kendaraan_page.dart:87-96` | Vehicle `"McLaren Senna"` + Plate `"D 12345 FE"` | ❌ Tidak ada di response ini | 🔴 Butuh endpoint lain |

### Catatan: Response ini adalah untuk guest scan. Jika user registered, backend mungkin return field tambahan:

| Field Mungkin Ada (Registered) | Kegunaan |
|-------------------------------|----------|
| `name` | Nama user |
| `plateNumber` | Plat nomor kendaraan |
| `slotNumber` | Nomor slot yang dibooking |

Perlu verifikasi dengan JWT valid untuk konfirmasi.

---

## Perbaikan `TicketData` Model

Berdasarkan response aktual, model `TicketData` di `scan_service.dart` perlu diperbarui:

```dart
class TicketData {
  final String ticketCode;    // ← dari ticketId
  final String status;        // ← dari status
  final String vehicleType;   // ← BARU — dari vehicleType
  final String areaId;        // ← BARU — dari areaId
  final String areaName;      // ← BARU — dari areaName
  final String bindingId;     // ← BARU — dari bindingId

  TicketData({
    required this.ticketCode,
    required this.status,
    this.vehicleType = '',
    this.areaId = '',
    this.areaName = '',
    this.bindingId = '',
  });

  factory TicketData.fromJson(Map<String, dynamic> json) {
    return TicketData(
      ticketCode: json['ticketId'] ?? json['ticketCode'] ?? '',
      status: json['status'] ?? 'active',
      vehicleType: json['vehicleType'] ?? '',
      areaId: json['areaId'] ?? '',
      areaName: json['areaName'] ?? '',
      bindingId: json['bindingId'] ?? '',
    );
  }
}
```

**Field name penting**: Backend menggunakan `ticketId` (bukan `ticketCode`). Frontend perlu mapping `ticketId → ticketCode`.

---

## Endpoint Auth Behavior — Implikasi

| Temuan | Implikasi |
|--------|-----------|
| Endpoint bekerja tanpa JWT | Frontend bisa panggil tanpa `requireAuth: true` |
| Endpoint juga menerima JWT | User registered tetap bisa scan dengan token |
| Guest vs Registered response | Mungkin berbeda (registered dapat field tambahan seperti plateNumber) |

**Rekomendasi**: Ubah `ScanService` untuk tidak memerlukan auth (guest scan flow), tapi tetap kirim token jika ada (registered flow).

---

## Known Issues

1. **Ticket sudah ter-claim** — call pertama sukses (200), call kedua gagal ("Tiket ini SUDAH digunakan"). Artinya ticket bersifat one-time-use.
2. **Hanya 1 ticket real yang diuji** — belum bisa membandingkan response guest vs registered.
3. **Field `ticketId` vs `ticketCode`** — backend return `ticketId`, frontend mengharapkan `ticketCode`. Perlu mapping di `TicketData.fromJson()`.

---

## Recommended Next Steps

1. **🔴 High** — Update `TicketData` model: tambah semua 7 field dari response, mapping `ticketId → ticketCode`
2. **🔴 High** — Ganti `ticketId` hardcoded `"ticket-user-123"` di DetailBooking dengan `ticketData.ticketCode` (dari hasil scan)
3. **🟡 Medium** — Ganti title hardcoded DetailBooking dengan `areaName` dari response
4. **🟡 Medium** — Ubah `ScanService` untuk guest mode (`requireAuth: false`)
5. **🟡 Medium** — Perluas status handling: `claimed`, `active`, `expired`, `pending`
6. **🟢 Low** — Verifikasi response registered user (butuh JWT valid)

---

## Executive Summary

1. **Endpoint `POST /access/verify`** mengembalikan **7 field** untuk ticket valid
2. **2 field kritis**: `ticketId` (ganti hardcoded di Booking) dan `areaName` (ganti title hardcoded DetailBooking)
3. **0 dari 7 field** saat ini digunakan frontend — semuanya potensial
4. **Endpoint bekerja tanpa auth** — guest scan flow sudah benar
5. **Ticket bersifat one-time-use** — call kedua return error "sudah digunakan"
6. **Status "claimed"** — bukan "active" — frontend perlu handle multiple status values
7. **Field `ticketId`** adalah primary identifier (bukan `ticketCode` seperti asumsi sebelumnya)
8. **Vehicle type, area info** tersedia — bisa dipakai untuk StatusKendaraan
9. **Registered user** mungkin dapat field tambahan (perlu verifikasi)
10. **Prioritas**: Update TicketData model → ganti hardcoded ticketId → ganti title DetailBooking → guest mode ScanService
