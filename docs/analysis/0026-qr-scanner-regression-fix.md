# Audit & Bug Fix Report — QR Scanner Failure & User Flow Revision

This document outlines the root cause analysis, file changes, and implementation details for fixing the QR scanner regression bug and revising the user flow.

---

## 1. Root Cause — QR Scanner Failure
- **Issue**: Tapping on the Scan QR screen on Flutter Web / PWA resulted in either a total freeze or a complete app crash, preventing any ticket verification.
- **Cause**: The addition of the `image_picker` package and its web plugins (`image_picker_for_web`, `file_selector`) caused conflicts with `mobile_scanner`'s native browser camera initialization. Instantiating `MobileScannerController` on web browsers without direct permission or in an insecure/iframe sandbox context triggers uncaught JS exceptions, breaking the Flutter widget rendering cycle.
- **Solution**: Implemented **Platform Branching**. On Flutter Web, camera-based scanning is replaced by a clean, user-friendly **Manual Ticket Verification Form** (text input + button), bypassing the unstable browser camera API entirely. On native mobile apps (Android/iOS), the camera-based live scanner remains active.

---

## 2. revised User Flow Validation
We revised the app navigation flow to match ParkFinder's business requirements:
- **Login Redirect**: Successfully updated the post-login destination so that users land directly on the **Home/Dashboard** (`/home`), rather than being forced to open the scan page (`/welcome-scan`).
- **Ticket Verification Guards**: Added active ticket validation check before letting users access any booking sections. If `ActiveTicketStorage` has no verified ticket:
  - Tapping "Cari Parkir" (Search Bar) on the Home Page redirects to `/welcome-scan`.
  - Tapping any specific parking building item redirects to `/welcome-scan`.
  - Tapping "Parkir" (Booking) on the bottom navigation bar redirects to `/welcome-scan`.
  - Entering `/booking` or `/detail-booking` directly via routing redirects to `/welcome-scan` (safety net inside `initState`).

---

## 3. Files Modified
- [welcome_scan_widget.dart](file:///workspaces/mobile-front/lib/features/welcome_scan/widget/welcome_scan_widget.dart):
  - Added conditional check using `kIsWeb` to skip `MobileScannerController` initialization on Web.
  - Implemented the manual verification layout and logic (`_buildWebLayout`) for web clients.
  - Added safe navigation guards for mobile-specific controller calls.
- [login_widget.dart](file:///workspaces/mobile-front/lib/features/login/widget/login_widget.dart):
  - Changed the successful login callback redirection route from `AppRoutes.welcomeScan` to `AppRoutes.home`.
- [home_widget.dart](file:///workspaces/mobile-front/lib/features/home/widget/home_widget.dart):
  - Integrated ticket checks on the search bar, list items, and bottom navigation taps.
- [booking_widget.dart](file:///workspaces/mobile-front/lib/features/booking/widget/booking_widget.dart):
  - Added active ticket check inside `initState` as a route fallback redirection.
- [detail_booking_widget.dart](file:///workspaces/mobile-front/lib/features/detail_booking/widget/detail_booking_widget.dart):
  - Added active ticket check inside `initState` as a route fallback redirection.

---

## 4. Test Results
- **Scanner Web/PWA**: Bypassed camera API initialization. Manual verification screen renders and processes codes successfully via the backend `/access/verify` endpoint.
- **Scanner Mobile**: Remains untouched, continuing to use the camera scanner.
- **Navigation Flow**:
  - Login -> Redirects to `/home` (Passed).
  - Home (No Active Ticket) -> Click Booking / Search -> Redirects to `/welcome-scan` (Passed).
  - Web Scan Screen -> Enter code -> Click "Verifikasi Tiket" -> Redirects to `/scan-berhasil` (Passed).
  - Home (With Active Ticket) -> Click Booking / Search -> Redirects to `/booking` or `/detail-booking` (Passed).

---

## 5. Verification Status
- **Static Analysis (flutter analyze)**: ✅ `No issues found!`
- **Web Build (flutter build web)**: ✅ Compiled successfully.
- **Final Status**: Fixed.
