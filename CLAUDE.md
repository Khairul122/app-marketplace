# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository layout

This is a multi-project repo (not a git repo) with one backend and two Flutter apps sharing it:

- `Backend_Ootday_Laravel/` — Laravel 13 REST API (Sanctum token auth) + a Livewire web admin panel. This is the single source of truth for all data; both mobile apps and the admin panel talk to it exclusively over HTTP.
- `ootday_owner/` — Flutter app for store owners ("penjual").
- `ootday_pelanggan/` — Flutter app for customers ("pembeli").
- `database/` — **Legacy, unused.** `schema.sql`/`migration_owner_uid.sql`/seeder SQL files describe an old MySQL-direct schema (Firebase-UID-keyed `users.uid`) that predates the Laravel migration. Do not treat this as authoritative — the real schema lives in `Backend_Ootday_Laravel/database/migrations/`.

There are three roles across the system: `admin` (web panel only), `owner` (Flutter app), `pelanggan` (Flutter app). All three are rows in the same `users` table (`role` enum column), not separate models.

## Backend — Backend_Ootday_Laravel

### Commands
```bash
composer install
php artisan migrate            # add --force outside interactive shells
php artisan db:seed            # seeds payment/shipping methods + one admin user
composer run dev               # serve + queue:listen + pail + vite, all at once
php artisan serve              # API/web only, http://127.0.0.1:8000
npm run dev / npm run build    # Vite (Tailwind v4) for the admin panel only — mobile apps don't use this
composer test                  # or: php artisan test
php artisan test --filter=SomeTestName
```
Tests run against in-memory SQLite (`phpunit.xml`), not the dev MySQL database, so `php artisan test` is safe to run anytime. There are currently no feature tests beyond the framework-default `ExampleTest` files — no test coverage exists for the custom API/admin code.

Dev database is MySQL (`DB_DATABASE=ootday_laravel` in `.env`, must be running locally e.g. via Laragon/FlyEnv before `migrate`/`serve` will work).

### Architecture
- **Auth**: `AuthController` (`app/Http/Controllers/Api/AuthController.php`) issues Sanctum bearer tokens for `POST /api/register` / `POST /api/login`. Mobile apps use `Authorization: Bearer <token>`; the admin panel uses a separate session-based `web` guard (see below). Both guards resolve to the same `App\Models\User`.
- **API routes** (`routes/api.php`): public routes (register/login, product/category/store catalog, payment/shipping methods) sit outside `auth:sanctum`. Everything else is under `Route::middleware('auth:sanctum')`, further split into `role:pelanggan` and `role:owner` groups via `App\Http\Middleware\EnsureRole` (generic — reads `$request->user()->role`, works for any guard). Owner-scoped endpoints (`/my-store`, `/my-products`, `/my-orders`, etc.) always derive the store from `$request->user()->store`, never trust a client-supplied `store_id`.
- **Admin web panel** (`routes/web.php`, `app/Livewire/Admin/*`): Blade + Livewire 4 **class-based** components (generated with `php artisan make:livewire Name --class` — plain `make:livewire` defaults to Livewire 4's newer single-file/anonymous-class style under `resources/views/components/`, which can't be referenced by `::class` for full-page routing, so always pass `--class` when adding new admin pages). Full-page components are registered directly in `routes/web.php` as `Route::get($uri, SomeComponent::class)`. Layout is `resources/views/admin/layout.blade.php` via `#[Layout('admin.layout')]` on each component. Auth is a separate `Auth::attempt` flow in `app/Http/Controllers/Admin/AuthController.php` restricted to `role === 'admin'`.
  - Gotcha already fixed once: don't let `/` unconditionally redirect to the login route — Laravel's `guest` middleware sends already-authenticated users back to `/` when no `dashboard`/`home` named route exists, creating an infinite redirect loop. `bootstrap/app.php` sets `$middleware->redirectUsersTo(fn () => route('admin.dashboard'))` to prevent this; keep that in mind if auth routing changes.
