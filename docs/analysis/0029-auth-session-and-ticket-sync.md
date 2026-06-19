# Analysis: Auth Session Persistence & Ticket Sync (Task 0029)

## Root Causes
1. **Session Persistence**: The `SplashScreenWidget` unconditionally redirected to `WelcomePage`, ignoring any existing JWT token stored in `SharedPreferences`. `logout` also didn't clear active tickets or reservations.
2. **Ticket Status Inconsistency**: The `HomeWidget` used hardcoded data and isolated state for the ticket and booking status cards instead of querying the unified local storages (`ActiveTicketStorage` and `ActiveReservationStorage`).

## Implementations
- **Auto-Login**: Updated `_goToHome` in `SplashScreenWidget` to retrieve the token and validate it via `ProfileService().getProfile()`. If valid, users bypass the Welcome/Login screens entirely and navigate straight to `Home`.
- **Session Cleanup**: Updated `AuthService.logout` to clear `ActiveTicketStorage` and `ActiveReservationStorage` alongside the JWT token to ensure completely clean state on logout.
- **Dynamic Home Status**: Updated `HomeWidget` to read from both `ActiveTicketStorage` and `ActiveReservationStorage` during `initState`. The status cards and the ticket status banner were refactored to dynamically reflect three states: "Belum Aktif" (not scanned), "Aktif" (scanned, waiting to book), and "Tidak Aktif" (checked out or expired).
- **Navigation Flow Fix**: Updated `ProfilWidget` logout to navigate explicitly to `AppRoutes.login` instead of `AppRoutes.welcome`.

## Validations
- Session survives app restart (`token` check logic added to splash screen).
- Ticket statuses map correctly across modules (Home now accurately matches the Booking view's conditions).
- `flutter build web` passes without compilation regressions.
