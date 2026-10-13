# ANALISIS FUNCTION POINT APLIKASI PARKFINDER (MOBILE ANDROID & PROGRESSIVE WEB APP)

## 1. Tujuan Analisis

Analisis Function Point (FP) dilakukan untuk mengukur ukuran fungsional perangkat lunak berdasarkan fungsi yang benar-benar disediakan kepada pengguna, bukan berdasarkan jumlah file, halaman, komponen, ataupun baris kode. Pengukuran dilaksanakan pada aplikasi frontend Mobile Android dan Progressive Web App (PWA) ParkFinder yang dikembangkan dengan framework Flutter.

Hasil analisis disusun untuk memperoleh nilai *Unadjusted Function Point* (UFP) dari lima kategori fungsi, yaitu *External Input* (EI), *External Output* (EO), *External Query* (EQ), *Logical Internal File* (ILF), dan *External Interface File* (EIF). Nilai UFP selanjutnya dikalibrasi dengan *General Characteristics Adjustment* (GCA) yang diturunkan dari empat belas *Degree of Influence* (DOI) untuk memperoleh nilai Function Point akhir. Nilai tersebut digunakan sebagai salah satu dasar pembahasan estimasi ukuran proyek pada metode *Rapid Application Development* (RAD). Seluruh angka pada laporan ini berasal dari audit source code pada direktori `lib/` serta berkas pendukung `web/` dan `pubspec.yaml`, dan dapat ditelusuri kembali.

## 2. Ruang Lingkup dan Batas Aplikasi

Batas aplikasi (boundary) ditentukan berdasarkan fungsi yang dirasakan pengguna, bukan berdasarkan struktur folder repository. ParkFinder Mobile/PWA merupakan *thin client* yang menyajikan antarmuka interaktif kepada pengguna terdaftar (role `user`) dan berkomunikasi dengan backend melalui REST API. Seluruh data bisnis (pengguna, area parkir, slot, tiket, reservasi) dikelola oleh sistem eksternal di luar boundary; frontend tidak memiliki basis data bisnis sendiri.

Aktor yang berinteraksi dengan aplikasi adalah Pengguna Terdaftar (pengemudi/mahasiswa) yang menggunakan tiket parkir masuk dan melakukan reservasi slot. Aplikasi berinteraksi dengan tiga sistem eksternal: (1) backend REST API pada Cloud Run, (2) Google Cloud Storage untuk aset gambar, dan (3) layanan pembangkit QR eksternal untuk penampilan kode QR tiket. Data yang berada di dalam boundary hanya data sesi teknis (token autentikasi, tiket aktif, reservasi aktif, dan preferensi tampilan) yang disimpan pada penyimpanan lokal perangkat; data ini berperan sebagai *cache* teknis, bukan sebagai kelompok data bisnis yang dikelola pengguna.

| No | Elemen | Keterangan |
|---|---|---|
| 1 | Nama aplikasi | ParkFinder — Frontend Mobile Android & PWA (Flutter) |
| 2 | Aktor | Pengguna terdaftar (pengemudi parkir), role `user` |
| 3 | Boundary aplikasi | Seluruh fungsi antarmuka dan alur transaksi yang disediakan kepada pengguna di dalam aplikasi Mobile/PWA |
| 4 | Sistem eksternal | Backend REST API (Cloud Run); Google Cloud Storage (aset gambar); layanan pembangkit QR (api.qrserver.com) |
| 5 | Sumber data eksternal | Data pengguna, area, slot, tiket, dan reservasi yang dikelola backend melalui REST API; seluruhnya berada di luar boundary |

## 3. Identifikasi Fungsi Fungsional

Identifikasi dilakukan melalui penelusuran service layer, provider, halaman, dan widget pada source code. Endpoint REST API hanya digunakan sebagai bukti pendukung bahwa suatu fungsi diimplementasikan dan tidak dihitung sebagai Function Point tersendiri. Fungsi yang sama pada platform Android dan PWA tidak dihitung dua kali karena keduanya menggunakan satu basis kode Flutter yang sama dan menyediakan fungsi bisnis yang identik.

Fungsi yang teridentifikasi dikelompokkan sebagai berikut.

**Kelompok External Input (EI):**

