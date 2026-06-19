# Laporan Perbaikan: Alur Parkir & Halaman Status Kendaraan (Task 0035)

Laporan ini mendokumentasikan perbaikan alur pengguna (parking flow) untuk melihat ketersediaan gedung/slot tanpa tiket, perbaikan serta integrasi data real pada halaman Status Kendaraan, serta penyelesaian masalah kompatibilitas platform PWA web dan perbaikan pengujian.

---

## 1. Root Cause Analysis (Penyebab Masalah)

### Masalah A: Alur Parkir Terkunci (Gated Flow)
* **Penyebab**: Sebelum perbaikan, file `home_widget.dart` dan `booking_widget.dart` memeriksa status tiket aktif menggunakan `ActiveTicketStorage` saat pengguna mengetuk gedung parkir atau mencari area parkir. Jika tiket kosong/belum di-scan, dialog `NoTicketDialog` akan langsung menghalangi akses secara paksa. Hal ini tidak ramah pengguna (UX buruk) karena pengguna tidak bisa melihat ketersediaan slot sebelum scan tiket.

### Masalah B: Halaman Status Kendaraan Kosong
* **Penyebab**: Halaman `StatusKendaraanPage` hanya menampilkan UI statis/kosong tanpa memuat status sesi dari API atau memproses penyimpanan lokal. Selain itu, navigasi pada bottom bar (tab indeks 2) di beberapa halaman utama (`booking_widget.dart`, `detail_booking_widget.dart`, `history_widget.dart`, `profil_widget.dart`) tidak memproses navigasi ke halaman status kendaraan.

### Masalah C: Inkompatibilitas Scanner di Web (PWA)
* **Penyebab**: Aplikasi diuji coba di platform web/PWA, namun halaman pemindaian barcode langsung menginisialisasi kamera via `mobile_scanner`. Ini menyebabkan crash/error pada platform web jika peramban (browser) tidak mengizinkan akses kamera atau perangkat tidak memilikinya.

---

## 2. Berkas yang Diubah (Files Modified)

| No | Berkas | Deskripsi Perubahan |
|----|--------|---------------------|
| 1 | `lib/core/storage/active_reservation_storage.dart` | Menambahkan field `startTime` pada model `ActiveReservation` untuk melacak kapan booking dilakukan secara presisi. |
| 2 | `lib/features/booking/widget/booking_widget.dart` | Menghapus gate tiket aktif di `initState`. Menambahkan navigasi `case 2` bottom bar ke Status Kendaraan. |
| 3 | `lib/features/detail_booking/widget/detail_booking_widget.dart` | Memungkinkan visualisasi slot parkir tanpa tiket. Menambahkan `startTime` saat menyimpan reservasi sukses, serta menambahkan navigasi `case 2` bottom bar. |
| 4 | `lib/features/history/widget/history_widget.dart` | Menambahkan navigasi `case 2` bottom bar untuk ke Status Kendaraan. |
| 5 | `lib/features/profil/widget/profil_widget.dart` | Menambahkan navigasi `case 2` bottom bar untuk ke Status Kendaraan. |
| 6 | `lib/features/home/widget/home_widget.dart` | Menghapus validasi tiket saat membuka gedung/mencari area. Menambahkan navigasi `case 2` bottom bar. |
| 7 | `lib/features/home/page/status_kendaraan_page.dart` | Menulis ulang seluruh halaman agar terintegrasi dengan API (memperoleh data kendaraan dari profil, reservasi/tiket aktif, dan durasi parkir berjalan yang ter-update tiap detik menggunakan `Timer.periodic`). |
| 8 | `lib/features/welcome_scan/widget/welcome_scan_widget.dart` | Menambahkan pengecekan platform `kIsWeb` untuk mem-bypass inisialisasi kamera dan otomatis menampilkan layout manual code input pada PWA/Web. |
| 9 | `test/widget_test.dart` | Memperbaiki unit test bawaan agar memeriksa keberadaan `SplashScreenWidget` secara benar alih-alih mencari teks statis yang tidak ada. |

---

## 3. Titik Akhir API yang Digunakan (API Endpoints)

| Method | Endpoint | Penggunaan |
|--------|----------|------------|
| `GET` | `/areas` | Memperoleh daftar gedung parkir untuk beranda & halaman pencarian secara publik |
| `GET` | `/areas/{id}/slots` | Memperoleh tata letak peta slot parkir per lantai secara publik |
| `GET` | `/users/profile` | Membaca profil pengguna nyata untuk melacak userId & foto profil |
| `GET` | `/users/vehicles` | Mengambil data kendaraan aktif pengguna (nomor plat nomor asli & tipe kendaraan) |
| `POST` | `/reservations` | Membuat pemesanan slot parkir baru (memerlukan tiket aktif) |
| `POST` | `/access/verify` | Memverifikasi tiket melalui pemindaian QR Code (mengirim payload `qrCode` real) |
| `GET` | `/access/activeTicket` | Memeriksa tiket aktif yang saat ini dimiliki pengguna dari backend |

---

## 4. Perbandingan Sebelum vs Sesudah (Before vs After)

### Alur Melihat Slot & Gedung
* **Sebelum**: Klik gedung parkir langsung memunculkan "No Ticket" dialog dan user dipaksa masuk ke scan barcode.
* **Sesudah**: Gedung, lantai, dan slot dapat dilihat serta dicari secara bebas oleh tamu maupun pengguna terdaftar. Validasi tiket hanya dilakukan saat pengguna menekan tombol **"Book Slot"**.

### Halaman Status Kendaraan
* **Sebelum**: Kosong tanpa data, menu bar tengah tidak merespon/macet.
* **Sesudah**:
  - Menampilkan nama kendaraan dinamis dari data user profil / reservasi (tidak ada mock statis "McLaren Senna").
  - Menampilkan nomor plat asli dan lokasi slot secara dinamis.
  - Durasi parkir dihitung secara live berdasarkan `startTime` reservasi dan diperbarui setiap detik.
  - Tombol **"Keluar Parkir"** berfungsi dinamis memanggil pembatalan/checkout tiket ke backend API.

---

## 5. Hasil Pengujian & Kompilasi (Testing & Compilation)

### A. Analisis Statis & Pengujian Unit
* **Flutter Analyze**: 0 Error Fatal.
* **Flutter Test**: Sukses meloloskan pengujian widget inisialisasi aplikasi.
  ```bash
  ✓ All tests passed!
  ```

### B. Hasil Kompilasi PWA
* Kompilasi web release berhasil tanpa kendala:
  ```bash
  ✓ Built build/web
  ```

### C. Server Pengembangan (Dev Run)
* Server dev web aktif melayani di port `8080` (`http://0.0.0.0:8080`) untuk pratinjau lokal yang responsif.
