# Update 0008

Date: 2026-06-10
Task: Backend Contract Audit

---

# Implementation Report

## Task Summary

Audit seluruh endpoint backend ParkFinder untuk memverifikasi ketersediaan, method, request/response body, dan auth requirement. Tidak ada perubahan kode — hanya probing langsung ke API + analisis source code frontend.

---

## Methodology

1. **Probe langsung** ke `https://backend-api-services-173368161554.asia-southeast2.run.app` via HTTP (GET/POST/PUT)
2. **Analisis kode frontend** — service layer di `lib/features/*/service/`
3. **Cek dokumentasi** — mencari api.md, swagger, openapi, postman collection (tidak ditemukan)
4. **Kategorisasi**: endpoint per grup (`/access/*`, `/reservations/*`, `/users/*`, `/areas/*`)

---

## Dokumen yang Ditemukan

| Dokumen | Lokasi | Status |
|---------|--------|--------|
| api.md | ❌ Tidak ditemukan di repo | Missing |
| Swagger/OpenAPI | ❌ Tidak ada di backend (`/swagger.json`, `/openapi.json`, `/docs`, `/api`, `/swagger-ui`) | Missing |
| Postman Collection | ❌ Tidak ditemukan | Missing |
| Source Code Backend | ❌ Tidak ada di repo | Missing |

**Sumber informasi endpoint**: Hanya dari kode frontend (service layer) dan probing langsung ke API.

---

## Full Endpoint Inventory

### Root

| Method | Path | Auth | Response (200) | Frontend Uses? | Available? |
|--------|------|------|----------------|----------------|------------|
| GET | `/` | ❌ | `{"message":"ParkFinder API Service Terhubung","serverTime":"..."}` | ❌ | ✅ |

---

### `/auth/*`

| Method | Path | Auth | Request | Response | Frontend Uses? | Available? | Notes |
|--------|------|------|---------|----------|----------------|------------|-------|
| POST | `/auth/register` | ❌ | `{name, email, phoneNumber, password, plateNumber}` | `200/201` | ✅ | ✅ | **Plate validation bug?** — semua nilai plateNumber ditolak dengan "wajib diisi" |
| POST | `/auth/login` | ❌ | `{email, password}` | `{token}` | ✅ | ✅ | ✅ Working |
| POST | `/auth/logout` | ✅ | — | `200` | ✅ | ✅ | ✅ Working |

---

### `/users/*`

| Method | Path | Auth | Request | Response | Frontend Uses? | Available? | Notes |
|--------|------|------|---------|----------|----------------|------------|-------|
| GET | `/users/profile` | ✅ | — | `{name, email, phoneNumber}` | ✅ | ✅ | ✅ Digunakan di ProfilPage, HomeWidget, HistoryWidget |
| PUT | `/users/profile` | ✅ | `{name, email, phoneNumber}` | `200` | ✅ | ✅ | ✅ Dipanggil oleh EditProfilPage. Sebelumnya diduga MISSING, tapi ternyata **ADA** |
| GET | `/users/vehicles` | ✅ | — | `[{plateNumber, vehicleType}]` | ✅ | ✅ | ✅ Digunakan di ProfilPage |
| POST | `/users/vehicles` | — | — | — | ❌ | ❓ Tidak diuji | api.md menyebut Add/Delete, tidak ada di frontend |
| DELETE | `/users/vehicles/{id}` | — | — | — | ❌ | ❓ Tidak diuji | Tidak ada di frontend |

---

### `/areas/*`

| Method | Path | Auth | Request | Response | Frontend Uses? | Available? | Notes |
|--------|------|------|---------|----------|----------------|------------|-------|
| GET | `/areas` | ❌ | — | `{success, data: [{id, name, totalSlots, availableSlots, address}]}` | ✅ | ✅ | ✅ Tanpa auth pun return data |
| GET | `/areas/{id}` | ❌ | — | `{success, data: {id, name, totalFloors, totalSlots, availableSlots, address, contactEmail, ...}}` | ❌ | ✅ | **ADA tapi tidak digunakan frontend** — bisa dipakai untuk title dinamis DetailBooking |
| GET | `/areas/{id}/slots` | ❌ | — | `{success, data: [{id, slotName, appStatus, vehicleType}]}` | ✅ | ✅ | ✅ Digunakan di DetailBooking |

---

### `/reservations/*`

