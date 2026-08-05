# Aset UI ParkFinder

Setiap aset visual baru harus ditempatkan berdasarkan feature, bukan langsung di root `lib/assets`.

| Feature | Folder | Contoh penggunaan |
| --- | --- | --- |
| Auth | `lib/assets/auth/` | logo atau ilustrasi form masuk/daftar |
| Welcome | `lib/assets/welcome/` | onboarding dan splash |
| Home | `lib/assets/home/` | foto kartu area dan banner |
| Parking | `lib/assets/parking/` | peta denah, slot, dan konfirmasi |
| Profile | `lib/assets/profile/` | avatar default |
| Scan | `lib/assets/scan/` | template tiket atau overlay scan |
| Shared | `lib/assets/shared/` | aset yang dipakai lebih dari satu feature |

Placeholder SVG di tiap folder adalah template yang dapat diganti oleh desainer. Pertahankan nama berkas jika sudah direferensikan dari kode; gunakan PNG/JPG/WebP untuk foto bitmap yang akan ditampilkan Flutter tanpa dependency tambahan.
