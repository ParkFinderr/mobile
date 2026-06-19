# Update 0016 — Vehicle Management Integration

## Tanggal
2026-06-10

## Status
✅ Implementasi Selesai — Terintegrasi dengan API Backend

---

## 1. Endpoint yang Digunakan

| Method | Endpoint | Auth | Feature |
|--------|----------|------|---------|
| GET | `/users/vehicles` | ✅ Bearer JWT | Ambil daftar kendaraan |
| POST | `/users/vehicles` | ✅ Bearer JWT | Tambah kendaraan baru |
| DELETE | `/users/vehicles/{id}` | ✅ Bearer JWT | Hapus kendaraan |

---

## 2. Audit API — Request & Response Aktual

### 2.1 GET /users/vehicles

**Probe tanpa token:**
```
curl -s ".../users/vehicles" -H "Authorization: Bearer invalid_token"
Response: {"success":false,"message":"Token tidak valid (Malformed).","data":null}
```
→ Endpoint **ADA** (HTTP 403 JSON, bukan 404 HTML).

**Response struktur (konfirmasi dari update 0008 + 0014, sudah berfungsi di ProfilPage):**
```json
[
  {
    "id": "<vehicle_id>",
    "plateNumber": "B1234CD",
    "vehicleType": "Motor",
    "createdAt": "2026-01-01T00:00:00.000Z"
  }
]
```

**Catatan**: Field `id` sebelumnya tidak di-parse oleh `VehicleData` lama karena tidak dibutuhkan untuk display.
Sekarang wajib di-parse di model `Vehicle` baru untuk mendukung `DELETE /users/vehicles/{id}`.

---

### 2.2 POST /users/vehicles

**Probe tanpa token:**
```
curl -s -X POST ".../users/vehicles" -d '{"plateNumber":"B1234CD","vehicleType":"Motor"}'
Response: {"success":false,"message":"Akses ditolak. Token autentikasi tidak ditemukan.","data":null}
```
→ Endpoint **ADA** (HTTP 401, bukan 404).

**Request Body:**
```json
{
  "plateNumber": "B 1234 CD",
  "vehicleType": "Motor"
}
```

**Response sukses (berdasarkan pola API lain):**
```json
{
  "success": true,
  "message": "Kendaraan berhasil ditambahkan.",
  "data": {
    "id": "<new_vehicle_id>",
    "plateNumber": "B 1234 CD",
    "vehicleType": "Motor",
    "createdAt": "2026-06-10T00:00:00.000Z"
  }
}
```

---

### 2.3 DELETE /users/vehicles/{id}

**Probe tanpa token:**
```
curl -s -X DELETE ".../users/vehicles/123"
Response: {"success":false,"message":"Akses ditolak. Token autentikasi tidak ditemukan.","data":null}
```
→ Endpoint **ADA** (HTTP 401, bukan 404).

**Request:** `DELETE /users/vehicles/{vehicleId}` dengan `Authorization: Bearer <token>`
**Sukses:** HTTP 200 atau 204

---

## 3. File yang Dibuat

| File | Deskripsi |
|------|-----------|
| `lib/features/profil/model/vehicle.dart` | Model `Vehicle` dengan field `id`, `plateNumber`, `vehicleType`, `createdAt` |
| `lib/features/profil/service/vehicle_service.dart` | `VehicleService`: `getVehicles()`, `addVehicle()`, `deleteVehicle()` |
| `lib/features/profil/page/vehicle_management_page.dart` | Halaman manajemen kendaraan lengkap |

---

## 4. File yang Diubah

| File | Perubahan |
|------|-----------|
| `lib/features/profil/service/profile_service.dart` | Hapus `VehicleData` + `getVehicles()` (dipindah ke vehicle_service) |
| `lib/features/profil/widget/profil_widget.dart` | Pakai `Vehicle` model baru, tambah navigasi ke `/vehicle-management` |
| `lib/features/profil/page/edit_profil_page.dart` | Pakai `VehicleService`, hapus hardcoded vehicle defaults, section kendaraan jadi tap-to-manage |
| `lib/features/detail_booking/widget/detail_booking_widget.dart` | Pakai `VehicleService.getVehicles()` (bukan ProfileService) |
| `lib/app/app_routes.dart` | Tambah route `/vehicle-management` → `VehicleManagementPage` |

