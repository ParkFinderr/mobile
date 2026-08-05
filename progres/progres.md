# Progress Proyek Redesign ParkFinder

## Selesai

- **Sinkronisasi Total Slot Parkir, Timer Real-Time Beranda vs Status Parkir, & Notifikasi Real-Time Backend**:
  - **Sinkronisasi Slot Parkir & Penjagaan Slot Name**:
    - Memperbarui `HomeWidget` ([home_widget.dart](file:///c:/programming/mobile-front/lib/features/home/widgets/home_widget.dart)) dan `StatusKendaraanPage` ([status_kendaraan_page.dart](file:///c:/programming/mobile-front/lib/features/home/pages/status_kendaraan_page.dart)) agar `slotName` asli pengguna (misal `A01`, `A05`, dsb.) tidak lagi terhapus atau tertimpa string kosong saat melakukan sinkronisasi dengan data backend.
    - Slot yang dipilih kini ditampilkan dengan tepat dan konsisten baik pada Banner *Parkir Aktif* di Beranda maupun pada Layar *Status Kendaraan*.
  - **Sinkronisasi Timer Durasi Parkir Beranda & Status Parkir**:
    - Menambahkan periodic timer `1 detik` pada [home_widget.dart](file:///c:/programming/mobile-front/lib/features/home/widgets/home_widget.dart) yang menghitung durasi waktu secara presisi dari `startTime` reservasi backend.
    - Menghapus teks durasi hardcoded (`Masuk: 10:15 WIB (Durasi: 01j 45m)`). Banner Beranda kini menampilkan durasi aktif yang **100% tersinkronisasi** dengan timer di Layar Status Kendaraan (`Status: Parkir Berjalan (Durasi: 00m 15s)`).
  - **Pembersihan Notifikasi Dummy Hardcoded di Header Modal**:
    - Memastikan [user_header_widget.dart](file:///c:/programming/mobile-front/lib/shared/widgets/user_header_widget.dart) dan `NotificationService` ([notification_service.dart](file:///c:/programming/mobile-front/lib/features/notification/services/notification_service.dart)) hanya menampilkan notifikasi *realtime* dari tiket aktif dan riwayat reservasi live backend.
    - Menghapus 3 item notifikasi dummy bawaan (`Pengingat Waktu Parkir 1 jam yang lalu`, `Sesi Parkir Aktif 15 mnt yang lalu`, dsb.).
  - **Re-Build Rilis Web PWA & Ekspor Fresh Bundle**:
    - Berhasil di-compile ulang ke Web PWA rilis (`flutter build web --release`). Bundle rilis rilis segar di [pwa/](file:///c:/programming/mobile-front/pwa) telah diperbarui untuk menghilangkan cache lama di browser.
- **Penyempurnaan Alur Reservasi Parkir, Timer Navigasi 15 Menit, Swap Slot, & Notifikasi Event Lengkap**:
  - **Penataan Alur Reservasi & Verifikasi Tiket**:
    - Pengguna bebas melihat denah, gedung, dan ketersediaan slot parkir tanpa tiket.
    - Ketika pengguna memilih slot parkir pada [detail_booking_widget.dart](file:///c:/programming/mobile-front/lib/features/parking/widgets/detail_booking_widget.dart), sistem mengecek ketersediaan tiket aktif. Jika belum ada tiket aktif, aplikasi menampilkan dialog peringatan dan mengarahkan ke halaman Scan Tiket Masuk ([welcome_scan_page.dart](file:///c:/programming/mobile-front/lib/features/scan/pages/welcome_scan_page.dart)). Jika tiket aktif tersedia, pengguna mengonfirmasi slot, membuat reservasi (`POST /reservations`), dan otomatis dialihkan ke Layar Status Parkir.
  - **Timer Navigasi 15 Menit & Peringatan Waktu Habis**:
    - Pada [status_kendaraan_page.dart](file:///c:/programming/mobile-front/lib/features/home/pages/status_kendaraan_page.dart), bagian *Menunggu Kedatangan* dilengkapi dengan **Countdown Timer Navigasi 15 Menit** (900 detik) real-time.
    - Jika waktu navigasi habis (> 15 menit), sistem menampilkan banner peringatan merah dan memberikan rekomendasi serta tombol **Pindah / Swap Slot Terdekat**.
  - **Pindah / Swap Slot (`POST/PATCH /reservations/{id}/swap`)**:
    - Menambahkan modal bottom sheet *Pindah / Swap Slot* yang menampilkan daftar slot kosong secara live. Memanggil endpoint backend `BookingService.swapReservation(...)` untuk memperbarui reservasi ke slot baru secara langsung.
  - **Konfirmasi Kedatangan ("Saya Sudah Sampai") & Selesai Parkir**:
    - Tombol *"Saya Sudah Sampai"* memanggil `BookingService.arriveReservation(...)` (endpoint `/reservations/{id}/arrive`). Setelah terkonfirmasi, tampilan otomatis beralih ke *Status Parkir Aktif*.
    - Tombol *"Selesai Parkir"* / *"Keluar Parkir"* memanggil `BookingService.completeReservation(...)` (endpoint `/reservations/{id}/complete`), menyelesaikan sesi parkir, dan membersihkan data parkir lokal.
  - **Sistem Notifikasi Event Lengkap (Profile, Tiket, Reservasi, Swap, Complete)**:
    - Memperbarui `NotificationService` ([notification_service.dart](file:///c:/programming/mobile-front/lib/features/notification/services/notification_service.dart)) untuk memunculkan notifikasi otomatis pada event:
      - Perubahan data profil & foto (`ProfileService`).
      - Verifikasi / scan tiket masuk (`ScanService`).
      - Reservasi slot baru (`BookingService.createReservation`).
      - Pindah / swap slot (`BookingService.swapReservation`).
      - Konfirmasi kedatangan & parkir berjalan (`BookingService.arriveReservation`).
      - Selesai / keluar parkir (`BookingService.completeReservation`).
- **Integrasi Notifikasi Real-Time Berbasis REST API Backend Live**:
  - Membuat `NotificationItem` ([notification_item.dart](file:///c:/programming/mobile-front/lib/features/notification/models/notification_item.dart)) dan `NotificationService` ([notification_service.dart](file:///c:/programming/mobile-front/lib/features/notification/services/notification_service.dart)) yang memanfaatkan endpoint backend live yang sudah ada.
  - Memperbarui [user_header_widget.dart](file:///c:/programming/mobile-front/lib/shared/widgets/user_header_widget.dart) untuk me-render daftar notifikasi secara dinamis via `FutureBuilder`, menggantikan data notifikasi dummy hardcoded sebelumnya.
- **Penghapusan Total Duplikasi Onboarding Tutorial Dialog & Floating Tutorial Button**:
  - Menghapus panggilan dan dialog `_checkAndShowTutorial()` serta `_TutorialDialog` pada [home_page.dart](file:///c:/programming/mobile-front/lib/features/home/pages/home_page.dart).
  - Memperbarui [floating_tutorial_widget.dart](file:///c:/programming/mobile-front/lib/shared/widgets/floating_tutorial_widget.dart) untuk mengembalikan `SizedBox.shrink()`.
- **Penyempurnaan Kontras Tinggi & Palette Warna Kamera Scanner & Verifikasi Tiket Manual**:
  - Memperbarui [welcome_scan_widget.dart](file:///c:/programming/mobile-front/lib/features/scan/widgets/welcome_scan_widget.dart) dan [welcome_scan_page.dart](file:///c:/programming/mobile-front/lib/features/scan/pages/welcome_scan_page.dart).
- **Pembaruan Palette Warna Halaman Scan & Konsistensi Feedback Popup/Slide Bottom Sheet dengan Theme (Light/Dark Mode)**:
  - Mengonfigurasi [welcome_scan_widget.dart](file:///c:/programming/mobile-front/lib/features/scan/widgets/welcome_scan_widget.dart) dan [scan_berhasil_widget.dart](file:///c:/programming/mobile-front/lib/features/scan/widgets/scan_berhasil_widget.dart).
- **Pemetaan Dinamis Nama & Detail Gedung pada Peta Parkir (Tanpa Hardcoded Dummy)**:
  - Menyelesaikan bug pemilihan gedung di [detail_booking_widget.dart](file:///c:/programming/mobile-front/lib/features/parking/widgets/detail_booking_widget.dart).
- **Pembersihan Total Sesi Parkir Hantu untuk Akun Baru & Pengalihan Keluar Parkir**:
  - Mengonfigurasi `login` di [auth_service.dart](file:///c:/programming/mobile-front/lib/features/auth/services/auth_service.dart).
- **Generasi QR Code Tiket Masuk Real & Dinamis**:
  - Mengonfigurasi `_showQrCodeDialog` pada [home_widget.dart](file:///c:/programming/mobile-front/lib/features/home/widgets/home_widget.dart).
- **Integrasi Backend Live untuk Status Tiket & Parkir Aktif di Beranda (`HomeWidget`)**:
  - Mengonfigurasi `_checkActiveTicket()` di [home_widget.dart](file:///c:/programming/mobile-front/lib/features/home/widgets/home_widget.dart).
- **Integrasi Statistik Profil (Total Parkir & Parkir Aktif) dengan Live Backend**:
  - Mengonfigurasi kartu statistik pada [profil_widget.dart](file:///c:/programming/mobile-front/lib/features/profile/widgets/profil_widget.dart) dan [stats_card_widget.dart](file:///c:/programming/mobile-front/lib/features/profile/widgets/stats_card_widget.dart).
- **Build Rilis & Ekspor PWA ke Direktori `pwa/`**:
  - Aplikasi berhasil di-compile ke Web PWA rilis (`flutter build web --release`).
- **Import Aset Foto Real dari `cdn-example` (Bukan Template/Dummy Lagi)**:
  - Mengimpor dan mengonfigurasi seluruh foto real dari sampel CDN (`cdn-example/`) ke dalam `lib/assets/` aplikasi.
- **Integrasi Full Real REST API Live Backend**:
  - Aplikasi 100% berkomunikasi langsung dengan server backend Google Cloud Run.
  - Lulus verifikasi analisis kode Flutter (0 error & 0 warning).

## Sedang dikerjakan

- Pengujian PWA pada perangkat mobile Android.

## Tersisa

- Tidak ada (seluruh tugas utama telah diselesaikan).
