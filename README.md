# 📱 Kasir Warung Makan - Aplikasi Flutter

Aplikasi kasir lengkap untuk warung makan dengan fitur:
- ✅ Kasir & transaksi penjualan
- ✅ Stok/inventaris bahan
- ✅ Laporan keuangan
- ✅ Hutang & piutang

---

## 🚀 CARA COMPILE JADI APK (Gratis via GitHub + Codemagic)

### LANGKAH 1 — Upload ke GitHub
1. Buat akun di https://github.com (gratis)
2. Buat repository baru, nama: `kasir-warung`
3. Upload semua folder & file ini ke repository tersebut

### LANGKAH 2 — Compile di Codemagic
1. Buka https://codemagic.io
2. Daftar gratis pakai akun GitHub kamu
3. Klik **"Add application"**
4. Pilih repository `kasir-warung`
5. Pilih **Flutter App**
6. Di bagian **Build**, pilih:
   - Platform: **Android**
   - Mode: **Debug** (gratis, untuk testing)
7. Klik **"Start new build"**
8. Tunggu ± 5–10 menit
9. Download file **APK** yang sudah jadi!

### LANGKAH 3 — Install di HP Android
1. Kirim file APK ke HP lewat WhatsApp atau Google Drive
2. Buka file APK di HP
3. Kalau muncul peringatan "Install dari sumber tidak dikenal":
   - Pergi ke Pengaturan → Keamanan → Aktifkan "Sumber tidak dikenal"
4. Klik Install → selesai! ✅

---

## 📁 Struktur Folder

```
kasir_warung/
├── lib/
│   ├── main.dart                  ← Entry point aplikasi
│   ├── models/
│   │   ├── models.dart            ← Data models
│   │   └── app_data.dart          ← Penyimpanan data lokal
│   └── screens/
│       ├── kasir_screen.dart      ← Halaman kasir/POS
│       ├── stok_screen.dart       ← Halaman stok bahan
│       ├── laporan_screen.dart    ← Halaman laporan keuangan
│       ├── hutang_screen.dart     ← Halaman hutang & piutang
│       └── menu_screen.dart       ← Halaman kelola menu
└── pubspec.yaml                   ← Konfigurasi & dependencies
```

---

## 💡 Fitur Aplikasi

### 🧾 Kasir
- Tampilkan menu dalam grid
- Filter berdasarkan kategori (Makanan, Minuman, dll)
- Keranjang belanja dengan +/- quantity
- Proses pembayaran tunai & transfer
- Hitung kembalian otomatis

### 📦 Stok
- Daftar bahan dengan jumlah & satuan
- Status: Aman / Menipis / Habis
- Peringatan bahan yang hampir habis
- Tambah, edit, hapus stok

### 📊 Laporan
- Filter: Hari ini / Minggu ini / Bulan ini / Semua
- Total pendapatan & jumlah transaksi
- Menu terlaris dengan progress bar
- Riwayat transaksi detail

### 💸 Hutang & Piutang
- Catat hutang (kita berhutang) & piutang (orang berhutang ke kita)
- Total hutang & piutang
- Tandai lunas
- Filter berdasarkan tipe

### 🍜 Kelola Menu
- Tambah/edit/hapus item menu
- Atur harga & kategori
- Tampil per kategori
