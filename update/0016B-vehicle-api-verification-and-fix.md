# Update 0016B — Vehicle API Verification & Contract Fix

## Tanggal
2026-06-10

## Status
✅ Selesai — `flutter analyze` 0 errors

---

## Audit 1 — Source of Truth Kendaraan

### Endpoint A: `GET /users/profile` (✅ BISA dipakai)
```json
{
  "success": true,
  "data": {
    "vehicles": [
      {
        "plateNumber": "B 5000 V2",
        "vehicleType": "mobil"
      }
    ]
  }
}
```
**Status**: 200 OK — **Ini adalah source of truth kendaraan untuk user biasa.**

### Endpoint B: `GET /users/vehicles` (❌ TIDAK bisa dipakai)
```json
// 403 Forbidden
{
  "success": false,
  "message": "Akses ditolak. Tindakan ini HANYA untuk Super Admin.",
  "data": null
}
```
**Status**: 403 Forbidden — Regular user tidak bisa akses endpoint ini.

---

## Audit 2 — Field Kendaraan Aktual

| Field | Ada di Response? | Tipe |
|-------|-----------------|------|
| `plateNumber` | ✅ | `string` — "B 5000 V2" |
| `vehicleType` | ✅ | `string` — "mobil" / "motor" |
| `id` | ❌ **Tidak ada** | Backend tidak mengembalikan ID |
| `vehicleId` | ❌ Tidak ada | — |
| `_id` | ❌ Tidak ada | — |
| `createdAt` | ❌ Tidak ada | — |

**Kesimpulan**: Vehicle hanya punya 2 field: `plateNumber` + `vehicleType`.

---

## Audit 3 — Create Vehicle

### Request
```json
// POST /users/vehicles
// Authorization: Bearer <JWT>
{
  "plateNumber": "D 6000 V2",
  "vehicleType": "motor"
}
```

### Response
```json
// 201 Created
{
  "success": true,
  "message": "Kendaraan berhasil ditambahkan.",
  "data": {
    "plateNumber": "D 6000 V2",
    "vehicleType": "motor"
  }
}
```

### Verifikasi — Profile After Create
```json
{
  "vehicles": [
    { "plateNumber": "B 5000 V2", "vehicleType": "mobil" },
    { "plateNumber": "D 6000 V2", "vehicleType": "motor" }
  ]
}
```
✅ Vehicle baru muncul di profile.

---

## Audit 4 — Delete Vehicle

### Request
```
DELETE /users/vehicles/D%206000%20V2
Authorization: Bearer <JWT>
```
(Plate number URL-encoded sebagai path parameter)

### Response
```json
// 200 OK
{
  "success": true,
  "message": "Kendaraan dengan Plat D 6000 V2 berhasil dihapus.",
  "data": null
}
```

### Verifikasi — Profile After Delete
```json
{
  "vehicles": [
    { "plateNumber": "B 5000 V2", "vehicleType": "mobil" }
  ]
}
```
✅ Vehicle berhasil dihapus dan hilang dari profile.

### Catatan DELETE
| Approach | Hasil |
|----------|-------|
| `DELETE /users/vehicles/{plateNumber}` (URL-encoded) | ✅ 200 OK |
| `DELETE /users/vehicles` with body `{plateNumber}` | ❌ 403 Super Admin |
| `DELETE /users/vehicles/fake-id` | ❌ 403 (token parsing issue) |

**Delete menggunakan plateNumber sebagai path parameter, bukan ID.**

---

## Status Code Summary

| Endpoint | Method | Status | Role |
|----------|--------|--------|------|
| `/users/profile` | GET | 200 ✅ | Regular user bisa |
| `/users/vehicles` | GET | 403 ❌ | Super Admin only |
| `/users/vehicles` | POST | 201 ✅ | Regular user bisa |
| `/users/vehicles/{plateNumber}` | DELETE | 200 ✅ | Regular user bisa |

---

## Frontend Verification — 3 Mismatch

