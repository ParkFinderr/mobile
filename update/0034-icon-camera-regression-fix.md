# Update 0034

Date: 2026-06-12
Task: 0034 — Fix Regression Icon & Camera Scanner

---

# Implementation Report

## Task Summary

Perbaiki 2 regression setelah Task 0033:
1. Material Icons muncul sebagai kotak kosong
2. Scanner kamera tidak muncul di Android Chrome/PWA

---

## Changes Made

### Modified

| File | Change |
|------|--------|
| `lib/app/app.dart` | Hapus `fontFamily: 'Roboto'` dari ThemeData (line 41) |
| `lib/features/welcome_scan/widget/welcome_scan_widget.dart` | Ganti `kIsWeb` guard dengan try/catch camera, tambah toggle camera/manual, rename `_buildWebLayout` → `_buildManualLayout` |

---

## Files Created

```
None
```

---

## Files Modified

```
lib/app/app.dart                          (1 line removed)
lib/features/welcome_scan/widget/welcome_scan_widget.dart  (major refactor: ~30 lines changed)
```

---

## Files Removed

```
None
```

---

## Dependencies Added

```
None
```

---

## Dependencies Removed

```
None
```

---

## Technical Details

### Regression 1 — Material Icons

**Before:**
```dart
// app.dart:41 — redundant fontFamily
scaffoldBackgroundColor: const Color(0xFF0D1628),
fontFamily: 'Roboto',
useMaterial3: true,
```

**After:**
```dart
scaffoldBackgroundColor: const Color(0xFF0D1628),
useMaterial3: true,
```

`GoogleFonts.poppinsTextTheme()` sudah menetapkan Poppins untuk semua text style. `fontFamily: 'Roboto'` redundant dan pada Flutter Web + CanvasKit dapat mengganggu loading Material Icons font.

### Regression 2 — Camera Scanner

**Before:**
```dart
// initState
if (!kIsWeb) { _cameraCtrl = MobileScannerController(...); }

// build
if (kIsWeb) { return _buildWebLayout(context); }
```

**After:**
```dart
// initState
try { _cameraCtrl = MobileScannerController(...); }
catch (_) { _useCamera = false; }

// build
if (!_useCamera || _cameraCtrl == null) { return _buildManualLayout(context); }
```

### Flow Diagram

```
┌─────────────────────────────────────┐
│         WelcomeScanWidget           │
│          init camera                │
│        (try/catch all)              │
└──────────┬──────────────────────────┘
           │
     ┌─────┴─────┐
     ▼           ▼
  Camera OK    Camera Fail
     │           │
     ▼           ▼
Camera Overlay  Manual Input
     │           │
     │ + "Manual"│ + "Kamera"
     │   button  │   button
     └───────────┘
```

### Key Design Decisions

1. **Try/catch instead of kIsWeb**: `MobileScannerController` constructor throws JS exception on web without HTTPS/camera. Try/catch handles this gracefully without platform check.

2. **Dual toggle**: Both camera and manual layouts have a button to switch to the other mode. Users on Android Chrome/PWA get camera by default, with manual as fallback.

3. **No platform detection**: The same logic applies to ALL platforms. Native mobile always gets camera (works). PWA with camera gets camera. Desktop web without camera gets manual input.

4. **Manual layout renamed**: `_buildWebLayout` → `_buildManualLayout` karena layout ini tidak lagi spesifik untuk web.

---

## Impact Analysis

### User Experience
- ✅ Android Chrome/PWA: camera scanner langsung muncul (dulu manual input)
- ✅ Desktop web tanpa kamera: manual input tetap muncul
- ✅ Ada toggle antara camera dan manual di kedua mode
- ✅ Pesan error camera yang misleading ("Karena batasan kamera pada browser PWA") diganti

### Performance
- 1 try/catch per initState (negligible overhead)
- Tidak ada tambahan network call

### Maintainability
- Tidak ada platform-specific logic untuk camera
- Satu method `_initCamera()` digunakan untuk init awal dan retry

---

## Validation Checklist

- [x] `flutter analyze` — 0 errors (2 pre-existing warnings)
- [x] `flutter build web --release` — Built pwa ✅
- [x] Camera: try init → success → show overlay
- [x] Camera: try init → fail → show manual
- [x] Camera overlay: "Masukkan Kode Manual" button → switch to manual
- [x] Manual layout: "Gunakan Kamera" button → retry camera
- [x] `fontFamily: 'Roboto'` removed from app.dart
- [x] Tree-shaker included new `camera_alt_outlined` icon (112 glyphs total)
- [x] No ticket flow changes (POST /access/verify, GET /access/activeTicket untouched)

---

## Known Issues

```
None
```

---

## Technical Debt

1. **2 pre-existing warnings** — `_showEndSessionDialog` unused, `AppColors` unused import
2. **No camera permission request UI** — Jika permission denied, user harus grant manually via browser settings

---

## Executive Summary

1. **Root cause icon**: `fontFamily: 'Roboto'` di theme redundant dan interferensi dengan CanvasKit font loading
2. **Fix icon**: Hapus `fontFamily: 'Roboto'` (1 line)
3. **Root cause camera**: `if (kIsWeb)` blanket check memblock kamera untuk SEMUA platform web termasuk Android Chrome/PWA
4. **Fix camera**: Ganti `kIsWeb` → try/catch + toggle camera/manual
5. **0 files created**, **2 files modified**, 0 dependencies
6. **`flutter analyze`**: 0 errors
7. **`flutter build web`**: Built pwa ✅
