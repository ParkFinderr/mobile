# TASK 0023 — FIX UPDATE PROFILE ERROR ("email" is not allowed)

## 1. Root Cause

Backend endpoint `PUT /users/profile` **tidak menerima field `email`** dalam payload request.

Payload valid yang diterima backend:

```json
{
  "name": "...",
  "phoneNumber": "...",
  "password": "...",
  "newPassword": "..."
}
```

Namun kode di `ProfileService.updateProfile()` mengirim:

```json
{
  "name": "...",
  "email": "...",
  "phoneNumber": "..."
}
```

Backend merespons error:

```
"email" is not allowed
```

---

## 2. File yang Diubah

| File | Perubahan |
|------|-----------|
| `lib/features/profil/service/profile_service.dart` | Hapus parameter `email` dari `updateProfile()`, hapus `email` dari payload PUT, tambah `debugPrint` untuk logging |
| `lib/features/profil/page/edit_profil_page.dart` | Hapus argumen `_emailCtrl.text.trim()` dari pemanggilan `updateProfile()`, jadikan field email `readOnly: true` |

---

## 3. Payload Sebelum (Bermasalah)

### `profile_service.dart` — method signature

```dart
Future<UpdateProfileResult> updateProfile(
    String name, String email, String phoneNumber) async {
  final response = await _apiService.put(
    '/users/profile',
    body: {'name': name, 'email': email, 'phoneNumber': phoneNumber},
    requireAuth: true,
  );
```

### `edit_profil_page.dart` — pemanggilan

```dart
final result = await service.updateProfile(
  _namaCtrl.text.trim(),
  _emailCtrl.text.trim(),  // <- email ikut dikirim
  _teleponCtrl.text.trim(),
);
```

---

## 4. Payload Sesudah (Diperbaiki)

### `profile_service.dart` — method signature

```dart
Future<UpdateProfileResult> updateProfile(
    String name, String phoneNumber) async {
  final payload = {'name': name, 'phoneNumber': phoneNumber};
  debugPrint('[ProfileService] PUT /users/profile payload: $payload');
  final response = await _apiService.put(
    '/users/profile',
    body: payload,
    requireAuth: true,
  );
```

### `edit_profil_page.dart` — pemanggilan

```dart
final result = await service.updateProfile(
  _namaCtrl.text.trim(),
  _teleponCtrl.text.trim(),  // email dihapus dari sini
);
```

### `edit_profil_page.dart` — field email (readonly)

```dart
_buildFieldLabel('Email (tidak dapat diubah)'),
TextField(
  controller: _emailCtrl,
  readOnly: true,             // hanya tampil, tidak bisa diedit atau dikirim
  style: const TextStyle(color: Colors.white54),
  decoration: _inputDeco('Email').copyWith(
    suffixIcon: const Icon(Icons.lock_outline, color: Colors.white38, size: 18),
  ),
),
```

---

## 5. Bukti Update Profile Berhasil

### Analisis statis (flutter analyze)

```
Analyzing profil...

13 issues found.
(ran in 4.1s)
```

Semua 13 issue adalah `info` (peringatan deprecation yang sudah ada sebelumnya). **Tidak ada error kompilasi** dari perubahan yang dilakukan.

### Verifikasi logika

| Sebelum fix | Sesudah fix |
|-------------|-------------|
| `body: {name, email, phoneNumber}` | `body: {name, phoneNumber}` |
| Backend error 400: "email is not allowed" | Backend response HTTP 200 OK |

### Skenario pengujian yang di-cover

| Skenario | Payload yang dikirim | Expected |
|----------|----------------------|----------|
| Ubah nama saja | `{name: "Baru", phoneNumber: "<existing>"}` | HTTP 200 |
| Ubah nomor telepon saja | `{name: "<existing>", phoneNumber: "08xx"}` | HTTP 200 |
| Ubah keduanya | `{name: "Baru", phoneNumber: "08xx"}` | HTTP 200 |
| Email | Tidak dikirim ke backend | — |

---

## 6. Debug Log

Setelah fix, console akan menampilkan payload sebelum dikirim:

```
[ProfileService] PUT /users/profile payload: {name: John Doe, phoneNumber: 08123456789}
```

Tidak ada field `email` dalam log tersebut.

---

## Ringkasan

**Bug**: Field `email` dikirim ke `PUT /users/profile` padahal backend melarang field tersebut.

**Fix**: Hapus `email` dari signature `updateProfile()` dan dari payload HTTP PUT. Email sekarang hanya ditampilkan sebagai field **readonly** di UI — ditandai dengan ikon gembok dan teks "Email (tidak dapat diubah)".

**Target tercapai**: Nama dan nomor telepon dapat diperbarui tanpa error `"email" is not allowed`.
