# Progres Project Ootday Marketplace

Terakhir diperbarui: 2026-07-19

Repo: https://github.com/Khairul122/app-marketplace (branch `main`)

## Ringkasan Arsitektur

- **Backend_Ootday_Laravel** — satu-satunya sumber data. REST API (Sanctum token) untuk 2 app mobile + web admin panel (Livewire, session auth) untuk role `admin`.
- **ootday_owner** (Flutter) — app penjual/owner.
- **ootday_pelanggan** (Flutter) — app pembeli/pelanggan.
- **database/** — skema legacy MySQL-langsung, **sudah tidak dipakai**, hanya arsip.
- 3 role dalam 1 tabel `users` (`role` enum: `pelanggan`, `owner`, `admin`), bukan model terpisah.

## Yang Sudah Selesai

### 1. Migrasi Firebase → Laravel REST API
- Audit awal menemukan 3 backend paralel yang tidak nyambung (Firebase, MySQL langsung dari mobile, endpoint PHP legacy yang sebagian tidak eksis).
- Backend: 10 controller API yang tadinya kosong (Product, Cart, Order, Category, Address, PaymentMethod, ShippingMethod, Chat, Notification, OwnerDashboard) sudah diimplementasikan lengkap + routing + role middleware.
- Checkout transaksional (`OrderController::store`): berbasis `cart_item_ids`, snapshot ke `order_items`, hapus cart otomatis, increment `sold_count`. Order dalam 1 toko per transaksi (tidak bisa campur toko).
- Kedua app Flutter: Firebase Auth/Firestore/Storage/Messaging, `mysql1`, dan endpoint PHP legacy dihapus total. Diganti layer service baru: `token_store.dart` (Sanctum token via `flutter_secure_storage`), `api_service.dart` (HTTP client + error handling), `auth_service.dart` (`AuthState` sebagai state login global).
- Config native Android (plugin `google-services`/`crashlytics`, `google-services.json`) dibersihkan dari kedua app. Bug `applicationId` pelanggan yang salah copy-paste ke `com.example.ootday_owner` diperbaiki.
- Diverifikasi end-to-end lewat curl: register → login → kategori → produk+gambar → cart → checkout → update status → notifikasi otomatis → dashboard → chat.

### 2. Web Admin Panel (Livewire)
- Role `admin` ditambahkan ke enum `users.role` (migrasi terpisah, tidak mengubah data existing).
- Auth web session-based terpisah dari Sanctum API (`app/Http/Controllers/Admin/AuthController.php`), akun admin pertama dari seeder (`admin@ootday.com` / `admin12345` — **belum ada fitur ganti password dari UI, sarankan ganti manual**).
- 7 halaman CRUD: Dashboard (statistik), Users, Stores, Categories, Products, Orders, Payment Methods, Shipping Methods — semua Livewire class-based component (`app/Livewire/Admin/*`, penting: generate baru harus pakai `--class` karena default Livewire 4 beda struktur).
- Tambah/Edit/Hapus/Lihat lengkap di hampir semua entity. Orders sengaja tanpa "Tambah" manual (order harus lewat alur checkout asli).
- Upload gambar produk (multi-file + preview) ditambahkan ke form Tambah/Edit Produk di panel admin.
- Redesign visual: tema rose/pink cerah, gradient, modal glassmorphism, animasi entrance, loading state di semua tombol Simpan, empty-state berikon, `tabular-nums` untuk angka, alt text gambar, favicon.
- Bug redirect-loop di `/` vs middleware `guest` sudah diperbaiki (`trustProxies` + `redirectUsersTo` di `bootstrap/app.php`).

### 3. Deploy & Infrastruktur
- Repo GitHub `Khairul122/app-marketplace` (public) — monorepo (backend + 2 app + database legacy). `.gitignore` dirapikan (ephemeral Flutter, `.gradle`, `.env`, dll — sudah diverifikasi tidak ada secret yang ikut ter-push).
- Testing lewat tunnel **localtonet** (`https://xbncmdd6jn.localto.net`) → **port harus 8000**, bukan 80 (port 80 dipakai nginx FlyEnv untuk project lain).
- Bug mixed-content HTTPS diperbaiki (`trustProxies(at: '*')` di `bootstrap/app.php`) — sebelumnya asset CSS/JS ter-generate `http://` di halaman `https://` sehingga browser blokir semua style.
- Base URL kedua app Flutter (`lib/services/api_service.dart`) saat ini di-set ke tunnel localtonet (**subdomain gratis berubah tiap restart tunnel** — update manual kalau berubah).

## Belum Dikerjakan / Diketahui Sebagai Gap

- **Push notification** (FCM) sengaja dihapus saat migrasi, belum ada penggantinya.
- **Chat & notifikasi real-time** (WebSocket/Laravel Reverb) — baru sebatas dibahas, belum diimplementasikan. Masih polling REST biasa.
- **Label "Dijual oleh [toko]"** belum ada di kartu/detail produk app pelanggan (produk dari semua penjual tercampur tanpa identitas toko saat browsing).
- **Reset password via email** belum ada (layar "Lupa Password" di kedua app cuma pesan statis "hubungi admin").
- **Tidak ada test otomatis** untuk kode custom (API, admin panel) — cuma `ExampleTest` bawaan Laravel.
- Ganti password admin dari UI panel belum ada (harus lewat DB langsung/tinker kalau perlu).

## Catatan Teknis Penting

- Jalankan `php artisan serve` **satu instance saja** — sempat ada belasan proses menumpuk dari sesi dev sebelumnya karena `pkill` di bash tidak selalu mematikan proses Windows di baliknya. Cek dengan PowerShell `Get-CimInstance Win32_Process -Filter "Name='php.exe'"` kalau ada gejala aneh (port bentrok, respons tidak konsisten).
- Dev database: MySQL `ootday_laravel`, harus jalan (Laragon/FlyEnv) sebelum `migrate`/`serve`.
- Detail arsitektur & command lengkap ada di `CLAUDE.md` (root project).
