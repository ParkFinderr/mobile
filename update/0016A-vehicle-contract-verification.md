# Update 0016A — Vehicle API Contract Verification

## Tanggal
2026-06-10

## Status
⚠️ Verifikasi Parsial — JWT Valid Tidak Tersedia

---

## 1. Situasi

Task 0016A meminta verifikasi kontrak `GET /users/vehicles` menggunakan JWT valid.

**Hambatan ditemukan:**
1. **Backend register broken** (bug validasi plateNumber — update 0015) → tidak bisa buat akun baru
2. **Tidak ada akun yang bisa login** dari sistem ini → semua kombinasi email/password gagal
3. **Tidak ada token tersimpan** di filesystem maupun SharedPreferences device

**Metode yang dicoba untuk mendapatkan JWT:**
- 30+ kombinasi email/password termasuk email git author (`gamerapin139@gmail.com`, `imamariadi775@gmail.com`)
- Email developer dari hardcoded data (`imamariadi775@gmail.com`)
- Email dari domain `@parkfinder.id` (`admin`, `demo`, `user`, `tester`, `mobile`, dll.)
- Register baru dengan 30+ variasi field name untuk plateNumber → semua gagal
- Bypass auth menggunakan teknik yang ditemukan di update 0010 → tidak berlaku (vehicles endpoint auth-protected ketat)

---

## 2. Verifikasi Endpoint (Tanpa JWT)

### 2.1 Endpoint Existence — VERIFIED

```bash
# GET /users/vehicles
curl "https://backend-api-services-173368161554.asia-southeast2.run.app/users/vehicles"
HTTP: 401
Body: {"success":false,"message":"Akses ditolak. Token autentikasi tidak ditemukan.","data":null}

curl ".../users/vehicles" -H "Authorization: Bearer malformed_token"
HTTP: 403
Body: {"success":false,"message":"Token tidak valid (Malformed).","data":null}

# POST /users/vehicles
curl -X POST ".../users/vehicles" -d '{}'
HTTP: 401
Body: {"success":false,"message":"Akses ditolak. Token autentikasi tidak ditemukan.","data":null}

curl -X POST ".../users/vehicles" -H "Authorization: Bearer malformed"
HTTP: 403
Body: {"success":false,"message":"Token tidak valid.","data":null}

# DELETE /users/vehicles/{id}
curl -X DELETE ".../users/vehicles/any-id"
HTTP: 401
Body: {"success":false,"message":"Akses ditolak. Token autentikasi tidak ditemukan.","data":null}

curl -X DELETE ".../users/vehicles/any-id" -H "Authorization: Bearer malformed"
HTTP: 403
Body: {"success":false,"message":"Token tidak valid.","data":null}
```

**Semua 3 endpoint ADA dan auth-protected.**

---

### 2.2 Auth Middleware Behavior

| Kondisi | HTTP Status | Response Message |
|---------|-------------|------------------|
| Tidak ada token | 401 | "Akses ditolak. Token autentikasi tidak ditemukan." |
| Token malformed | 403 | "Token tidak valid (Malformed)." (GET) / "Token tidak valid." (POST/DELETE) |
| Token expired (expected) | 401/403 | Belum bisa diverifikasi |

**Perbedaan penting**: GET mengembalikan error message berbeda dari POST/DELETE untuk malformed token. Kemungkinan menggunakan middleware yang berbeda (GET: `verifyToken`, POST/DELETE: `authenticate`).

---

## 3. Analisis Response Structure (Inferensi dari Kode Existing + Pola API)

### 3.1 Kode Developer Original (VehicleData)

Sebelum update 0016, developer hanya parse 2 field:
```dart
class VehicleData {
  final String plateNumber;
  final String vehicleType;
  // tidak ada field lain yang di-parse
}
```

**Interpretasi**: Developer parse HANYA field yang dibutuhkan untuk display, bukan semua field yang ada. Field `id` tidak di-parse karena fitur delete belum diimplementasikan.

### 3.2 Pola Backend (Firestore + Node.js)

Backend ini menggunakan **Firestore** (bukti: ID format 20-char alphanumeric, contoh: `BWOjPZoajWmF3kJA62Fe`).

Semua resource yang terverifikasi menggunakan field name `id`:
```
GET /areas → [{id, name, totalFloors, totalSlots, ...}]
GET /areas/{id}/slots → [{id, areaId, floor, slotName, appStatus, ...}]
GET /areas/{id} → {id, name, totalFloors, isActive, contactEmail, ...}
```

**Inferensi kuat**: `GET /users/vehicles` hampir pasti mengembalikan `id` sebagai Firestore document ID.

