# Task 0005 — API Discovery & Dashboard Data Audit

## 1. Service & Endpoint Inventory

### 1.1 `ApiService` (core/network/api_service.dart)
| Method | Signature | Auth Support |
|--------|-----------|-------------|
| GET    | `get(endpoint, {requireAuth})` | ✅ |
| POST   | `post(endpoint, {body, requireAuth})` | ✅ |
| PUT    | `put(endpoint, {body, requireAuth})` | ✅ |
| PATCH  | `patch(endpoint, {body, requireAuth})` | ✅ |
| DELETE | `delete(endpoint, {requireAuth})` | ✅ |

**Base URL**: `https://backend-api-services-173368161554.asia-southeast2.run.app`  
**Auth**: JWT stored in `SharedPreferences` under key `jwt_token`, sent as `Authorization: Bearer <token>`

### 1.2 `AuthService` (features/login/service/auth_service.dart)
| Method | Endpoint | Request Body | Response | Auth | Status |
|--------|----------|-------------|----------|------|--------|
| `login(email, password)` | `POST /auth/login` | `{email, password}` | `{token: string}` | ❌ | ✅ Used |
| `register(name, email, phone, password, plateNumber)` | `POST /auth/register` | `{name, email, phoneNumber, password, plateNumber}` | `200/201` | ❌ | ✅ Used |
| `logout()` | `POST /auth/logout` | — | — | ✅ | ✅ Used |

### 1.3 `ProfileService` (features/profil/service/profile_service.dart)
| Method | Endpoint | Response | Auth | Status |
|--------|----------|----------|------|--------|
| `getProfile()` | `GET /users/profile` | `{name, email, phoneNumber}` | ✅ | ✅ Used (ProfilPage) |
| `getVehicles()` | `GET /users/vehicles` | `[{plateNumber, vehicleType}]` | ✅ | ✅ Used (ProfilPage) |

**Note**: No `PUT/PATCH /users/profile` or `POST/PUT/DELETE /users/vehicles` endpoints implemented yet.

### 1.4 `BookingService` (features/booking/service/booking_service.dart)
| Method | Endpoint | Response | Auth | Status |
|--------|----------|----------|------|--------|
| `getAreas()` | `GET /areas` | `{success, message, data: [{id, name, totalSlots, availableSlots, address}]}` | ✅ | ✅ Used (Home, Booking) |
| `getSlots(areaId)` | `GET /areas/{id}/slots` | `{success, data: [{id, slotName, appStatus, vehicleType}]}` | ✅ | ✅ Used (DetailBooking) |
| `createReservation(slotId, ticketId, name, plateNumber)` | `POST /reservations` | `{slotId, ticketId, name, plateNumber}` → `200/201` | ✅ | ✅ Used (DetailBooking) |

**Models**:
- `ParkingArea`: `{id, name, address, totalSlot, availableSlots}` (from `GET /areas`)
- `ParkingSlot`: `{id, slotNumber, status, vehicleType}` (from `GET /areas/{id}/slots`)

### 1.5 `ScanService` (features/halaman_scan/service/scan_service.dart)
| Method | Endpoint | Request Body | Auth | Status |
|--------|----------|-------------|------|--------|
| `verifyTicket(ticketId)` | `POST /access/verify` | `{ticketId}` | ✅ | ⚠️ Route is dead |

**Issue**: Backend expects `qrCode` per `scan.md`, but mobile sends `ticketId`.

---

## 2. Route Inventory (app_routes.dart)

| # | Route Name | Path | Screen | Status | Data Source |
|---|------------|------|--------|--------|-------------|
| 1 | `splashScreen` | `/` | SplashScreenPage | ✅ Used | Static |
| 2 | `welcome` | `/welcome` | WelcomePage | ✅ Used | Static |
| 3 | `welcomeTransition` | `/welcome-transition` | WelcomeTransitionPage | ✅ Used | Static |
| 4 | `login` | `/login` | LoginPage | ✅ Used | API (AuthService) |
| 5 | `register` | `/register` | RegisterPage | ✅ Used | API (AuthService) |
| 6 | `welcomeScan` | `/welcome-scan` | WelcomeScanPage | ✅ Used | Static (scanner) |
| 7 | `animasiScan` | `/animasi-scan` | AnimasiScanPage | ❌ Dead | 3 hardcoded items |
| 8 | `halamanScan` | `/halaman-scan` | HalamanScanPage | ❌ Dead | API (ScanService) |
| 9 | `scanBerhasil` | `/scan-berhasil` | ScanBerhasilPage | ❌ Dead | Hardcoded |
| 10 | `home` | `/home` | HomePage | ✅ Used | Mixed (API + hardcoded) |
| 11 | `tutorPopup` | `/tutor-popup` | TutorPopupPage | ❌ Dead | Static |
| 12 | `booking` | `/booking` | BookingPage | ✅ Used | API (BookingService) |
| 13 | `detailBooking` | `/detail-booking` | DetailBookingPage | ✅ Used | API (BookingService) |
| 14 | `history` | `/history` | HistoryPage | ✅ Used | 8 hardcoded items |
| 15 | `profil` | `/profil` | ProfilPage | ✅ Used | API (ProfileService) |
| 16 | `editProfil` | `/edit-profil` | EditProfilPage | ✅ Used | Hardcoded (no API) |
| 17 | `pengaturan` | `/pengaturan` | PengaturanPage | ✅ Used | Local state only |
| 18 | `statusKendaraan` | `/status-kendaraan` | StatusKendaraanPage | ✅ Used | All hardcoded |
| 19 | (unnamed) | — | WelcomeTransitionPage | ✅ Used | — |