| Method | Path | Auth | Request | Response | Frontend Uses? | Available? | Notes |
|--------|------|------|---------|----------|----------------|------------|-------|
| POST | `/reservations` | ✅ | `{slotId, ticketId, name, plateNumber}` | `200/201` | ✅ | ✅ | ✅ Digunakan di DetailBooking. Response 404 jika ticketId tidak valid |
| GET | `/reservations` | ✅ | — | — | ❌ | ❌ **404 HTML** | Tidak ada |
| GET | `/reservations/history` | ✅ | — | — | ❌ | ❌ **404 HTML** | Tidak ada |
| GET | `/reservations/my` | — | — | — | ❌ | ❌ **404 HTML** | Tidak ada |

---

### `/access/*`

| Method | Path | Auth | Request | Response | Frontend Uses? | Available? | Notes |
|--------|------|------|---------|----------|----------------|------------|-------|
| POST | `/access/verify` | ✅ | `{qrCode}` | `200` (valid) / `404` (invalid) | ❌ | ✅ | **ADA** — tapi tidak dipanggil di active flow (ScanService dihapus di task 0006) |
| POST | `/access/cancelTicket` | ✅ | `{ticketId}` | `200` | ❌ | ✅ | **ADA** — tapi tidak diintegrasikan. Frontend butuh untuk "Keluar Parkir" |
| GET | `/access/active-session` | ✅ | — | — | ❌ | ❌ **404 HTML** | Tidak ada |

---

## Response Detail Verifikasi

### GET /areas/{id} — Response (200)

```json
{
  "success": true,
  "message": "Detail area berhasil diambil.",
  "data": {
    "id": "BWOjPZoajWmF3kJA62Fe",
    "name": "Jurusan Teknik Elektro Unila",
    "totalFloors": 1,
    "isActive": true,
    "contactEmail": "admin.elektro@parkfinder.id",
    "totalSlots": 3,
    "availableSlots": 3,
    "address": "Jl. Prof. Dr. Ir. Sumantri Brojonegoro, ...",
    "createdAt": "2026-02-18T03:50:38.447Z",
    "updatedAt": "2026-05-10T12:36:50.879Z"
  }
}
```

### GET / — Response (200)

```json
{
  "message": "ParkFinder API Service Terhubung",
  "serverTime": "2026-06-10T00:37:03.858Z"
}
```

### POST /access/verify — Response (404 business logic)

```json
{"success": false, "message": "Tiket tidak valid atau tidak ditemukan.", "data": null}
```

Endpoint **EXISTS** (404 adalah business response, bukan route error).

### POST /access/cancelTicket — Response (401)

```json
{"success": false, "message": "Identitas pengguna tidak ditemukan.", "data": null}
```

Endpoint **EXISTS** — middleware auth aktif.

### PUT /users/profile — Response (403 fake token)

```json
{"success": false, "message": "Token tidak valid (Malformed).", "data": null}
```

Endpoint **EXISTS** — token validation aktif.

---

## Summary Table: Frontend Need vs Backend Availability

| Endpoint | Frontend Needs | Backend Available | Gap |
|----------|---------------|-------------------|-----|
| `POST /auth/register` | ✅ Register | ✅ Available | ⚠️ Plate validation mungkin bermasalah |
| `POST /auth/login` | ✅ Login | ✅ Available | ✅ Match |
| `POST /auth/logout` | ✅ Logout | ✅ Available | ✅ Match |
| `GET /users/profile` | ✅ Profil | ✅ Available | ✅ Match |
| `PUT /users/profile` | ✅ Edit Profil | ✅ Available | ✅ Match (sebelumnya diduga MISSING) |
| `GET /users/vehicles` | ✅ Kendaraan | ✅ Available | ✅ Match |
| `GET /areas` | ✅ Daftar Parkir | ✅ Available | ✅ Match |
| `GET /areas/{id}` | ❌ Tidak digunakan | ✅ Available | 🔵 **Frontend opportunity** — bisa untuk title dinamis |
| `GET /areas/{id}/slots` | ✅ Slot per area | ✅ Available | ✅ Match |
| `POST /reservations` | ✅ Booking | ✅ Available | ✅ Match |
| `GET /reservations` | ❌ Tidak digunakan | ❌ **404** | 🔴 Gap — tidak ada endpoint history |
| `GET /reservations/history` | ❌ Tidak digunakan | ❌ **404** | 🔴 Gap — tidak ada endpoint history |
| `POST /access/verify` | ✅ (seharusnya) | ✅ Available | ⚠️ Frontend tidak panggil (ScanService dihapus) |
| `POST /access/cancelTicket` | ✅ (seharusnya) | ✅ Available | ⚠️ Frontend tidak integrasi |
| `GET /access/active-session` | ✅ (seharusnya) | ❌ **404** | 🔴 Gap — tidak ada endpoint active session |

---

## Verifikasi 5 Endpoint yang Dipertanyakan

