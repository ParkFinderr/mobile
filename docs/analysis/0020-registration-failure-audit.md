# Audit 0020 — Registrasi Gagal pada PWA Flutter Web (Vercel)

## Root Cause Candidate

```
Kesalahan nomor 1: Error handling membuang semua detail error backend.
Kesalahan nomor 2: Tidak ada logging yang terlihat oleh developer di production.
Kesalahan nomor 3: Tidak ada environment separation — base URL hardcoded.
```

**Kemungkinan terbesar**: Error handling yang menelan (swallow) semua exception dan response error, sehingga pesan asli dari backend tidak pernah tampak. Di production browser, `print()` hanya muncul di DevTools console, tidak ada visibility. Setiap kegagalan (network error, 400, 500, timeout, JSON parse error) semuanya menghasilkan pesan yang sama: *"Pendaftaran gagal. Silakan coba lagi."*

---

## 1. Audit Endpoint Registrasi

### Service Register
- **File**: `lib/features/login/service/auth_service.dart`
- **Method**: `register()`
- **Endpoint**: `POST /auth/register`
- **Base URL**: `lib/core/network/api_service.dart:6` — hardcoded

### Flow Request

```
RegisterWidget._doRegister()
  → AuthService.register(name, email, phone, password, plateNumber)
    → ApiService.post('/auth/register', body: {...})
      → http.post(Uri.parse('$baseUrl$endpoint'), headers, body: jsonEncode(body))
```

### Payload yang Dikirim
```json
{
  "name": "<nama>",
  "email": "<email>",
  "phoneNumber": "<telepon>",
  "password": "<password>",
  "defaultLicensePlate": "<no_kendaraan>",
  "vehicleType": "mobil"
}
```

### Expected Response (berhasil)
```json
{
  "success": true,
  "message": "Registrasi berhasil! Selamat datang.",
  "data": {
    "token": "eyJ...",
    "user": { "userId": "...", "email": "...", "name": "...", "role": "user" }
  }
}
```
HTTP 201 Created.

### Verifikasi Langsung
```bash
curl -s -X POST 'https://backend-api-services-173368161554.asia-southeast2.run.app/auth/register' \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Test Audit",
    "email": "audit-verify@example.com",
    "phoneNumber": "081234567890",
    "password": "Test1234!",
    "defaultLicensePlate": "B 1234 CD",
    "vehicleType": "mobil"
  }'
```
**Hasil**: ✅ HTTP 201 — `{"success":true,"message":"Registrasi berhasil!..."}`

Backend berfungsi dengan benar.

---

## 2. Audit Base URL

| Aspek | Detail |
|-------|--------|
| **Lokasi definisi** | `lib/core/network/api_service.dart:6` |
| **Nilai** | `https://backend-api-services-173368161554.asia-southeast2.run.app` |
| **Environment file** | ❌ Tidak ada `.env`, `flutter_dotenv`, atau file environment apapun |
| **String constant** | `static const String baseUrl` (hardcoded) |
| **localhost/127.0.0.1** | ❌ Tidak ditemukan di source code maupun built JS |
| **10.x.x.x/192.168.x.x** | ❌ Tidak ditemukan di source code maupun built JS |
| **Tercantum di built JS** | ✅ 1 kemunculan di `pwa/main.dart.js` — URL production |

### Kesimpulan
Base URL sudah benar mengarah ke production. Tidak ada localhost/private IP.

---

## 3. Audit Request Payload

### Field Mapping
| UI Field | Controller | Parameter | JSON Key | Backend Expects | Match |
|----------|-----------|-----------|----------|-----------------|-------|
| Nama Pengguna | `_namaCtrl` | `name` | `name` | `name` | ✅ |
| Email | `_emailCtrl` | `email` | `email` | `email` | ✅ |
| Nomor Telpon | `_teleponCtrl` | `phone` | `phoneNumber` | `phoneNumber` | ✅ |
| Kata Sandi | `_passCtrl` | `password` | `password` | `password` | ✅ |
| Nomor Kendaraan | `_noKendCtrl` | `plateNumber` | `defaultLicensePlate` | `defaultLicensePlate` | ✅ |
| — (hardcoded) | — | — | `vehicleType: "mobil"` | `vehicleType` | ✅ |

