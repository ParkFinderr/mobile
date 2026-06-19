# Task 0034 — Fix Regression Icon & Camera Scanner

Date: 2026-06-12
Task: 0034 — Fix Regression Icon & Camera Scanner

---

## Regression 1 — Material Icons Hilang

### Gejala
Seluruh Material Icons (Home, Profile, Camera, Bottom Nav, dll.) berubah menjadi karakter kotak kosong (□).

### Root Cause

| # | Faktor | Detail |
|---|--------|--------|
| 1 | **`fontFamily: 'Roboto'` di theme** | App theme (`app.dart:41`) menetapkan `fontFamily: 'Roboto'` sebagai font default. Pada Flutter Web dengan CanvasKit, font family ini memicu engine untuk mencoba load font Roboto dari Google Fonts CDN. Loading Roboto dari CDN dapat gagal (network, CORS, ad blocker) dan interferensi ini menyebabkan CanvasKit gagal meregistrasi Material Icons font dengan benar. |
| 2 | **Google Fonts Poppins** | `GoogleFonts.poppinsTextTheme()` sudah menetapkan font Poppins untuk semua text style secara eksplisit. `fontFamily: 'Roboto'` bersifat redundant dan tidak diperlukan. |
| 3 | **Font file tetap valid** | Font `MaterialIcons-Regular.otf` (14KB, 112 glyphs) ada di `assets/fonts/`, `FontManifest.json` mereferensikannya dengan benar, dan semua 51 codepoint dari JS cocok dengan isi font. Issue bukan di tree-shaker atau missing glyph. |

### Verifikasi

| Item | Hasil |
|------|-------|
| `uses-material-design: true` di pubspec.yaml | ✅ Ada (line 64) |
| `MaterialIcons-Regular.otf` di build | ✅ Ada (14KB, 112 glyphs) |
| FontManifest.json | ✅ Referensi benar |
| Semua 51 JS codepoint match font cmap | ✅ Cocok semua |
| Tree-shaker masukkan semua icon yang dipakai | ✅ (112 glyphs) |
| `fontFamily: 'Roboto'` di theme | ❌ **Redundant** (Poppins sudah di set via GoogleFonts) |

### Fix A
Hapus baris `fontFamily: 'Roboto'` dari theme di `app.dart:41`. GoogleFonts.poppinsTextTheme() sudah menetapkan Poppins untuk semua text style secara eksplisit, sehingga Roboto tidak diperlukan.

---

## Regression 2 — Scanner Kamera Hilang

### Gejala
Halaman scan selalu menampilkan form input manual dengan pesan "Karena batasan kamera pada browser PWA...", meskipun diakses dari Android Chrome / PWA dengan camera permission granted.

### Root Cause

| # | Faktor | Detail |
|---|--------|--------|
| 1 | **`kIsWeb` blanket check** | `welcome_scan_widget.dart:150`: `if (kIsWeb) { return _buildWebLayout(context); }` — menganggap SEMUA platform web tidak punya kamera. |
| 2 | **`MobileScannerController` diguard** | `welcome_scan_widget.dart:33`: `if (!kIsWeb) { _cameraCtrl = MobileScannerController(...); }` — controller hanya diinit untuk native mobile. |
| 3 | **PWA / Android Chrome punya kamera** | `kIsWeb` bernilai `true` untuk PWA yang diinstall dari Chrome Android. Padahal device ini memiliki kamera yang bisa diakses via WebRTC. |
| 4 | **No fallback mechanism** | Tidak ada mekanisme untuk fallback ke manual input jika kamera gagal. Manual input adalah satu-satunya opsi untuk web. |

### Sejarah
Task 0026 sengaja menonaktifkan kamera di web karena konflik antara `image_picker` dan `mobile_scanner` plugin web. Solusi saat itu adalah platform branching: native mobile → camera, web → manual input. Namun ini terlalu agresif — PWA di Android Chrome seharusnya bisa menggunakan kamera.

### Fix B
Ganti blanket `kIsWeb` check dengan try/catch mekanisme:
1. **Init camera di semua platform** — `MobileScannerController` di-create dengan try/catch
2. **Jika berhasil**: tampilkan live camera scanner (sama seperti native mobile)
3. **Jika gagal**: tampilkan form input manual
4. **Toggle**: tombol "Masukkan Kode Manual" di camera overlay, dan tombol "Gunakan Kamera" di manual layout

---

## File yang Diubah

| File | Perubahan |
|------|-----------|
| `lib/app/app.dart:41` | Hapus `fontFamily: 'Roboto'` dari theme |
| `lib/features/welcome_scan/widget/welcome_scan_widget.dart` | Ganti `kIsWeb` → try/catch camera; rename `_buildWebLayout` → `_buildManualLayout`; tambah toggle button; tambah `_initCamera()` method |

## Test Results

| Test | Hasil |
|------|-------|
| `flutter analyze` | 0 errors ✅ (2 pre-existing warnings) |
| `flutter build web --release` | Built pwa ✅ |
| Font codepoints | 112 glyphs ✅ (termasuk `camera_alt_outlined`) |

## Flow Baru Camera

```
Masuk halaman scan
  ↓
Try create MobileScannerController
  ├── Berhasil → Camera Overlay (dengan tombol "Masukkan Kode Manual")
  └── Gagal → Manual Layout (dengan tombol "Gunakan Kamera")
         ↓ (tap "Gunakan Kamera")
         Try create ulang
           ├── Berhasil → Camera Overlay
           └── Gagal → tetap manual
```

```
Camera Overlay
  ├── Live scanner
  ├── Tombol senter
  ├── Tombol balik kamera
  └── "Masukkan Kode Manual" → switch ke manual layout

Manual Layout
  ├── Input kode tiket
  ├── Tombol verifikasi
  └── "Gunakan Kamera" → switch ke camera overlay
```
