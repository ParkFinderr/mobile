# Audit & Verification Report — Profile Photo Upload Feature

This document presents the audit results and verification of the profile photo upload feature for the ParkFinder mobile app/PWA.

---

## 1. Struktur Fitur Upload Foto
Fitur upload foto profil sekarang diimplementasikan pada beberapa layer aplikasi:
- **UI Layer (`lib/features/profil/page/edit_profil_page.dart`)**:
  - Avatar dan tombol "Ubah Foto" sekarang dibungkus dengan `GestureDetector`.
  - Menggunakan package `image_picker` untuk memilih gambar dari galeri/sistem file secara cross-platform (kompatibel untuk Android, iOS, Web, Desktop).
  - Menggunakan `cached_network_image` untuk menampilkan avatar dari URL secara efisien dengan image caching, shimmer placeholder, dan fallback error widget.
  - Menangani pemanggilan service, status loading (`_isSaving`), dan menampilkan feedback ke user menggunakan `SnackBar`.
- **UI Layer (`lib/features/profil/widget/profil_widget.dart` & `lib/features/profil/widget/profile_avatar_widget.dart`)**:
  - `ProfileAvatarWidget` diperbarui untuk menerima parameter opsional `photoUrl` dan merendernya menggunakan `CachedNetworkImage`.
  - `ProfilWidget` menyuplai `_profileData?.photoUrl` ke `ProfileAvatarWidget` agar avatar terbaru langsung ditampilkan di halaman profil utama.
- **Service Layer (`lib/features/profil/service/profile_service.dart`)**:
  - Model `ProfileData` ditambahkan field `photoUrl` opsional yang diparsing langsung dari response data profil backend.
  - Method `uploadPhoto(List<int> bytes, String fileName)` ditambahkan untuk melakukan request upload foto profil.
- **Network Layer (`lib/core/network/api_service.dart`)**:
  - Method `multipartPost` ditambahkan ke `ApiService` untuk menangani request `multipart/form-data` secara cross-platform menggunakan `http.MultipartRequest` dan `http.MultipartFile.fromBytes` (tidak bergantung pada file path lokal sehingga kompatibel 100% dengan Flutter Web).

---

## 2. Endpoint yang Digunakan
- **Endpoint**: `POST /users/profile/photo`
- **Base URL**: `https://backend-api-services-173368161554.asia-southeast2.run.app`
- **Method**: `POST`
- **Headers**:
  - `Authorization: Bearer <token>`
  - `Accept: application/json`
  - `Content-Type: multipart/form-data` (boundary diatur secara otomatis oleh http client)
- **Body**:
  - Multipart field: `image` (berisi file gambar JPEG/PNG)

---

## 3. Request Payload Aktual
Request payload dikirimkan dalam format `multipart/form-data`.
- **Field Name**: `image`
- **Mime Type**: diatur dinamis berdasarkan format file (misal `image/jpeg` atau `image/png`)
- **Filename**: nama file asli dari picker (misal `test.jpg` atau `avatar.png`)
- **Content**: byte data file yang dibaca langsung secara asinkron dari `XFile` melalui `readAsBytes()`

---

## 4. Response Backend Aktual
Response ketika upload berhasil (HTTP 200 OK):
```json
{
  "success": true,
  "message": "Foto profil berhasil diunggah.",
  "data": {
    "photoUrl": "https://storage.googleapis.com/parkfinderrbucket/imageProfile/JN3sa2xIoInH4UK2QipN-1781184768390.jpg"
  }
}
```

Response ketika token tidak valid/kadaluarsa (HTTP 403 Forbidden):
```json
{
  "success": false,
  "message": "Token tidak valid (Malformed).",
  "data": null
}
```

Response ketika tidak mengirimkan file/field kosong (HTTP 400 Bad Request):
```json
{
  "success": false,
  "message": "\"image\" is required"
}
```

---

## 5. Kompatibilitas Flutter Web
Implementasi fitur ini dirancang khusus agar sepenuhnya kompatibel dengan **Flutter Web & PWA**:
1. **File Selection**: Menggunakan `image_picker` yang secara internal pada Flutter Web menggunakan elemen `<input type="file">` HTML5.
2. **Byte Reading**: Menggunakan `pickedFile.readAsBytes()` yang mengembalikan `Uint8List`. Ini menghindari penggunaan path (`File(path)`) dari `dart:io` yang memicu error `Unsupported operation` di web browser.
3. **Multipart Request**: Menggunakan `http.MultipartFile.fromBytes` daripada `fromPath` agar data gambar dapat dikirim dalam bentuk byte array memory secara aman dan cross-platform.
4. **CORS Handling**: Backend dikonfigurasi dengan header `Access-Control-Allow-Origin: *` dan mengizinkan header `Authorization` serta `Content-Type`, sehingga browser PWA dapat berinteraksi dengan API tanpa hambatan preflight request.

---

## 6. Temuan Bug & Root Cause
Sebelum perbaikan dilakukan, ditemukan beberapa masalah kritis:
1. **Fitur Upload Belum Terintegrasi**: Halaman `EditProfilPage` memiliki tombol "Ubah Foto" namun hanya bersifat statis (tanpa event listener/handler). Tidak ada logic file picker maupun integrasi API.
2. **Model ProfileData Kurang Lengkap**: `ProfileData` tidak memetakan field `photoUrl` dari response backend. Akibatnya, data foto profil yang tersimpan di server tidak pernah ditampilkan pada UI.
3. **Ketiadaan Dukungan Multipart di ApiService**: Class `ApiService` hanya mendukung request JSON (`application/json`) dan tidak memiliki method untuk memproses request `multipart/form-data`.
4. **Ketergantungan Package yang Kurang**: Project belum menyertakan dependency `image_picker` untuk memfasilitasi input file gambar dari user secara lintas-platform.

---

## 7. Tindakan Perbaikan yang Dilakukan
Seluruh masalah di atas telah berhasil diselesaikan secara langsung:
1. **Dependency Ditambahkan**: Memasang package `image_picker` ke `pubspec.yaml` untuk penanganan file selection yang kompatibel dengan Web/Android/iOS/Desktop.
2. **ApiService Diperluas**: Menambahkan method `multipartPost()` ke `ApiService` menggunakan `http.MultipartFile.fromBytes` agar kompatibel penuh dengan Flutter Web (menghindari crash kompilasi platform-specific).
3. **Model & Service Diperbarui**:
   - Menambahkan field `photoUrl` ke model `ProfileData`.
   - Mengimplementasikan method `uploadPhoto()` ke `ProfileService`.
4. **UI Terintegrasi**:
   - Menghubungkan tombol "Ubah Foto" dan komponen Avatar di `EditProfilPage` ke picker dan service upload.
   - Menggunakan `CachedNetworkImage` di `ProfileAvatarWidget` dan `EditProfilPage` agar foto profil terbaru langsung dirender dari CDN backend begitu diunggah tanpa perlu restart/re-login.
   - Menambahkan state loading (`_isSaving`) dan penanganan error/success snackbar yang informatif.

---

## 8. Rekomendasi Langkah Selanjutnya
1. **Validasi Ukuran File**: Tambahkan pengecekan ukuran file di tingkat UI (misal maksimal 5MB) sebelum melakukan upload ke backend untuk menghemat kuota bandwidth pengguna dan performa server.
2. **Image Cropper/Compressor**: Tambahkan package kompresi gambar opsional sebelum upload jika ingin mengurangi beban payload jaringan secara lebih signifikan.
3. **Shimmer Skeleton Loading**: Terapkan efek shimmer loading pada avatar saat profil sedang di-fetch di awal halaman.