- **Domain model** (`app/Models/`): `Store` 1:1 `User` (via `owner_id`, one store per owner). `Product` → `ProductImage` (ordered, one `is_primary`) + `ProductVariant` (unique on `product_id,size,color`; `effectivePrice()` = variant price or `product.price + price_adjustment`). `Order` has a fixed status lifecycle in `Order::STATUSES` (`menunggu_pembayaran, diproses, dikirim, selesai, dibatalkan`) — always reuse that constant rather than hardcoding the list. `OrderItem` snapshots product/variant name+price+image at order time (FKs are nullable/nullOnDelete). Chat is `ChatThread` (unique per `customer_id,store_id`) + `ChatMessage`; notifications are `AppNotification` (table `notifications_app`). Payment/shipping methods are simple global lookup tables, not per-store.
- **File uploads**: `FILESYSTEM_DISK=public`; product/store images are stored via `Storage::disk('public')->put(...)` and served from `/storage/...` (requires `php artisan storage:link`, already done once — re-run if `public/storage` is ever missing after a fresh clone).
- **Checkout** (`OrderController::store`): takes `cart_item_ids` (not raw product data), computes totals from the referenced `CartItem`→`ProductVariant`→`Product` chain inside a DB transaction, snapshots into `OrderItem`, deletes the consumed cart items, and increments `Product.sold_count`. Any change to pricing/cart logic should go through this method, not be duplicated elsewhere.
- **Deliberately out of scope** (confirmed with the project owner, not oversights): no push notifications (FCM was removed during the Firebase migration), chat/notifications are polled via REST rather than real-time (no broadcasting configured — `BROADCAST_CONNECTION=log`), no password-reset-via-email flow exists yet (mobile "lupa password" screens just show a static "contact admin" message), no automated tests for custom code.

## Mobile apps — ootday_owner / ootday_pelanggan

Both are plain Flutter (`sdk: ^3.6.1`), state via `setState`/`ChangeNotifier` only — **no Provider/Riverpod/Bloc**, don't introduce one. Both were migrated off Firebase + a legacy PHP/MySQL backend onto the Laravel API above; do not reintroduce `firebase_*`, `cloud_firestore`, `mysql1`, or calls to the old `http://192.168.1.77/Backend_Ootday/*.php` endpoints.

### Commands (run inside each app's directory)
```bash
flutter pub get
flutter analyze
flutter run
flutter test
```

### Shared architecture (per app, in `lib/services/`)
- `token_store.dart` — `flutter_secure_storage` wrapper holding the Sanctum bearer token + cached user JSON.
- `api_service.dart` — thin HTTP client; base URL is `http://10.0.2.2:8000/api` (Android emulator → host loopback — change to the LAN IP for a physical device or `127.0.0.1` for iOS simulator). Injects `Authorization: Bearer` automatically from `TokenStore`, throws `ApiException` (with `.message`/`.errors`) on non-2xx so callers can show `AuthException`/API error text directly.
- `auth_service.dart` — wraps register/login/logout/me/updateProfile/changePassword/deleteAccount; exposes `AuthState.instance` (a `ChangeNotifier` singleton) as the app-wide "am I logged in / who am I" source, checked at startup in `main.dart` via `AuthService().restoreSession()` (calls `GET /me` to validate the stored token) before deciding between the logged-in home screen and the welcome/login screen.
- Multipart uploads (owner app product/store photos) go through `ApiService().multipart(...)`, encoding array fields Laravel-style (`images[0]`, `variants[0][size]`, etc.).

`ootday_owner` is the store-management app (products, categories, orders-for-my-store, dashboard stats, chat, own-store settings). `ootday_pelanggan` is the shopping app (browse, cart, checkout, addresses, my-orders, chat) — its cart/checkout is variant-based (`variant_id`, not bare `product_id`), and checkout requires picking payment/shipping methods by numeric `id` fetched from `/payment-methods` and `/shipping-methods`.