| No | Nama Fungsi | Deskripsi Fungsi | Aktor/Sumber | Jenis Fungsi |
|---|---|---|---|---|
| 1 | Login | Autentikasi pengguna dengan email dan kata sandi; validasi role pengguna; penyimpanan token | Pengguna | EI |
| 2 | Registrasi Akun | Pembuatan akun baru (nama, email, telepon, kata sandi, plat nomor, tipe kendaraan) | Pengguna | EI |
| 3 | Pemindaian & Verifikasi Tiket | Aktivasi tiket parkir masuk melalui pemindaian QR (kamera) atau masukan kode manual | Pengguna | EI |
| 4 | Reservasi Slot Parkir | Pembuatan reservasi slot parkir pada area terpilih | Pengguna | EI |
| 5 | Konfirmasi Kedatangan (Check-in) | Konfirmasi kedatangan pengguna di slot parkir | Pengguna | EI |
| 6 | Penyelesaian Sesi Parkir (Check-out) | Penyelesaian/penutupan sesi parkir aktif | Pengguna | EI |
| 7 | Pembatalan Reservasi | Pembatalan reservasi slot yang masih berstatus menunggu | Pengguna | EI |
| 8 | Pembatalan Tiket | Pembatalan tiket parkir aktif | Pengguna | EI |
| 9 | Pindah/Ganti Slot (Swap) | Perpindahan reservasi ke slot lain yang tersedia | Pengguna | EI |
| 10 | Logout | Pengakhiran sesi pengguna dan pembersihan data lokal | Pengguna | EI |
| 11 | Pembaruan Profil | Perubahan nama dan nomor telepon pengguna | Pengguna | EI |
| 12 | Unggah Foto Profil | Pengunggahan gambar profil pengguna | Pengguna | EI |
| 13 | Penambahan Kendaraan | Pendaftaran plat nomor kendaraan mobil baru | Pengguna | EI |
| 14 | Penghapusan Kendaraan | Penghapusan kendaraan terdaftar berdasarkan plat nomor | Pengguna | EI |

**Kelompok External Output (EO):**

| No | Nama Fungsi | Deskripsi Fungsi | Aktor/Sumber | Jenis Fungsi |
|---|---|---|---|---|
| 15 | Penampilan QR Tiket Masuk | Pembangkitan representasi QR dari kode tiket aktif untuk ditampilkan kepada pengguna | Pengguna | EO |

**Kelompok External Query (EQ):**

| No | Nama Fungsi | Deskripsi Fungsi | Aktor/Sumber | Jenis Fungsi |
|---|---|---|---|---|
| 16 | Melihat Daftar Area Parkir | Penampilan daftar area parkir beserta ketersediaan slot | Pengguna | EQ |
| 17 | Melihat Denah Slot per Area | Penampilan denah slot beserta status ketersediaan pada suatu area | Pengguna | EQ |
| 18 | Melihat Status Parkir Aktif | Penampilan tiket aktif, reservasi aktif, dan durasi parkir berjalan | Pengguna | EQ |
| 19 | Melihat Riwayat Parkir | Penampilan daftar riwayat reservasi parkir beserta status dan waktu | Pengguna | EQ |
| 20 | Melihat Profil Pengguna | Penampilan data diri pengguna (nama, email, telepon, foto) | Pengguna | EQ |
| 21 | Melihat Daftar Kendaraan | Penampilan daftar kendaraan mobil terdaftar | Pengguna | EQ |
| 22 | Melihat Notifikasi | Penampilan notifikasi aktivitas tiket dan reservasi | Pengguna | EQ |

**Kelompok Internal Logical File (ILF):** tidak ada (0).

**Kelompok External Interface File (EIF):** tidak ada (0).

Halaman onboarding, panduan penggunaan (floating tutorial), halaman splash, dan halaman pengaturan (tema serta preferensi notifikasi) tidak dihitung sebagai fungsi karena tidak melakukan transaksi data dan tidak mengubah kondisi data bisnis; pengaturan tema disimpan secara lokal sebagai preferensi perangkat (mekanisme teknis).

## 4. Penentuan Kompleksitas Fungsi

Kompleksitas ditentukan melalui matriks kompleksitas standar metode Function Point (Albrecht/IFPUG) berdasarkan dua parameter, yaitu banyaknya elemen data (DET) yang diproses dan banyaknya file yang direferensikan (FTR). Matriks untuk External Input, External Output, dan External Query adalah sebagai berikut.