### Mismatch 1: Vehicle Model (`model/vehicle.dart`)
| Item | Sebelum | Sesudah |
|------|---------|---------|
| Field `id` | ✅ Required — `json['id'] ?? json['vehicleId'] ?? json['_id']` | ❌ **Dihapus** — backend tidak return ID |
| Constructor | 4 params (`id`, `plateNumber`, `vehicleType`, `createdAt`) | 2 params (`plateNumber`, `vehicleType`) |

### Mismatch 2: Vehicle Service — getVehicles (`service/vehicle_service.dart`)
| Item | Sebelum | Sesudah |
|------|---------|---------|
| Endpoint | `GET /users/vehicles` (403 ❌) | `GET /users/profile` → `data.vehicles` (200 ✅) |
| Response parse | Array langsung / `{data: [...]}` | `body['data']['vehicles']` |

### Mismatch 3: Vehicle Service — deleteVehicle (`service/vehicle_service.dart`)
| Item | Sebelum | Sesudah |
|------|---------|---------|
| Parameter | `String vehicleId` | `String plateNumber` |
| URL | `/users/vehicles/$vehicleId` | `/users/vehicles/$encodedPlate` |
| Encoding | Tidak ada | `Uri.encodeComponent()` |

### Mismatch 4: Vehicle Card (`page/vehicle_management_page.dart`)
| Item | Sebelum | Sesudah |
|------|---------|---------|
| Delete call | `_service.deleteVehicle(vehicle.id)` | `_service.deleteVehicle(vehicle.plateNumber)` |
| ID display | `if (vehicle.id.isNotEmpty)` show ID | ❌ **Dihapus** — backend tidak return ID |

---

## Files Changed

| File | Perubahan |
|------|-----------|
| `lib/features/profil/model/vehicle.dart` | `id` + `createdAt` dihapus. Constructor hanya `plateNumber` + `vehicleType`. |
| `lib/features/profil/service/vehicle_service.dart` | `getVehicles()` → `GET /users/profile`. `deleteVehicle()` → pakai `plateNumber` + URL-encode. `addVehicle()` simplified. |
| `lib/features/profil/page/vehicle_management_page.dart` | `deleteVehicle(vehicle.id)` → `deleteVehicle(vehicle.plateNumber)`. ID card display dihapus. |

---

## Known Issues

| Issue | Detail |
|-------|--------|
| **`GET /users/vehicles` tidak bisa dipakai** | Endpoint ini 403 untuk regular user. Frontend pakai `GET /users/profile` sebagai gantinya. |
| **Delete by plateNumber rentan** | Jika user punya 2 kendaraan dengan plat sama (tidak mungkin di Indonesia), delete akan ambigu. Backend mengandalkan uniqueness plat. |
| **Vehicle ID tidak tersedia** | Tanpa ID, tidak ada cara untuk referensi kendaraan spesifik selain plat nomor. |
| **Search/filter vehicle by ID** | Tidak bisa dilakukan karena ID tidak ada. |

---

## Executive Summary

| Item | Nilai |
|------|-------|
| **Kontrak backend** | Vehicle = `{plateNumber, vehicleType}` — TANPA `id` |
| **Source of truth** | `GET /users/profile` → `data.vehicles` (bukan `/users/vehicles`) |
| **Create** | ✅ `POST /users/vehicles` with `{plateNumber, vehicleType}` → 201 |
| **Delete** | ✅ `DELETE /users/vehicles/{url-encoded-plate}` → 200 |
| **Frontend fix** | 3 file diubah: model, service, page |
| **Root cause** | Asumsi bahwa backend return `id` dan `GET /users/vehicles` bisa dipakai ternyata salah |

## Validation Checklist

- [x] POST vehicle → berhasil (201)
- [x] POST vehicle → muncul di profile
- [x] DELETE vehicle → berhasil (200)
- [x] DELETE vehicle → hilang dari profile
- [x] GET vehicle → data real dari backend (via profile)
- [x] Frontend menggunakan kontrak yang benar