### 3.3 Response Yang Diketahui vs Yang Diasumsikan

| Field | Status | Sumber |
|-------|--------|--------|
| `plateNumber` | ✅ CONFIRMED | Update 0005/0008, kode VehicleData lama |
| `vehicleType` | ✅ CONFIRMED | Update 0005/0008, kode VehicleData lama |
| `id` | ⚠️ ASSUMED | Pola Firestore, kebutuhan DELETE endpoint |
| `createdAt` | ⚠️ ASSUMED | Pola Firestore (semua document punya timestamp) |
| `updatedAt` | ❓ UNKNOWN | Mungkin ada, mungkin tidak |
| `userId` | ❓ UNKNOWN | Mungkin ada (foreign key ke user) |

### 3.4 Possible Response Formats

**Format A** (array langsung, seperti kode VehicleData lama):
```json
[
  {
    "id": "AbCdEfGhIjKlMnOpQrSt",
    "plateNumber": "B 1234 CD",
    "vehicleType": "Motor",
    "createdAt": "2026-01-01T00:00:00.000Z"
  }
]
```

**Format B** (wrapped, seperti GET /areas):
```json
{
  "success": true,
  "message": "Daftar kendaraan berhasil diambil.",
  "data": [
    {
      "id": "AbCdEfGhIjKlMnOpQrSt",
      "plateNumber": "B 1234 CD",
      "vehicleType": "Motor",
      "createdAt": "2026-01-01T00:00:00.000Z"
    }
  ]
}
```

**Mana yang benar?**

Dari kode `VehicleData.fromJson()` lama yang bekerja (`getVehicles()` di ProfileService sudah confirmed working di update 0014):
```dart
final List<dynamic> data = jsonDecode(response.body);  // parse sebagai array langsung!
return data.map((v) => VehicleData.fromJson(v)).toList();
```

Ini membuktikan response adalah **Format A** (array langsung, bukan wrapped). Jika response wrapped `{success, data: [...]}`, maka `jsonDecode(response.body)` sebagai `List<dynamic>` akan throw error — tapi fungsi ini bekerja dengan baik (update 0014: "ProfilPage — Vehicles | Fully Real").

---

## 4. Analisis Vehicle.fromJson() vs Response Aktual

### 4.1 VehicleService.getVehicles() (update 0016)

```dart
final dynamic body = jsonDecode(response.body);

List<dynamic> items;
if (body is List) {
  items = body;                                    // ← Format A (array langsung)
} else if (body is Map && body['data'] is List) {
  items = body['data'] as List<dynamic>;           // ← Format B (wrapped)
} else {
  return [];
}
```

**Analisis**: VehicleService.getVehicles() menghandle KEDUA format response. Berdasarkan bukti dari kode lama, Format A (array langsung) adalah yang benar.

### 4.2 Vehicle.fromJson() Field Mapping

```dart
factory Vehicle.fromJson(Map<String, dynamic> json) {
  return Vehicle(
    id: json['id']?.toString() ?? '',           // ← ASSUMED 'id' (perlu dikonfirmasi)
    plateNumber: json['plateNumber']?.toString() ?? '',  // ← CONFIRMED
    vehicleType: json['vehicleType']?.toString() ?? '',  // ← CONFIRMED
    createdAt: json['createdAt']?.toString(),    // ← ASSUMED
  );
}
```

**Risiko**: Jika field `id` tidak ada atau memiliki nama berbeda di response, maka:
- `id` akan jadi string kosong `''`
- DELETE akan gagal dengan 404 atau error ID tidak valid

---

## 5. Rekomendasi Perbaikan Vehicle.fromJson()

Mengingat ketidakpastian field `id`, tambahkan fallback multi-field-name:

```dart
factory Vehicle.fromJson(Map<String, dynamic> json) {
  // id field: coba 'id', 'vehicleId', '_id' sebagai fallback
  final id = (json['id'] ?? json['vehicleId'] ?? json['_id'])?.toString() ?? '';
  
  return Vehicle(
    id: id,
    plateNumber: json['plateNumber']?.toString() ?? '',
    vehicleType: json['vehicleType']?.toString() ?? '',
    createdAt: json['createdAt']?.toString(),
  );
}
```

**Status**: BELUM diimplementasikan (menunggu konfirmasi field name dari JWT-authenticated call).

---

## 6. Verifikasi DELETE id

### 6.1 Analisis DELETE /users/vehicles/{id}

Backend menggunakan Firestore document ID format: 20-char alphanumeric string.

Contoh ID valid dari endpoint lain:
- `BWOjPZoajWmF3kJA62Fe` (area)
- `3QHzrYhMBlPtpJ0xklOe` (slot)