| FTR \ DET | 1–4 | 5–15 | ≥16 |
|---|---|---|---|
| 0–1 | Low | Low (EI) / Medium (EO–EQ) | Medium (EI) / High (EO–EQ) |
| 2 | Low | Medium | High |
| ≥3 | Medium | High | High |

Karena frontend tidak memiliki internal logical file dan external interface file (FTR = 0), kompleksitas ditentukan semata oleh jumlah DET. Dengan demikian, untuk EI berlaku Low pada DET 1–15 dan Medium pada DET ≥16, sedangkan untuk EO/EQ berlaku Low pada DET 1–4, Medium pada DET 5–15, dan High pada DET ≥16.

| No | Fungsi | Jenis FP | Kompleksitas | Alasan Penentuan |
|---|---|---|---|---|
| 1 | Login | EI | Low | 2 elemen data diproses (email, kata sandi) |
| 2 | Registrasi Akun | EI | Low | 6 elemen data diproses; FTR = 0 sehingga masuk rentang Low (1–15 DET) |
| 3 | Pemindaian & Verifikasi Tiket | EI | Low | 1 elemen data diproses (kode QR) |
| 4 | Reservasi Slot Parkir | EI | Low | 4 elemen data diproses (slotId, ticketId, nama, plat nomor) |
| 5 | Konfirmasi Kedatangan | EI | Low | 1 elemen data diproses (reservationId) |
| 6 | Penyelesaian Sesi Parkir | EI | Low | 1 elemen data diproses (reservationId) |
| 7 | Pembatalan Reservasi | EI | Low | 1 elemen data diproses (reservationId) |
| 8 | Pembatalan Tiket | EI | Low | 1 elemen data diproses (ticketId) |
| 9 | Pindah/Ganti Slot | EI | Low | 2 elemen data diproses (reservationId, newSlotId) |
| 10 | Logout | EI | Low | Tanpa payload data; pengakhiran sesi |
| 11 | Pembaruan Profil | EI | Low | 2 elemen data diproses (nama, nomor telepon) |
| 12 | Unggah Foto Profil | EI | Low | 2 elemen data diproses (berkas gambar, nama berkas) |
| 13 | Penambahan Kendaraan | EI | Low | 2 elemen data diproses (plat nomor, tipe kendaraan) |
| 14 | Penghapusan Kendaraan | EI | Low | 1 elemen data diproses (plat nomor) |
| 15 | Penampilan QR Tiket Masuk | EO | Low | 1 elemen data diolah menjadi representasi QR (kode tiket) |
| 16 | Melihat Daftar Area Parkir | EQ | Medium | 5 elemen data per rekaman (id, nama, alamat, total slot, slot tersedia) |
| 17 | Melihat Denah Slot per Area | EQ | Low | 4 elemen data per rekaman (id, nomor slot, status, tipe kendaraan) |
| 18 | Melihat Status Parkir Aktif | EQ | Medium | Gabungan data tiket aktif dan reservasi aktif (±14 elemen data) |
| 19 | Melihat Riwayat Parkir | EQ | Medium | ±13 elemen data per rekaman reservasi termasuk timestamp |
| 20 | Melihat Profil Pengguna | EQ | Medium | 6 elemen data (userId, nama, email, telepon, foto, role) |
| 21 | Melihat Daftar Kendaraan | EQ | Low | 2 elemen data per rekaman (plat nomor, tipe kendaraan) |
| 22 | Melihat Notifikasi | EQ | Medium | Gabungan data notifikasi lokal, tiket aktif, dan riwayat reservasi |

## 5. Perhitungan Unadjusted Function Point

Bobot yang digunakan sesuai ketentuan analisis: EI Low=3, Medium=4, High=6; EO Low=4, Medium=5, High=7; EQ Low=3, Medium=4, High=6; ILF Low=7, Medium=10, High=15; EIF Low=5, Medium=7, High=10.