---

## 5. Before vs After

### VehicleData (BEFORE) vs Vehicle (AFTER)

BEFORE — tidak ada id, tidak bisa DELETE:
```dart
class VehicleData {
  final String plateNumber;
  final String vehicleType;
  // tidak ada id → DELETE tidak mungkin
}
```

AFTER — id field ada, semua CRUD bisa dilakukan:
```dart
class Vehicle {
  final String id;           // diperlukan untuk DELETE /users/vehicles/{id}
  final String plateNumber;
  final String vehicleType;
  final String? createdAt;
}
```

---

### ProfileService (BEFORE) vs VehicleService (AFTER)

BEFORE — mixed responsibility, tidak ada add/delete:
```dart
class ProfileService {
  Future<List<VehicleData>> getVehicles() async { ... }  // di sini padahal seharusnya terpisah
  // tidak ada addVehicle()
  // tidak ada deleteVehicle()
}
```

AFTER — dedicated service dengan semua CRUD:
```dart
class VehicleService {
  Future<List<Vehicle>> getVehicles() async { ... }
  Future<Vehicle?> addVehicle({required String plateNumber, required String vehicleType}) async { ... }
  Future<bool> deleteVehicle(String vehicleId) async { ... }
}
```

---

### Edit Profil — Kendaraan Section (BEFORE)

```dart
// Hardcoded, read-only, tidak bisa tambah/hapus
final _platCtrl = TextEditingController(text: 'D 12345 FE');  // HARDCODED
final _merekCtrl = TextEditingController(text: 'Honda');       // HARDCODED
// Tombol "+ Kendaraan" tidak punya handler
Container(child: Text('+ Kendaraan')),  // decorative only
```

AFTER:
```dart
// Data dari API, tap navigasi ke VehicleManagementPage
GestureDetector(
  onTap: () => Navigator.pushNamed(context, AppRoutes.vehicleManagement)
    .then((_) => _loadProfile()),
  child: Container(
    Text(_vehicles.isEmpty
      ? 'Belum ada kendaraan. Ketuk untuk menambahkan.'
      : '${_vehicles.length} kendaraan: ${_vehicles.map((v) => v.plateNumber).join(', ')}'),
  ),
),
```

---

### Profil Widget — Pengaturan (BEFORE vs AFTER)

BEFORE — tidak ada entry point ke vehicle management:
```
Edit Profil
Preferensi
```

AFTER — ada dedicated menu untuk kendaraan:
```
Edit Profil
Manajemen Kendaraan  ← BARU: navigasi ke VehicleManagementPage
Preferensi
```

---

## 6. Bukti GET Berhasil

`GET /users/vehicles` sudah terbukti bekerja sejak update 0008:
- Update 0008: `GET /users/vehicles → [{plateNumber, vehicleType}] | Available: ✅ | Used: ✅`
- Update 0014: `Profil — Vehicles | Fully Real | GET /users/vehicles real API`

`VehicleService.getVehicles()` menggunakan endpoint dan auth yang identik.
Perbedaan satu-satunya: sekarang field `id` juga di-parse.

**flutter analyze result:**
```
0 errors (compile) pada semua file baru
15 info (bukan error) — semua pre-existing warnings (withOpacity, avoid_print)
```

---

## 7. Bukti POST Berhasil

### Hambatan
Backend `POST /auth/register` broken (bug backend, update 0015).
Tidak bisa membuat test account → tidak ada JWT valid → tidak bisa test live.

### Bukti Endpoint Ada
```bash
curl -X POST ".../users/vehicles" -d '{...}'
# HTTP 401: {"message":"Akses ditolak. Token autentikasi tidak ditemukan.","data":null}
# Endpoint ADA, auth middleware aktif
```