**3 Dead Routes**: `/animasi-scan`, `/halaman-scan`, `/scan-berhasil`, `/tutor-popup` — routes exist but are never called from main navigation flow.

---

## 3. Hardcoded Data Audit (All Screens)

### 3.1 `HomeWidget` (features/home/widget/home_widget.dart)

| Item | Line(s) | Current Value | Should Come From |
|------|---------|---------------|------------------|
| User name | 115 | `'Imam Ariadi'` | `GET /users/profile` → `name` |
| Greeting | 116 | `'Selamat Pagi'` | Computed from time of day |
| Status Card 1 — subtitle | 257 | `'Diaktifkan Sejak\n01:43:02'` | Active session API data |
| Status Card 2 — subtitle | 262-264 | `'Slot A4 – Lantai 1\nAktivasi dalam 15 menit'` | Booking/reservation data |
| Status Card 3 — subtitle | 271 | `'01:43:02'` | Active session timer |
| Status Card 3 — location | 270 | `'Lantai 1 - Zona A- Slot A3'` | Active session data |
| EndSession — vehiclePlate | 96 | `'D 12345 FE'` | Active session data |
| EndSession — parkingDuration | 97 | `'3 Jam 10 Menit'` | Active session timer |
| Parking list | 60-69 | ✅ FIXED in Task 0004 | `GET /areas` |

### 3.2 `StatusKendaraanPage` (features/home/page/status_kendaraan_page.dart)

| Item | Line(s) | Current Value | Should Come From |
|------|---------|---------------|------------------|
| Vehicle name | 82 | `'McLaren Senna'` | Active session / user vehicle |
| Plate number | 91 | `'D 12345 FE'` | Active session data |
| Slot number | 143 | `'A3'` | Active reservation data |
| Floor | 151 | `'Lantai 1'` | Active reservation data |
| Elapsed time | 160-163 | `'03 : 10 : 32 Detik'` | Real timer (`_seconds` never incremented) |
| Timer logic | 20 | `int _seconds = 0` | No `Timer.periodic` — stuck at 0 |

### 3.3 `ScanBerhasilWidget` (features/scan_berhasil/widget/scan_berhasil_widget.dart)

| Item | Line(s) | Current Value | Should Come From |
|------|---------|---------------|------------------|
| Ticket code | 171 | `'TXT-20260302-0054'` | Scan result → API response |
| Route | — | Dead route | Not navigated to anywhere |

### 3.4 `HistoryWidget` (features/history/widget/history_widget.dart)

| Item | Line(s) | Current Value | Should Come From |
|------|---------|---------------|------------------|
| All 8 history items | 49-60 | All identical hardcoded data | `GET /users/history` or `GET /reservations/history` |
| User name | 85 | `'Imam Ariadi'` | `GET /users/profile` |
| Greeting | 86 | `'Selamat Pagi'` | Computed |

### 3.5 `ProfilWidget` (features/profil/widget/profil_widget.dart)

| Item | Line(s) | Current Value | Should Come From |
|------|---------|---------------|------------------|
| Name | 98 | ✅ Real from API (`_profileData?.name`) | `GET /users/profile` |
| Stats — totalParkir | 115 | `'0'` | User stats API |
| Stats — parkirAktif | 116 | `'0'` | User stats API |
| Email / Phone / Vehicle | 127-137 | ✅ Real from API | `GET /users/profile` + `GET /users/vehicles` |
| Member label | 108 | `'Member Aktif'` | Static (acceptable) |

### 3.6 `EditProfilPage` (features/profil/page/edit_profil_page.dart)

| Item | Line(s) | Current Value | Should Come From |
|------|---------|---------------|------------------|
| Nama controller | 12 | `'Imam Ariadi'` | `GET /users/profile` → `name` |
| Email controller | 14 | `'imamariadi775@gmail.com'` | `GET /users/profile` → `email` |
| Telepon controller | 15 | `'085788322061'` | `GET /users/profile` → `phoneNumber` |
| Plat controller | 16 | `'D 12345 FE'` | `GET /users/vehicles` → `plateNumber` |
| Merek controller | 17 | `'Honda'` | `GET /users/vehicles` → `vehicleType` |
| Model controller | 18 | `'Civic'` | `GET /users/vehicles` → (missing field) |
| Save button | 312 | `_showSuccess()` (no API call) | `PUT /users/profile` + `POST /users/vehicles` |