| No | Fungsi | Jenis | Kompleksitas | Bobot | FP |
|---|---|---|---|---|---:|
| 1 | Login | EI | Low | 3 | 3 |
| 2 | Registrasi Akun | EI | Low | 3 | 3 |
| 3 | Pemindaian & Verifikasi Tiket | EI | Low | 3 | 3 |
| 4 | Reservasi Slot Parkir | EI | Low | 3 | 3 |
| 5 | Konfirmasi Kedatangan | EI | Low | 3 | 3 |
| 6 | Penyelesaian Sesi Parkir | EI | Low | 3 | 3 |
| 7 | Pembatalan Reservasi | EI | Low | 3 | 3 |
| 8 | Pembatalan Tiket | EI | Low | 3 | 3 |
| 9 | Pindah/Ganti Slot | EI | Low | 3 | 3 |
| 10 | Logout | EI | Low | 3 | 3 |
| 11 | Pembaruan Profil | EI | Low | 3 | 3 |
| 12 | Unggah Foto Profil | EI | Low | 3 | 3 |
| 13 | Penambahan Kendaraan | EI | Low | 3 | 3 |
| 14 | Penghapusan Kendaraan | EI | Low | 3 | 3 |
| 15 | Penampilan QR Tiket Masuk | EO | Low | 4 | 4 |
| 16 | Melihat Daftar Area Parkir | EQ | Medium | 4 | 4 |
| 17 | Melihat Denah Slot per Area | EQ | Low | 3 | 3 |
| 18 | Melihat Status Parkir Aktif | EQ | Medium | 4 | 4 |
| 19 | Melihat Riwayat Parkir | EQ | Medium | 4 | 4 |
| 20 | Melihat Profil Pengguna | EQ | Medium | 4 | 4 |
| 21 | Melihat Daftar Kendaraan | EQ | Low | 3 | 3 |
| 22 | Melihat Notifikasi | EQ | Medium | 4 | 4 |

Rekapitulasi per kategori:

| Jenis Fungsi | Low | Medium | High | Total |
|---|---|---:|---:|---:|
| EI | 14 | 0 | 0 | 14 |
| EO | 1 | 0 | 0 | 1 |
| EQ | 2 | 5 | 0 | 7 |
| ILF | 0 | 0 | 0 | 0 |
| EIF | 0 | 0 | 0 | 0 |
| **Total** | **17** | **5** | **0** | **22** |

Perhitungan UFP dilakukan secara eksplisit:

```
UFP = (EI Low × 3) + (EI Medium × 4) + (EI High × 6)
    + (EO Low × 4) + (EO Medium × 5) + (EO High × 7)
    + (EQ Low × 3) + (EQ Medium × 4) + (EQ High × 6)
    + (ILF Low × 7) + (ILF Medium × 10) + (ILF High × 15)
    + (EIF Low × 5) + (EIF Medium × 7) + (EIF High × 10)

UFP = (14 × 3) + (0 × 4) + (0 × 6)
    + (1 × 4) + (0 × 5) + (0 × 7)
    + (2 × 3) + (5 × 4) + (0 × 6)
    + (0 × 7) + (0 × 10) + (0 × 15)
    + (0 × 5) + (0 × 7) + (0 × 10)

UFP = 42 + 0 + 0 + 4 + 0 + 0 + 6 + 20 + 0 + 0 + 0 + 0 + 0 + 0 + 0

UFP = 72
```

Nilai UFP tidak dibulatkan dan sebesar **72**.

## 6. Penilaian Degree of Influence

Penilaian empat belas faktor *General System Characteristics* menggunakan skala 0–5 dengan dasar penilaian dari implementasi aktual. Rekapitulasi nilai tiap faktor ditampilkan pada Tabel berikut.

| No | General System Characteristic | Nilai |
|---|---|---:|
| 1 | Data Communications | 2 |
| 2 | Distributed Functions | 3 |
| 3 | Performance | 2 |
| 4 | Heavily Used Configuration | 1 |
| 5 | Transaction Rate | 1 |
| 6 | On-Line Data Entry | 4 |
| 7 | End-User Efficiency | 4 |
| 8 | On-Line Updating | 4 |
| 9 | Complex Processing | 1 |
| 10 | Reusability | 2 |
| 11 | Installation Ease | 2 |
| 12 | Operational Ease | 3 |
| 13 | Multiple Sites | 2 |
| 14 | Facilitate Change | 3 |
| | **Total** | **34** |

Dasar penilaian setiap faktor diuraikan sebagai berikut.

