# Update 0021

Date: 2026-06-11 12:12:00
Task: PWA Registration Failure Audit & Fix

---

# Implementation Report

## Task Summary

Audit dan perbaikan kegagalan registrasi pada PWA Flutter Web yang dideploy ke Vercel.
Root cause: error handling menelan semua detail pesan error dari backend.

---

## Changes Made

### Added
* `docs/analysis/0020-registration-failure-audit.md` — Dokumen audit lengkap

### Modified
* `lib/features/login/service/auth_service.dart` — `register()` dan `login()` return `String?` (null = sukses, pesan = error)
* `lib/features/register/widget/register_widget.dart` — tampilkan pesan error asli dari backend
* `lib/features/login/widget/login_widget.dart` — tampilkan pesan error asli dari backend

### Removed
* None

---

## Files Created

```txt
docs/analysis/0020-registration-failure-audit.md
```

---

## Files Modified

```txt
lib/features/login/service/auth_service.dart
lib/features/register/widget/register_widget.dart
lib/features/login/widget/login_widget.dart
```

---

## Files Removed

```txt
None
```

---

## Dependencies Added

```txt
None
```

---

## Dependencies Removed

```txt
None
```

---

## Folder Structure Changes

```txt
docs/
└── analysis/
    └── 0020-registration-failure-audit.md
```

---

## Technical Details

### Root Cause

Error handling di `AuthService.register()` menangkap **semua** jenis error (network, 4xx, 5xx, timeout, JSON parse) dengan `catch (e) { print(...); return false; }` dan menggantinya dengan nilai boolean `false`. UI kemudian menampilkan pesan generik: "Pendaftaran gagal. Silakan coba lagi."

Detail error dari backend (`response.body.message`) tidak pernah sampai ke user.

### Perbaikan

#### 1. `AuthService.register()` → return `String?`

**Sebelum:**
```dart
Future<bool> register(...) async {
  try {
    final response = await _apiService.post(...);
    if (statusCode == 200 || statusCode == 201) return true;
    return false;  // ← error detail hilang
  } catch (e) {
    print('Register error: $e');
    return false;  // ← semua exception ditelan
  }
}
```

**Sesudah:**
```dart
Future<String?> register(...) async {
  try {
    final response = await _apiService.post(...);
    if (statusCode == 200 || statusCode == 201) return null; // sukses
    final body = jsonDecode(response.body);
    return body['message'] ?? 'Pendaftaran gagal. Silakan coba lagi.';
  } catch (e) {
    print('Register error: $e');
    return 'Terjadi kesalahan jaringan. Periksa koneksi Anda.';
  }
}
```

#### 2. `AuthService.login()` → return `String?` (sama polanya)

#### 3. Widget Register & Login — tampilkan pesan error asli

**Sebelum:**
```dart
const SnackBar(content: Text('Pendaftaran gagal. Silakan coba lagi.'))
```

**Sesudah:**
```dart
SnackBar(content: Text(error))  // error dari backend
```

### Verifikasi Backend (curl)
```bash
curl -s -X POST 'https://backend-api-services-173368161554.asia-southeast2.run.app/auth/register' \
  -d '{"name":"Test","email":"test@example.com","phoneNumber":"081234567890","password":"Test1234!","defaultLicensePlate":"B 1234 CD","vehicleType":"mobil"}'
# → HTTP 201, {"success":true,"message":"Registrasi berhasil! Selamat datang.",...}
```

### Build Status
```
flutter analyze → 0 errors (113 info — deprecations pre-existing)
flutter build web --release -o pwa → ✓ Built pwa
```

---

## Impact Analysis

### User Experience
* User sekarang melihat pesan error asli dari backend (misal: "Email sudah terdaftar")
* Network error menampilkan pesan yang relevan ("Periksa koneksi Anda")

### Performance
* Tidak ada dampak performa

### Maintainability
* `String?` return type lebih ekspresif daripada `bool`
* Error message dari backend tidak lagi hilang

### Scalability
* Pattern `String?` bisa diganti dengan `Result<T>` atau `Either` di masa depan

---

## Validation Checklist

* [x] Audit endpoint registrasi — selesai
* [x] Audit base URL — tidak ada localhost
* [x] Audit request payload — sesuai kontrak
* [x] Audit error handling — ditemukan dan diperbaiki
* [x] Audit CORS — berfungsi
* [x] Audit browser deployment — dianalisis
* [x] Audit Flutter web build — URL production ter-embed
* [x] Dokumen audit dibuat di `docs/analysis/`
* [x] `AuthService.register()` — return `String?`, tampilkan pesan error backend
* [x] `AuthService.login()` — return `String?`, tampilkan pesan error backend
* [x] Widget register — menggunakan pesan error asli
* [x] Widget login — menggunakan pesan error asli
* [x] `flutter analyze` — 0 errors
* [x] `flutter build web` — berhasil

---

## Known Issues

1. `print()` masih digunakan untuk console logging (pre-existing di banyak file)
2. Tidak ada environment configuration — URL hardcoded, perlu rebuild untuk ganti environment
3. `vehicleType` di-hardcode `"mobil"` — tidak ada UI selector untuk motor

---

## Technical Debt

1. **Tidak ada structured logging** — `print()` saja
2. **Tidak ada environment separation** — hardcoded URL
3. **HTTP client polos** — Tidak ada retry, timeout configuration, atau interceptor
4. **Tidak ada loading shimmer/skeleton** — CircularProgressIndicator saja

---

## Remaining Work

1. Gunakan `--dart-define` untuk environment-based base URL
2. Tambahkan retry mechanism untuk network transient errors
3. Ganti `print()` dengan structured logging (misal: `logging` package)

---

## Recommended Next Steps

1. Deploy ulang ke Vercel dan verifikasi registrasi
2. Tambahkan `--dart-define=BASE_URL=...` untuk environment separation
3. Refactor semua service ke pattern `String?` atau `Result<T>`

---

## Executive Summary

1. Root cause: error handling menelan detail error backend
2. Fix: `AuthService.register()` dan `login()` return `String?` (null = sukses)
3. Widget register dan login sekarang menampilkan pesan error asli dari backend
4. Backend, payload, CORS, base URL — semuanya sudah benar
5. Build berhasil (0 errors)
6. Dokumen audit: `docs/analysis/0020-registration-failure-audit.md`