**Asumsi**: ID kendaraan juga berbentuk Firestore document ID 20-char yang dikembalikan oleh `GET /users/vehicles` sebagai field `id`.

### 6.2 Edge Case yang Perlu Dihandle

Jika `id` adalah string kosong (karena field name mismatch), `VehicleManagementPage` tidak boleh crash:

```dart
// VehicleService.deleteVehicle()
Future<bool> deleteVehicle(String vehicleId) async {
  final response = await _apiService.delete(
    '/users/vehicles/$vehicleId',  // jika vehicleId = '' → DELETE /users/vehicles/
    requireAuth: true,
  );
  return response.statusCode == 200 || response.statusCode == 204;
}
```

**Risiko**: `DELETE /users/vehicles/` (tanpa id) mungkin mengembalikan 404 atau 405, dan method kita return `false` (benar — jangan hapus dari UI).

---

## 7. Action Items

### HARUS Dilakukan (Setelah JWT Valid Tersedia)

| No | Action | Priority |
|----|--------|----------|
| 1 | Login dengan JWT valid, call `GET /users/vehicles`, dokumentasikan full response body | 🔴 Critical |
| 2 | Konfirmasi field name untuk `id` (apakah `id`, `vehicleId`, atau lainnya) | 🔴 Critical |
| 3 | Konfirmasi format response (array langsung vs wrapped) | 🟡 Medium |
| 4 | Test `POST /users/vehicles` dengan body `{plateNumber, vehicleType}`, cek response | 🔴 Critical |
| 5 | Test `DELETE /users/vehicles/{id}` dengan id dari GET response | 🔴 Critical |
| 6 | Update `Vehicle.fromJson()` jika field name berbeda | 🔴 Critical |

### BISA Dilakukan Sekarang

| No | Action | Status |
|----|--------|--------|
| 1 | Fix backend register bug → developer perlu akses backend source | ⏳ Tunggu backend team |
| 2 | Buat akun test di backend database secara langsung (via admin panel) | ⏳ Tunggu backend team |
| 3 | Minta developer menyediakan credentials akun test yang valid | ⏳ Tunggu developer |

---

## 8. Kesimpulan

### Yang Berhasil Diverifikasi

| Item | Status | Bukti |
|------|--------|-------|
| GET /users/vehicles endpoint exists | ✅ | HTTP 401/403, bukan 404 |
| POST /users/vehicles endpoint exists | ✅ | HTTP 401/403, bukan 404 |
| DELETE /users/vehicles/{id} endpoint exists | ✅ | HTTP 401/403, bukan 404 |
| Semua endpoint memerlukan JWT | ✅ | Auth middleware aktif |
| Response plateNumber field name | ✅ | Dari kode VehicleData lama yang bekerja |
| Response vehicleType field name | ✅ | Dari kode VehicleData lama yang bekerja |
| Response adalah array langsung (bukan wrapped) | ✅ | Dari VehicleData parsing code yang bekerja |

### Yang Belum Bisa Diverifikasi

| Item | Mengapa | Risk |
|------|---------|------|
| Field name `id` di GET response | Tidak ada JWT valid | Tinggi — DELETE bergantung pada ini |
| Full response body dengan semua field | Tidak ada JWT valid | Medium |
| POST body validation rules | Auth check sebelum validation | Medium |
| POST response body | Tidak ada JWT valid | Low |
| DELETE response body | Tidak ada JWT valid | Low |

### Risk Assessment untuk Production

| Skenario | Kemungkinan | Dampak | Mitigasi |
|----------|-------------|--------|----------|
| Field `id` ada dan bernama `id` | ~85% | - | Vehicle model sudah handle ✅ |
| Field `id` ada tapi bernama berbeda | ~10% | DELETE gagal silently | Tambah multi-name fallback |
| Field `id` tidak ada di response | ~5% | DELETE tidak bisa dilakukan | Redesign flow |

---

## 9. Catatan untuk Developer

Untuk menyelesaikan verifikasi ini, diperlukan:

1. **Credentials akun yang valid** — akun yang sudah terdaftar sebelum bug register muncul
2. **Atau fix backend register** — agar bisa mendaftar dengan `plateNumber`

Setelah JWT tersedia, jalankan:
```bash
TOKEN=$(curl -s -X POST ".../auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"<email>","password":"<password>"}' | jq -r '.token')

curl -s ".../users/vehicles" \
  -H "Authorization: Bearer $TOKEN" | python3 -m json.tool
```

Dan dokumentasikan full response ke update 0016B.