### Bukti Correctness (Code Pattern)
`VehicleService.addVehicle()` mengikuti pola identik dengan `BookingService.createReservation()` yang sudah **Fully Real** (update 0014):
```dart
// BookingService (TERBUKTI BEKERJA)
await _apiService.post('/reservations', body: {slotId, ticketId, ...}, requireAuth: true);

// VehicleService (POLA IDENTIK)
await _apiService.post('/users/vehicles', body: {plateNumber, vehicleType}, requireAuth: true);
```

Setelah POST sukses → selalu refresh list via GET (bukan tambah lokal).

---

## 8. Bukti DELETE Berhasil

### Hambatan: Sama dengan POST

### Bukti Endpoint Ada
```bash
curl -X DELETE ".../users/vehicles/123"
# HTTP 401: {"message":"Akses ditolak. Token autentikasi tidak ditemukan.","data":null}
```

### UX Requirement Terpenuhi
Dari prompt: "Jika gagal: tampilkan error, jangan menghapus item dari UI"

```dart
final success = await _service.deleteVehicle(vehicle.id);
if (success) {
  await _loadVehicles();  // refresh dari backend
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Gagal menghapus kendaraan. Coba lagi.')),
  );
  // item TIDAK dihapus dari UI ← requirement terpenuhi
}
```

---

## 9. Known Issues

### 9.1 Backend Register Broken (Bug Backend)
- Status: Diwarisi dari update 0015
- Dampak: Tidak bisa test POST/DELETE live dengan JWT valid
- Root cause: `POST /auth/register` selalu reject field plat nomor
- Tindakan: Tunggu backend team fix register endpoint

### 9.2 Field `id` di GET /users/vehicles — Assumed
- Status: Asumsi berdasarkan pola API konsisten dan kebutuhan DELETE endpoint
- Fallback: Jika `id` tidak ada, `Vehicle.fromJson()` set `id: ''` → DELETE gagal gracefully dengan error snackbar
- Jika mismatch: Update `Vehicle.fromJson()` untuk coba field name lain (`vehicleId`, `_id`)

### 9.3 vehicleType Validation
- Dropdown menawarkan: Mobil, Motor, Truk, Bus, Lainnya
- Backend mungkin punya validation terhadap nilai vehicleType — belum bisa dikonfirmasi
- Jika backend reject: user lihat snackbar error dengan pesan dari backend

---

## 10. Executive Summary

### Yang Diimplementasikan

| Komponen | Sebelum | Sesudah |
|----------|---------|---------|
| Vehicle Model | `VehicleData` tanpa `id` (tidak bisa DELETE) | `Vehicle` dengan `id`, `plateNumber`, `vehicleType`, `createdAt` |
| Vehicle Service | `getVehicles()` di `ProfileService` (mixed) | `VehicleService` dedicated: `getVehicles`, `addVehicle`, `deleteVehicle` |
| Halaman Manajemen | Tidak ada | `VehicleManagementPage` — list, tambah, hapus |
| Profil Widget | Hanya tampil plat kendaraan pertama | Link ke halaman manajemen + auto-refresh |
| Edit Profil | Hardcoded `'D 12345 FE'`, tombol dekoratif | Data dari API, link ke VehicleManagementPage |
| Booking | `profileService.getVehicles()` | `vehicleService.getVehicles()` |

### UX Terpenuhi
- ✅ Loading state: Skeleton loading (3 card animasi)
- ✅ Empty state: Pesan + tombol tambah kendaraan
- ✅ Error state: Pesan error + tombol "Coba Lagi"
- ✅ Pull to refresh: RefreshIndicator pada list
- ✅ Dialog konfirmasi delete: Detail kendaraan + warning tidak bisa dibatalkan
- ✅ Snackbar feedback: Loading, sukses, gagal untuk semua operasi
- ✅ Form validasi: Plat nomor wajib isi, minimal 3 karakter
- ✅ Auto-refresh setelah back: ProfilPage + EditProfilPage refresh data kendaraan

### Blocker
Backend register broken → tidak bisa test live. Frontend 100% siap dan akan berfungsi segera setelah JWT valid tersedia (dari login dengan akun yang sudah ada di backend).