1. **Data Communications (nilai 2).** Seluruh transaksi berjalan secara online melalui REST API berbasis HTTP/HTTPS menuju backend Cloud Run.
2. **Distributed Functions (nilai 3).** Pemrosesan terdistribusi antara client (presentasi dan state lokal) dan server (logika bisnis), serta penggunaan penyimpanan aset GCS dan layanan QR eksternal.
3. **Performance (nilai 2).** Terdapat indikator pemuatan dan pemantauan durasi berjalan, namun tanpa target kinerja ketat yang terukur.
4. **Heavily Used Configuration (nilai 1).** Aplikasi berjalan pada perangkat bergerak standar tanpa konfigurasi perangkat keras khusus.
5. **Transaction Rate (nilai 1).** Frekuensi transaksi per pengguna relatif rendah (reservasi personal, bukan sistem transaksi volume tinggi).
6. **On-Line Data Entry (nilai 4).** Hampir seluruh masukan data (login, registrasi, reservasi, profil, kendaraan) dilakukan interaktif secara online.
7. **End-User Efficiency (nilai 4).** Desain berorientasi seluler: denah interaktif, pencarian area, tombol aksi cepat, tutorial, dan umpan balik pemuatan.
8. **On-Line Updating (nilai 4).** Pembaruan data reservasi, profil, dan kendaraan dilakukan secara online melalui API.
9. **Complex Processing (nilai 1).** Pemrosesan kompleks pada frontend terbatas pada penghitungan persentase ketersediaan dan durasi.
10. **Reusability (nilai 2).** Terdapat pustaka widget bersama dan service layer terpusat yang dirancang untuk digunakan ulang.
11. **Installation Ease (nilai 2).** Instalasi melalui platform standar serta konversi PWA dengan service worker; tidak ada prosedur instalasi khusus.
12. **Operational Ease (nilai 3).** Menyediakan penanganan galat, state kosong, dan mekanisme muat ulang yang memudahkan operasional.
13. **Multiple Sites (nilai 2).** Aplikasi melayani beberapa area/gedung parkir pada satu lingkungan kampus.
14. **Facilitate Change (nilai 3).** Arsitektur berbasis fitur, konfigurasi terpusat (AppConfig), dan tema terpusat memudahkan pemeliharaan dan perubahan.

## 7. Perhitungan General Characteristics Adjustment

GCA dihitung menggunakan rumus:

```
GCA = 0,65 + (0,01 × TDI)
```

Substitusi angka:

```
GCA = 0,65 + (0,01 × 34)
GCA = 0,65 + 0,34
GCA = 0,99
```

## 8. Perhitungan Function Point

Function Point akhir dihitung menggunakan rumus:

```
FP = UFP × GCA
```

Substitusi angka:

```
FP = 73 × 0,99
FP = 72,27
```

Nilai Function Point yang diperoleh untuk aplikasi ParkFinder Mobile/PWA adalah sebesar **72,27 FP**. Nilai desimal dipertahankan tanpa pembulatan karena tidak terdapat alasan metodologis untuk membulatkan.

## 9. Rekapitulasi Hasil

| Komponen | Nilai |
|---|---:|
| External Input | 14 |
| External Output | 1 |
| External Query | 7 |
| Internal Logical File | 0 |
| External Interface File | 0 |
| Unadjusted Function Point | 73 |
| Total Degree of Influence | 34 |
| General Characteristics Adjustment | 0,99 |
| Function Point | 72,27 |

Hasil pengukuran menunjukkan bahwa aplikasi ParkFinder Mobile/PWA tergolong perangkat lunak berukuran fungsional kecil. Kontribusi terbesar berasal dari kategori External Input (43 FP dari total UFP 73) karena alur transaksi parkir personal mendominasi fungsi aplikasi, diikuti External Query (26 FP) untuk fungsi penelusuran dan pemantauan. Tidak terdapat Internal Logical File maupun External Interface File karena aplikasi merupakan *thin client* yang tidak mengelola kelompok data bisnis sendiri. Nilai ini menggambarkan ukuran fungsional murni frontend dan dapat digunakan sebagai pembanding ukuran proyek pada tabel referensi RAD, bukan sebagai target angka.

## 10. Validasi dan Keputusan Klasifikasi