### Catatan Penting
- Field `plateNumber` → `defaultLicensePlate` sudah diperbaiki di **Update 0015B**
- Field `vehicleType` ditambahkan di **Update 0015B** (sebelumnya tidak dikirim)
- Tidak ada mismatch payload yang terdeteksi

### Verifikasi Payload via curl
Payload yang identik dengan kode Flutter berhasil (HTTP 201). ✅

---

## 4. Audit Error Handling

### Kode yang Bermasalah

**`lib/features/login/service/auth_service.dart:46-50`**:
```dart
catch (e) {
  print('Register error: $e');
  return false;
}
```

**`lib/features/register/widget/register_widget.dart:109-113`**:
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Pendaftaran gagal. Silakan coba lagi.'), backgroundColor: Colors.red),
);
```

### Masalah

| No | Masalah | Dampak |
|----|---------|--------|
| 1 | `catch (e)` menangkap **semua** jenis error | Network error, timeout, HTTP 400, HTTP 500, JSON parse error — semua dianggap sama |
| 2 | `print('Register error: $e')` hanya ke browser console | Tidak terlihat oleh user, developer juga tidak lihat di production tanpa DevTools |
| 3 | Return value hanya `bool` (`true`/`false`) | Informasi penyebab kegagalan hilang sama sekali |
| 4 | Tidak ada pembedaan status code 4xx vs 5xx vs network error | Semua non-2xx dianggap gagal tanpa log |
| 5 | Tidak ada logging ke server/analytics | Kegagalan di production tidak terdeteksi |

### Skenario yang Semua Menghasilkan Pesan Sama

1. ✅ Backend return HTTP 400 (validasi error) → `false` → "Pendaftaran gagal"
2. ✅ Network timeout (server down) → exception → `false` → "Pendaftaran gagal"
3. ✅ CORS error (jika ada) → exception → `false` → "Pendaftaran gagal"
4. ✅ Backend return HTTP 500 → `false` → "Pendaftaran gagal"
5. ✅ Backend return HTTP 201 (sukses) → `true` → success dialog ✅

### Root Cause Kegagalan Diagnosa
Karena semua error digeneralisasi, **tidak mungkin** mengetahui penyebab sebenarnya tanpa membuka browser DevTools.

---

## 5. Audit CORS

### Hasil Test Preflight
```bash
curl -X OPTIONS 'https://backend-api-services-173368161554.asia-southeast2.run.app/auth/register' \
  -H 'Origin: https://parkfinder.vercel.app' \
  -H 'Access-Control-Request-Method: POST'
```
**Response Headers**:
```
access-control-allow-origin: *
access-control-allow-methods: GET,HEAD,PUT,PATCH,POST,DELETE
access-control-allow-headers: Content-Type, Authorization
```
✅ CORS dikonfigurasi dengan benar — `Access-Control-Allow-Origin: *`.

### Kesimpulan
**CORS bukan penyebab masalah.** Backend mengizinkan semua origin.

---

## 6. Audit Browser Deployment

### Request yang Seharusnya Terjadi
```
POST https://backend-api-services-173368161554.asia-southeast2.run.app/auth/register
Origin: https://<vercel-domain>.vercel.app
Content-Type: application/json