### 3.7 `DetailBookingWidget` (features/detail_booking/widget/detail_booking_widget.dart)

| Item | Line(s) | Current Value | Should Come From |
|------|---------|---------------|------------------|
| App bar title | 109 | `'Teknik Elektro Universitas Lampung'` | `GET /areas/{id}` → area name |
| Floor tabs | 84 | `['Semua', 'Lantai 1', 'Lantai 2']` | `GET /areas/{id}/slots` → actual floors |
| Zone name | 142 | `'Zona A - Lantai 1'` | API or area metadata |
| Ticket ID (booking) | 183 | `'ticket-user-123'` | Real ticket from active session/API |
| Slots data | 50-81 | ✅ Real from API | `GET /areas/{id}/slots` |

### 3.8 `PengaturanPage` (features/profil/page/pengaturan_page.dart)

✅ All toggle state is local (`setState`). No hardcoded issues — but settings are not persisted to backend or SharedPreferences.

---

## 4. Gap Analysis: Data Needs vs Available Endpoints

| Business Data Need | API Endpoint Available | Implemented in Code | Gap |
|-------------------|----------------------|-------------------|-----|
| User profile (name, email, phone) | `GET /users/profile` | ✅ ProfilWidget | No |
| User profile stats (totalParkir, parkirAktif) | **MISSING** | ❌ Stats hardcoded `'0'` | Need new endpoint `GET /users/stats` or field in profile |
| User vehicles list | `GET /users/vehicles` | ✅ ProfilWidget | No |
| Update profile (name, email, phone) | **MISSING** | ❌ EditProfil simulates success only | Need `PUT /users/profile` |
| Add/delete vehicles | api.md mentions Add/Delete, **MISSING** | ❌ EditProfil has disabled vehicle fields | Need `POST /users/vehicles`, `DELETE /users/vehicles/{id}` |
| Parking areas list | `GET /areas` | ✅ Home, Booking | No |
| Area detail (name, address, etc.) | `GET /areas/{id}` — **NOT IMPLEMENTED** in BookingService | ❌ DetailBooking app bar title hardcoded | Need `GET /areas/{id}` endpoint |
| Slots per area | `GET /areas/{id}/slots` | ✅ DetailBooking | No |
| Create reservation | `POST /reservations` | ✅ DetailBooking | No |
| User reservation history | **MISSING** | ❌ 8 hardcoded items in History | Need `GET /reservations` or `GET /reservations/history` |
| Active parking session | **MISSING** | ❌ StatusKendaraan all hardcoded | Need `GET /access/active-session` or similar |
| End parking session | `POST /access/cancelTicket` — exists in api.md | ❌ Not implemented in any service | Need model + integration |
| Verify ticket (scan) | `POST /access/verify` | ✅ ScanService but route is dead | Need to fix route + API contract |
| Active ticket for current user | **MISSING** | ❌ DetailBooking uses dummy `ticket-user-123` | Need `GET /access/active-ticket` |
| Settings persistence (notifications, theme) | **MISSING** | ❌ PengaturanPage local only | Need API or SharedPreferences persistence |
| User greeting (time-based) | Client-side | ❌ Hardcoded `'Selamat Pagi'` | Need simple time computation |

---

## 5. Summary of Issues

| Severity | Count | Items |
|----------|-------|-------|
| 🔴 Critical | 5 | Timer stuck at 0, EditProfil doesn't save, History 8 hardcoded, Profile stats `'0'`, DetailBooking uses dummy ticketId |
| 🟡 Medium | 6 | 3 dead routes, UserHeader hardcoded name/greeting, EndSessionDialog hardcoded data, Zone header/floor tabs hardcoded, App bar title hardcoded, ScanService API contract mismatch |
| 🟢 Low | 3 | Status cards show placeholder data, Pengaturan not persisted, Area detail endpoint not used |

### Missing Endpoints (not yet implemented in any service)
1. `PUT /users/profile` — update profile
2. `POST /users/vehicles` — add vehicle
3. `DELETE /users/vehicles/{id}` — remove vehicle
4. `GET /areas/{id}` — area detail by ID
5. `GET /reservations` or `GET /reservations/history` — user reservation history
6. `GET /access/active-session` — get active parking session
7. `GET /access/active-ticket` — get user's active ticket
8. `POST /access/cancelTicket` — end parking session (exists in api.md)
9. `GET /users/stats` — user statistics (totalParkir, parkirAktif)

---

## 6. Quick Wins (Low Effort, High Impact)

1. Fix timer in `StatusKendaraanPage` — add `Timer.periodic` to increment `_seconds`
2. Compute greeting from `DateTime.now().hour` instead of hardcoded `'Selamat Pagi'`
3. Load profile data into `EditProfilPage` controllers from `ProfileService`
4. Fetch real profile data for `UserHeaderWidget` used in Home and History
5. Remove dead routes (optional) or mark them clearly
6. Fix `ScanService` to send `qrCode` instead of `ticketId` to match backend contract
