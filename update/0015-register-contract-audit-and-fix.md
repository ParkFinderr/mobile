# Update 0015 — Register Contract Audit & Fix

## Tanggal
2026-06-10

## Status
✅ Audit Selesai — **Backend Bug**

---

## Langkah 1 — Frontend Request Audit

### Form Fields (UI → Controller)

| UI Label | Controller Variable | Example Value |
|----------|-------------------|---------------|
| Nama Pengguna | `_namaCtrl.text.trim()` | `"Test User"` |
| Email | `_emailCtrl.text.trim()` | `"test@example.com"` |
| Nomor Telpon | `_teleponCtrl.text.trim()` | `"081234567890"` |
| Nomor Kendaraan | `_noKendCtrl.text.trim()` | `"B1234CD"` |
| Kata Sandi | `_passCtrl.text` | `"Test1234!"` |
| Ulang Kata Sandi | `_confirmPassCtrl.text` | `"Test1234!"` |

### Mapping to JSON Payload

Source: `lib/features/login/service/auth_service.dart:32-37`

| UI Field | JSON Key | Example Value |
|----------|----------|---------------|
| Nama Pengguna | `name` | `"Test User"` |
| Email | `email` | `"test@example.com"` |
| Nomor Telpon | `phoneNumber` | `"081234567890"` |
| Kata Sandi | `password` | `"Test1234!"` |
| Nomor Kendaraan | `plateNumber` | `"B1234CD"` |

### Final Request Body

```json
{
  "name": "Test User",
  "email": "test@example.com",
  "phoneNumber": "081234567890",
  "password": "Test1234!",
  "plateNumber": "B1234CD"
}
```

---

## Langkah 2 — Backend Contract Verification

### Documentation
- Swagger/OpenAPI: **Tidak tersedia** (404 pada `/docs`, `/api-docs`, `/swagger.json`, `/openapi.json`)
- Postman Collection: **Tidak ditemukan**
- Backend source code: **Tidak tersedia**

### Endpoint Under Test
```
POST https://backend-api-services-173368161554.asia-southeast2.run.app/auth/register
Content-Type: application/json
```

### Validation Order (discovered via systematic testing)

| Step | Field Checked | Error Message |
|------|--------------|---------------|
| 1 | `name` / "Nama Lengkap" | `"Nama Lengkap wajib diisi."` |
| 2 | `email` / "Email" | `"Email wajib diisi."` |
| 3 | `password` / "Password" | `"Password wajib diisi."` |
| 4 | `phoneNumber` / "Nomor Telepon" | `"Nomor Telepon wajib diisi."` |
| 5 | `plateNumber` / "Plat Nomor" | `"Plat Nomor wajib diisi."` |

### Konfirmasi Field Name yang Berfungsi
- `name` ✅ — validasi berfungsi
- `email` ✅ — validasi berfungsi
- `password` ✅ — validasi berfungsi
- `phoneNumber` ✅ — validasi berfungsi (field name: `phoneNumber`, bukan `phone` atau `telepon`)
- **Tidak ada field name untuk plat yang berfungsi** ❌

### Semua Field Name Plat yang Diuji (18 variasi)

| Field Name | Hasil | 
|------------|-------|
| `plateNumber` | ❌ "Plat Nomor wajib diisi." |
| `platNomor` | ❌ "Plat Nomor wajib diisi." |
| `plat_nomor` | ❌ "Plat Nomor wajib diisi." |
| `plat` | ❌ "Plat Nomor wajib diisi." |
| `plate` | ❌ "Plat Nomor wajib diisi." |
| `noPlat` | ❌ "Plat Nomor wajib diisi." |
| `no_plat` | ❌ "Plat Nomor wajib diisi." |
| `noplat` | ❌ "Plat Nomor wajib diisi." |
| `noKend` | ❌ "Plat Nomor wajib diisi." |
| `kendaraan` | ❌ "Plat Nomor wajib diisi." |
| `platKendaraan` | ❌ "Plat Nomor wajib diisi." |
| `nomorPolisi` | ❌ "Plat Nomor wajib diisi." |
| `nopol` | ❌ "Plat Nomor wajib diisi." |
| `licensePlate` | ❌ "Plat Nomor wajib diisi." |
| `vehiclePlate` | ❌ "Plat Nomor wajib diisi." |
| `registrationPlate` | ❌ "Plat Nomor wajib diisi." |
| `plat_nomor_kendaraan` | ❌ "Plat Nomor wajib diisi." |
| `vehicleRegistration` | ❌ "Plat Nomor wajib diisi." |

### Semua Format/Value Plat yang Diuji

| Value | Hasil |
|-------|-------|
| `"B1234CD"` (tanpa spasi) | ❌ |
| `"B 1234 CD"` (dengan spasi) | ❌ |
| `"D 1234 AB"` (4 digit standar) | ❌ |
| `"AB 1234 CD"` (2 huruf region) | ❌ |
| `"F 1234 ABCD"` (Jakarta panjang) | ❌ |
| `"B 1 A"` (pendek) | ❌ |
| `"1234"` (angka saja) | ❌ |
| `"B"` (1 karakter) | ❌ |
| `""` (string kosong) | ❌ |
| `null` | ❌ |
| `1234` (number, bukan string) | ❌ |

---

## Langkah 3 — Payload Comparison

