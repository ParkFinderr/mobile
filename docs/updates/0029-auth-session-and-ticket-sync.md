# Update: Auth Session Persistence & Ticket Sync (Task 0029)

## Changes
- **`lib/features/splash_screen/widget/splash_screen_widget.dart`**:
  - Implemented auto-login by checking `jwt_token` in `SharedPreferences` and validating it via `/users/profile`. Redirects to `AppRoutes.home` on success.
- **`lib/features/login/service/auth_service.dart`**:
  - Updated `logout` to explicitly clear `ActiveTicketStorage` and `ActiveReservationStorage` in addition to clearing the user token.
- **`lib/features/profil/widget/profil_widget.dart`**:
  - Refactored `_doLogout` to navigate directly to `AppRoutes.login` (bypassing `AppRoutes.welcome`).
- **`lib/features/home/widget/home_widget.dart`**:
  - Imported `ActiveReservationStorage` and `TicketData`.
  - Replaced hardcoded status cards with dynamic data reading from local storage states.
  - Handled three logical states for tickets: "Belum Aktif", "Aktif", and "Tidak Aktif" (Checked Out/Expired).

## Testing
1. Successfully logged in, restarted app, and verified auto-login bypassed Welcome Screen directly into Home.
2. Verified Home dynamically hides/shows ticket and booking cards based on active reservations and scanned tickets.
3. Verified logging out correctly wipes caches and drops user to the Login screen.
4. Clean build via `flutter build web --release` without regressions.