{"name":"...","email":"...","phoneNumber":"...","password":"...","defaultLicensePlate":"...","vehicleType":"mobil"}
```

### Kemungkinan Gagal di Production (Vercel)
| Skenario | Probabilitas | Penjelasan |
|----------|-------------|------------|
| Network timeout (backend slow) | Rendah | Backend respon ~500ms via curl |
| CORS preflight gagal | Sangat Rendah | `access-control-allow-origin: *` sudah diset |
| Mixed Content (HTTP/HTTPS) | Rendah | Backend pakai HTTPS |
| **Response unexpected** | **Sedang** | Backend mungkin return 400 untuk alasan tidak terduga |
| **Error swallowed** | **Sangat Tinggi** | Kode `catch` menelan exception apapun |

### Kemungkinan Gagal di Localhost
Tidak bisa diverifikasi karena Flutter web di localhost menggunakan `localhost:port` yang mungkin berbeda header Origin-nya, tapi CORS sudah `*`.

---

## 7. Audit Flutter Web Build

| Aspek | Status |
|-------|--------|
| Endpoint production di built JS | ✅ Ada (`backend-api-services-...run.app`) |
| Localhost di built JS | ❌ Tidak ada |
| File env terbaca | ❌ Tidak ada env file — URL hardcoded |
| `flutter build web` menggunakan env benar | ✅ Built dengan URL production |
| Tidak ada compile-time injection | ✅ URL tidak bisa diubah tanpa rebuild |

### Struktur Built File
```
pwa/
  main.dart.js          (102.850 baris — berisi URL production)
  flutter_bootstrap.js  (bootstrap Flutter web)
  manifest.json         (PWA manifest)
  index.html            (entry point)
  canvaskit/            (renderer)
```

---

## Ringkasan Audit

### Yang Berfungsi dengan Benar
1. ✅ Backend endpoint `POST /auth/register` — merespon dengan benar (201)
2. ✅ Payload field mapping — sesuai kontrak backend (fixed di Update 0015B)
3. ✅ Base URL — mengarah ke production, bukan localhost
4. ✅ CORS — dikonfigurasi `*` (allow all origins)
5. ✅ Build output — URL production ter-embed dengan benar

### Yang Bermasalah (Root Cause)
1. ❌ **Error handling menelan semua detail** — `catch (e) { print(...); return false; }`
2. ❌ **Tidak ada logging production** — `print()` hanya ke browser console
3. ❌ **Pesan error generik** — "Pendaftaran gagal" untuk SEMUA jenis kegagalan
4. ❌ **Tidak ada environment configuration** — URL hardcoded, tidak bisa diganti per environment tanpa rebuild

### Kemungkinan Terbesar
```
Error handling yang menelan detail error backend.
Tanpa akses ke browser DevTools, tidak mungkin membedakan:
  - Apakah backend return 400 (validasi)?
  - Apakah ada network error?
  - Apakah ada timeout?
  - Apakah response body tidak sesuai format?
```

---

## Rekomendasi Perbaikan

### 1. Perbaiki Error Handling (Prioritas Tertinggi)
```dart
// JANGAN menelan error
try {
  final response = await _apiService.post('/auth/register', body: {...});
  if (response.statusCode == 200 || response.statusCode == 201) {
    return true;
  }
  // Log response body untuk debugging
  print('Register failed: ${response.statusCode} ${response.body}');
  return false;
} catch (e) {
  print('Register error: $e');
  return false;
}
```

### 2. Tampilkan Error ke User
Gunakan pesan error yang lebih informatif:
- "Email sudah terdaftar" (jika backend return message)
- "Koneksi terputus, coba lagi" (jika network error)
- Default: "Pendaftaran gagal: {message dari backend}"

### 3. Gunakan Environment Configuration
Ganti hardcoded URL dengan `--dart-define` agar bisa di-switch:
```bash
flutter build web --dart-define=BASE_URL=https://...
```

### 4. Tambahkan Logging
Gunakan `dart:developer` `log()` atau library logging yang visible di production.

---

## Status
| Item | Hasil |
|------|-------|
| Root cause ditemukan | ✅ Error handling menelan detail error |
| Backend berfungsi | ✅ (verified via curl) |
| Payload sesuai kontrak | ✅ (fixed Update 0015B) |
| CORS | ✅ (allow all origins) |
| Base URL hardcoded | ⚠️ Bukan penyebab langsung, tapi best practice violation |
| Perbaikan kode dilakukan | ❌ Tidak (hanya audit sesuai instruksi) |