### Frontend Mengirim
```json
{
  "name": "Test User",
  "email": "test@example.com",
  "phoneNumber": "081234567890",
  "password": "Test1234!",
  "plateNumber": "B1234CD"
}
```

### Perbandingan dengan Variasi Lain

Semua 18 variasi field name untuk plat:
- ❌ **Tidak ada satupun yang berhasil**
- Semua mengembalikan `{"success":false,"message":"Plat Nomor wajib diisi.","data":null}` dengan HTTP 400

### Kesimpulan Perbandingan
✅ Field `name`, `email`, `password`, `phoneNumber` — kontrak sesuai antara frontend dan backend
❌ Field untuk plat nomor — **TIDAK ADA field name yang cocok** antara frontend dan backend

Tidak mungkin frontend salah karena:
1. Semua 18 variasi field name gagal dengan cara identik
2. Semua 10 variasi value gagal dengan cara identik (termasuk empty string dan null)
3. Validasi non-plate fields berfungsi dengan benar

---

## Langkah 4 — Network Verification

### Test Aktual (Flutter Payload)

```bash
curl -s -X POST 'https://backend-api-services-173368161554.asia-southeast2.run.app/auth/register' \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "phoneNumber": "081234567890",
    "password": "Test1234!",
    "plateNumber": "B1234CD"
  }'
```

### Response
```json
{
  "success": false,
  "message": "Plat Nomor wajib diisi.",
  "data": null
}
```

**HTTP Status**: `400 Bad Request`
**Latency**: ~300-500ms (server memproses hingga langkah validasi plat sebelum merespon)

### Bukti Tambahan — Test with Empty Body
```json
// Request: {}
// Response: {"success":false,"message":"Email wajib diisi.","data":null}
```
Ini membuktikan backend memproses JSON body dengan benar.

### Test with Phone Field Name `phone` (salah)
```json
// Request: {"name":"Test","email":"t@t.com","password":"Test1234!","phone":"081234567890","plateNumber":"B1234CD"}
// Response: {"success":false,"message":"Nomor Telepon wajib diisi.","data":null}
```
Ini membuktikan:
- Backend membedakan field `phoneNumber` dengan `phone`
- Backend tidak mengabaikan field yang tidak dikenal
- Validasi `phoneNumber` BERFUNGSI dengan benar

---

## Root Cause

**Backend bug pada validasi field plat nomor di `POST /auth/register`.**

### Bukti Konklusif

| Bukti | Detail |
|-------|--------|
| 1. Semua field non-plat berfungsi | `name`, `email`, `password`, `phoneNumber` pass validation ketika dikirim dengan benar |
| 2. Field `plateNumber` dikirim dengan benar | JSON body mengandung key `plateNumber`, value non-empty (`"B1234CD"`) |
| 3. 18 variasi field name gagal | Tidak ada satu pun field name untuk plat yang diterima backend |
| 4. 10 variasi value gagal | Termasuk `""`, `null`, `"B"`, `1234` — semua gagal identik |
| 5. Error konsisten | Pesan error `"Plat Nomor wajib diisi."` muncul PERSIS SAMA untuk semua input |

### Skenario Kemungkinan

1. **Typo di backend**: Backend memeriksa field `req.body.plateNamber` atau `req.body.plate_nmbr` (typo) yang tidak ada di request
2. **Logic error validasi**: Kondisi validasi di backend selalu true karena operator error (misal `||` seharusnya `&&`)
3. **Field wrapper berubah**: Backend mungkin mengharapkan plat di dalam nested object (contoh: `vehicle.plateNumber`) tapi validasi memeriksa level yang salah
4. **Library validation bug**: Validation library di backend memiliki konfigurasi yang salah untuk field plat

---

## Keputusan

❌ **Tidak ada perubahan di frontend.**

Alasan:
- Frontend sudah mengirim field `plateNumber` dengan benar (mengikuti pola yang sama dengan field lain yang berfungsi)
- 18 variasi field name tidak ada yang berhasil — bukan masalah naming
- Membuat workaround (misal: menghilangkan validasi plat di frontend) akan merusak data dan merugikan user

✅ **Backend perlu diperbaiki.**

Yang perlu diperbaiki:
1. Identifikasi field name aktual yang digunakan backend untuk plat nomor
2. Perbaiki validasi agar menerima field name yang benar
3. Atau sesuaikan field name backend dengan yang dikirim frontend (`plateNumber`)

---

## Dampak

| Area | Dampak |
|------|--------|
| **Akuisisi user** | **BLOCKED TOTAL** — tidak ada user baru yang bisa daftar |
| **User experience** | User frustrasi karena form selalu gagal meski diisi benar |
| **Testing** | Tidak bisa buat akun test untuk menguji fitur lain |
| **Frontend code** | ✅ Tidak ada perubahan — `lib/features/login/service/auth_service.dart` sudah benar |
| **Workaround** | Tidak bisa — error murni dari backend, frontend tidak bisa bypass |

---

## Validasi

| Requirement | Hasil | Keterangan |
|-------------|-------|------------|
| Register berhasil buat akun | ❌ | Gagal karena backend bug. Tidak bisa diverifikasi. |
| Tidak ada error "Plat Nomor wajib diisi" | ❌ | Error selalu muncul untuk input apapun. |
| User bisa login hasil registrasi | ❌ | Tidak bisa karena registrasi gagal. |
| Data kendaraan tersimpan benar | ❌ | Tidak bisa diverifikasi. |