| No | Fungsi | Permasalahan | Keputusan | Alasan |
|---|---|---|---|---|
| 1 | Halaman onboarding, splash, dan transisi selamat datang | Merupakan elemen antarmuka tanpa transaksi data | Tidak dihitung | Tidak memproses data dan tidak memenuhi karakteristik FP |
| 2 | Tutorial/panduan penggunaan (floating tutorial) | Konten statis penjelasan penggunaan | Tidak dihitung | Hanya penyajian informasi statis, bukan transaksi |
| 3 | Pengaturan aplikasi (tema dan preferensi notifikasi) | Pengaturan disimpan lokal sebagai preferensi perangkat | Tidak dihitung | Mekanisme teknis; tidak mengubah data bisnis dan tidak dihitung sebagai fungsi |
| 4 | Pemindaian QR dan masukan kode manual | Dua jalur masukan untuk satu fungsi | Dihitung satu kali (EI No. 3) | Keduanya memanggil service verifikasi yang sama (verifyTicket) untuk satu fungsi bisnis |
| 5 | Melihat Daftar Area (Home, Booking, DetailBooking) | Endpoint yang sama digunakan pada beberapa halaman | Dihitung satu kali (EQ No. 16) | Merupakan satu fungsi logis yang sama, pencegahan double counting |
| 6 | Melihat Status Parkir Aktif vs Melihat Riwayat Parkir | Berbagi endpoint riwayat reservasi | Dihitung sebagai dua EQ terpisah | Tujuan pengguna berbeda: pemantauan sesi berjalan vs penelusuran riwayat lampau |
| 7 | Navigasi menuju slot (denah dan timer 15 menit) | Hanya menampilkan gambar denah statis dan penghitung waktu | Tidak dihitung terpisah; menjadi bagian EQ No. 18 | Tidak melakukan transaksi data tersendiri; merupakan bagian penyajian status aktif |
| 8 | Melihat Profil vs Melihat Daftar Kendaraan | Kedua fungsi mengambil data dari GET /users/profile | Dihitung sebagai dua EQ terpisah | Memenuhi kebutuhan pengguna yang berbeda pada halaman berbeda; endpoint hanya bukti pendukung |
| 9 | QR Tiket Masuk vs Status Parkir Aktif | QR dihasilkan dari tiket aktif yang sama | Dihitung sebagai EO No. 15 | Penampilan QR merupakan output turunan (representasi QR) yang merupakan fungsi tersendiri yang dapat diakses pengguna |
| 10 | Endpoint REST API (18 endpoint) | Muncul sebagai banyak endpoint | Tidak dihitung sebagai FP | Endpoint hanya bukti pendukung; fungsi dihitung berdasarkan fungsi bisnis yang dirasakan pengguna |
| 11 | Penyimpanan lokal (token, tiket aktif, reservasi aktif, notifikasi) | Menyerupai penyimpanan data | Tidak dihitung sebagai ILF | Berperan sebagai cache teknis/state sesi, bukan kelompok data bisnis yang dikelola pengguna |
| 12 | Data area, slot, tiket, reservasi, pengguna | Data dikelola backend | Tidak dihitung sebagai EIF | Referensi data melalui REST API tidak serta-merta memenuhi definisi external interface file; menghindari klaim EIF tanpa bukti |
| 13 | Instalasi PWA dan pembaruan service worker | Fitur platform khusus | Tidak dihitung | Mekanisme teknis distribusi, bukan fungsi bisnis yang terlihat oleh pengguna |
| 14 | Verifikasi Tiket (klasifikasi EI/EQ) | Dapat diinterpretasikan sebagai kueri verifikasi | Dihitung sebagai EI | Pemindaian mengaktifkan tiket (perubahan status tiket menjadi aktif/claimed) sehingga mengubah kondisi data eksternal |
| 15 | Notifikasi (klasifikasi EQ/EO) | Merupakan agregasi beberapa sumber data | Dihitung sebagai EQ | Tujuan utamanya penelusuran dan penampilan, meskipun terdapat agregasi minor |

## 11. Kesimpulan

Berdasarkan audit source code, berhasil diidentifikasi **22 fungsi** yang memenuhi karakteristik Function Point, terdiri atas 14 External Input, 1 External Output, dan 7 External Query, tanpa Internal Logical File maupun External Interface File. Nilai *Unadjusted Function Point* (UFP) yang diperoleh adalah **73**. Total *Degree of Influence* bernilai **34**, sehingga *General Characteristics Adjustment* (GCA) dihitung sebesar **0,99**. Nilai Function Point akhir aplikasi ParkFinder Mobile/PWA adalah **72,27 FP**. Seluruh nilai tersebut diturunkan dari fungsi bisnis yang benar-benar diimplementasikan dan dapat diverifikasi dari source code, bukan dari jumlah halaman, endpoint, komponen, ataupun baris kode.