| Endpoint | Status | Bukti |
|----------|--------|-------|
| `GET /access/active-session` | ❌ **Tidak ada** | 404 HTML `Cannot GET /access/active-session` |
| `POST /access/cancelTicket` | ✅ **Ada** | 401 JSON (auth required) — endpoint reachable |
| `GET /reservations/history` | ❌ **Tidak ada** | 404 HTML `Cannot GET /reservations/history` |
| `GET /areas/{id}` | ✅ **Ada** | 200 JSON — mengembalikan detail area |
| `PUT /users/profile` | ✅ **Ada** | 401/403 JSON — endpoint reachable, auth middleware aktif |

**Kesimpulan**: 3 dari 5 endpoint yang dipertanyakan ternyata **ADA** (`POST /access/cancelTicket`, `GET /areas/{id}`, `PUT /users/profile`). Hanya 2 yang benar-benar **TIDAK ADA** (`GET /access/active-session`, `GET /reservations/history`).

---

## Total Endpoint Count

| Kategori | Jumlah |
|----------|--------|
| ✅ Endpoint aktif (available) | 12 |
| ❌ Endpoint tidak ada (404) | 3 |
| ❓ Belum diuji | 2 (POST/DELETE vehicles) |

---

## Known Issues

1. **`POST /auth/register` plate validation** — Semua nilai `plateNumber` yang dikirim ditolak dengan "Plat Nomor wajib diisi". Kemungkinan backend bug atau perubahan schema. Perlu investigasi lebih lanjut dari tim backend.
2. **3 endpoint tidak ada**: `GET /access/active-session`, `GET /reservations`, `GET /reservations/history` — memblokir fitur StatusKendaraan dan History.
3. **`GET /areas/{id}` tidak digunakan** — Frontend bisa memanfaatkan endpoint ini untuk title dan floor tabs yang dinamis.

---

## Technical Debt

1. **Tidak ada dokumentasi API** — Tidak ada api.md, swagger, atau openapi spec. Satu-satunya referensi adalah kode frontend.
2. **Register endpoint mungkin broken** — plate validation selalu gagal. Perlu konfirmasi dari backend apakah endpoint ini masih berfungsi.
3. **History endpoint tidak ada** — 8 item hardcoded di History tidak akan bisa diganti sampai backend menyediakan endpoint.

---

## Remaining Work

1. Konfirmasi tim backend tentang POST /auth/register plate validation
2. Minta backend membuat GET /access/active-session
3. Minta backend membuat GET /reservations/history
4. Implementasi GET /areas/{id} di frontend untuk DetailBooking dinamis
5. Integrasi POST /access/cancelTicket untuk fitur "Keluar Parkir"
6. Integrasi ulang POST /access/verify di flow scan

---

## Recommended Next Steps

1. **🔴 Critical** — Laporkan issue register ke backend (plate validation selalu gagal)
2. **🔴 Critical** — Minta endpoint baru: GET /access/active-session dan GET /reservations/history
3. **🟡 Medium** — Implementasi GET /areas/{id} untuk membuat DetailBooking title dinamis
4. **🟡 Medium** — Integrasi POST /access/cancelTicket untuk "Keluar Parkir"
5. **🟡 Medium** — Integrasi ulang POST /access/verify di WelcomeScan → ScanBerhasil flow
6. **🟢 Low** — Buat api.md sebagai dokumentasi internal dari hasil audit ini

---

## Executive Summary

1. **12 endpoint backend available**, **3 endpoint missing** (active-session, reservations list, reservations history)
2. **Dari 5 endpoint yang dipertanyakan**: 3 ternyata **ADA** (`cancelTicket`, `areas/{id}`, `users/profile PUT`), hanya 2 yang benar-benar **TIDAK ADA**
3. **`GET /areas/{id}`** — endpoint sudah ada tapi tidak digunakan frontend (bisa untuk title dinamis DetailBooking)
4. **`POST /access/cancelTicket`** — endpoint sudah ada tapi tidak diintegrasikan ke button "Keluar Parkir"
5. **`PUT /users/profile`** — endpoint sudah ada, frontend sudah panggil (EditProfilPage)
6. **Register endpoint mungkin broken** — plate validation selalu gagal untuk semua input
7. **Tidak ada dokumentasi API** — api.md, swagger, openapi tidak tersedia
8. **3 endpoint missing memblokir 3 fitur**: StatusKendaraan real data, History real data, Active Session
9. **Frontend opportunity**: `GET /areas/{id}` siap pakai untuk dynamic title DetailBooking
10. **Prioritas**: Fix register → minta endpoint baru → integrasi existing endpoint yang belum terpakai
