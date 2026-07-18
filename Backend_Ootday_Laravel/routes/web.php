<?php

use App\Http\Controllers\Admin\AuthController;
use App\Livewire\Admin\Categories\Index as CategoriesIndex;
use App\Livewire\Admin\Dashboard;
use App\Livewire\Admin\Orders\Index as OrdersIndex;
use App\Livewire\Admin\PaymentMethods\Index as PaymentMethodsIndex;
use App\Livewire\Admin\Products\Index as ProductsIndex;
use App\Livewire\Admin\ShippingMethods\Index as ShippingMethodsIndex;
use App\Livewire\Admin\Stores\Index as StoresIndex;
use App\Livewire\Admin\Users\Index as UsersIndex;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    if (Auth::check() && Auth::user()->isAdmin()) {
        return redirect()->route('admin.dashboard');
    }

    return redirect()->route('login');
});

Route::middleware('guest')->group(function () {
    Route::get('/admin/login', [AuthController::class, 'showLogin'])->name('login');
    Route::post('/admin/login', [AuthController::class, 'login'])->name('admin.login.submit');
});

Route::post('/admin/logout', [AuthController::class, 'logout'])
    ->middleware('auth')
    ->name('admin.logout');

Route::middleware(['auth', 'role:admin'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/', Dashboard::class)->name('dashboard');
    Route::get('/users', UsersIndex::class)->name('users.index');
    Route::get('/stores', StoresIndex::class)->name('stores.index');
    Route::get('/categories', CategoriesIndex::class)->name('categories.index');
    Route::get('/products', ProductsIndex::class)->name('products.index');
    Route::get('/orders', OrdersIndex::class)->name('orders.index');
    Route::get('/payment-methods', PaymentMethodsIndex::class)->name('payment-methods.index');
    Route::get('/shipping-methods', ShippingMethodsIndex::class)->name('shipping-methods.index');
});
