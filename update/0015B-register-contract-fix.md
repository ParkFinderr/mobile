# Update 0015B — Register Contract Fix

## Tanggal
2026-06-10

## Status
✅ Selesai — `flutter analyze` 0 errors

---

## 1. Audit Kontrak Frontend vs Backend

### Perbandingan Payload

| Field Frontend (sebelum) | Field Backend (Postman) | Status |
|--------------------------|------------------------|--------|
| `name` | `name` | ✅ Match |
| `email` | `email` | ✅ Match |
| `password` | `password` | ✅ Match |
| `phoneNumber` | `phoneNumber` | ✅ Match |
| `plateNumber` | `defaultLicensePlate` | ❌ **MISMATCH** |
| — (tidak dikirim) | `vehicleType` | ❌ Missing |
| — (tidak dikirim) | `fcmToken` | ❌ Missing |

### Request Body — Sebelum
```json
{
  "name": "Test User",
  "email": "test@example.com",
  "phoneNumber": "081234567890",
  "password": "Test1234!",
  "plateNumber": "B1234CD"
}
```

### Request Body — Sesudah
```json
{
  "name": "Test User",
  "email": "test@example.com",
  "phoneNumber": "081234567890",
  "password": "Test1234!",
  "defaultLicensePlate": "B1234CD",
  "vehicleType": "mobil"
}
```

---

## 2. Root Cause Final

### Jawaban: **B. Frontend contract mismatch**

Update 0015 **salah** dalam menyimpulkan "backend bug". Bukti:

| Update 0015 menyimpulkan | Fakta sebenarnya |
|--------------------------|------------------|
| "Backend bug pada validasi plat" | Backend benar — field name berbeda |
| "18 variasi field name semua gagal" | Karena hanya `defaultLicensePlate` yang benar |
| "10 variasi value semua gagal" | Karena field name salah, value tidak pernah dicek |

### Akar Masalah
Frontend mengirim field `plateNumber`, backend mengharapkan `defaultLicensePlate`.

### Mengapa Update 0015 Keliru
Dokumentasi Postman backend tidak tersedia saat audit 0015. Tanpa dokumentasi, tim menyimpulkan "backend bug" karena semua variasi field name gagal. Setelah dokumen Postman ditemukan, kontrak yang benar terungkap.

---

## 3. Perubahan Kode

### File: `lib/features/login/service/auth_service.dart`

**Register method** — 2 perubahan:

| Sebelum | Sesudah |
|---------|---------|
| `'plateNumber': plateNumber` | `'defaultLicensePlate': plateNumber` |
| — (tidak ada) | `'vehicleType': 'mobil'` |

**Login method** — 1 perubahan:

| Sebelum | Sesudah |
|---------|---------|
| `data['token']` | `body['data']?['token']` |

Login sebelumnya membaca token dari level yang salah (`data['token']` vs `data['data']['token']`). Karena token digunakan untuk authentication, login selalu gagal menyimpan JWT — artinya **login juga broken** dan perlu diperbaiki.

---

## 4. Validasi End-to-End

### STEP 1: Register ✅
```json
// Request
{
  "email": "test-e2e-1781057937@example.com",
  "name": "E2E Test User",
  "password": "Test1234!",
  "phoneNumber": "081234567890",
  "defaultLicensePlate": "B 9999 E2E",
  "vehicleType": "mobil"
}

// Response: 200 OK
{
  "success": true,
  "message": "Registrasi berhasil! Selamat datang.",
  "data": {
    "token": "eyJ...",
    "user": { "userId": "AnGJrvmd6yT2v8dk4q6S", "email": "test-...", "name": "E2E Test User", "role": "user" }
  }
}
```

### STEP 2: Login ✅
```json
// Request
{ "email": "test-e2e-1781057937@example.com", "password": "Test1234!" }

// Response: 200 OK — JWT diperoleh
{ "success": true, "message": "Login berhasil.", "data": { "token": "eyJ..." } }
```

### STEP 3: JWT → Protected Endpoint ✅
```json
// GET /users/profile (Authorization: Bearer eyJ...)
{
  "success": true,
  "data": {
    "name": "E2E Test User",
    "email": "test-e2e-1781057937@example.com",
    "phoneNumber": "081234567890",
    "vehicles": [{ "plateNumber": "B 9999 E2E", "vehicleType": "mobil" }]
  }
}
```

---

## 5. Known Issues

| Issue | Detail |
|-------|--------|
| **vehicleType hardcoded** | Frontend tidak punya UI selector tipe kendaraan. Nilai `"mobil"` di-hardcode. Solusi jangka panjang: tambah dropdown mobil/motor di form register. |
| **fcmToken tidak dikirim** | Firebase Cloud Messaging belum diintegrasikan. Backend menerima `fcmToken` sebagai opsional — tidak dikirim sama sekali. |
| **`GET /users/vehicles` broken** | Endpoint ini hanya untuk Super Admin. Data kendaraan tersedia via `GET /users/profile.data.vehicles`. Perlu diperbaiki di masa depan. |
| **Login juga broken** | Login method membaca `data['token']` tapi token ada di `data['data']['token']`. Diperbaiki bersamaan dengan register fix. |

---

## 6. Executive Summary

| Item | Nilai |
|------|-------|
| **Bug type** | Contract mismatch (frontend) |
| **Root cause** | Frontend kirim `plateNumber`, backend harap `defaultLicensePlate` |
| **Fix** | 1 baris di `auth_service.dart` register method |
| **Bonus fix** | Login token extraction path juga salah — diperbaiki |
| **Verification** | ✅ Register → ✅ Login → ✅ JWT → ✅ Profile |
| **Update 0015** | ❌ Salah kesimpulan (backend bug) → sebenarnya frontend mismatch |
| **Dampak** | Register & Login sekarang berfungsi penuh |

---

## 7. Validation Checklist

- [x] Register berhasil
- [x] Error "Plat Nomor wajib diisi" hilang
- [x] Login berhasil
- [x] JWT berhasil diperoleh
- [x] Endpoint protected dapat diakses
- [x] Payload frontend sesuai dokumentasi backend
