<?php

use App\Http\Controllers\Api\AddressController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\ChatController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\OwnerDashboardController;
use App\Http\Controllers\Api\PaymentMethodController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\ShippingMethodController;
use App\Http\Controllers\Api\StoreController;
use Illuminate\Support\Facades\Route;

// Auth (publik)
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Publik (tanpa login) - katalog toko/produk
Route::get('/stores/{id}', [StoreController::class, 'show']);
Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/products', [ProductController::class, 'index']);
Route::get('/products/{id}', [ProductController::class, 'show']);
Route::get('/payment-methods', [PaymentMethodController::class, 'index']);
Route::get('/shipping-methods', [ShippingMethodController::class, 'index']);

Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::put('/profile', [AuthController::class, 'updateProfile']);
    Route::put('/password', [AuthController::class, 'changePassword']);
    Route::delete('/account', [AuthController::class, 'deleteAccount']);

    // Notifications & chat (kedua role)
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::put('/notifications/{id}/read', [NotificationController::class, 'markRead']);
    Route::put('/notifications/read-all', [NotificationController::class, 'markAllRead']);

    Route::get('/chat/threads', [ChatController::class, 'threads']);
    Route::get('/chat/threads/{id}/messages', [ChatController::class, 'messages']);
    Route::post('/chat/threads/{id}/messages', [ChatController::class, 'sendMessage']);

    // Pelanggan
    Route::middleware('role:pelanggan')->group(function () {
        Route::post('/chat/threads', [ChatController::class, 'startThread']);

        Route::get('/cart', [CartController::class, 'index']);
        Route::post('/cart', [CartController::class, 'store']);
        Route::put('/cart/select-all', [CartController::class, 'selectAll']);
        Route::put('/cart/{id}', [CartController::class, 'update']);
        Route::delete('/cart/{id}', [CartController::class, 'destroy']);

        Route::get('/addresses', [AddressController::class, 'index']);
        Route::post('/addresses', [AddressController::class, 'store']);
        Route::put('/addresses/{id}', [AddressController::class, 'update']);
        Route::delete('/addresses/{id}', [AddressController::class, 'destroy']);

        Route::get('/orders', [OrderController::class, 'index']);
        Route::post('/orders', [OrderController::class, 'store']);
    });

    Route::get('/orders/{id}', [OrderController::class, 'show']);

    // Owner
    Route::middleware('role:owner')->group(function () {
        Route::get('/my-store', [StoreController::class, 'myStore']);
        Route::put('/my-store', [StoreController::class, 'updateMyStore']);

        Route::get('/my-categories', [CategoryController::class, 'myCategories']);
        Route::post('/my-categories', [CategoryController::class, 'store']);
        Route::put('/my-categories/{id}', [CategoryController::class, 'update']);
        Route::delete('/my-categories/{id}', [CategoryController::class, 'destroy']);

        Route::get('/my-products', [ProductController::class, 'myProducts']);
        Route::post('/my-products', [ProductController::class, 'store']);
        Route::put('/my-products/{id}', [ProductController::class, 'update']);
        Route::delete('/my-products/{id}', [ProductController::class, 'destroy']);
        Route::post('/my-products/{id}/images', [ProductController::class, 'addImages']);

        Route::get('/my-orders', [OrderController::class, 'myOrders']);
        Route::put('/my-orders/{id}/status', [OrderController::class, 'updateStatus']);

        Route::get('/owner/dashboard', [OwnerDashboardController::class, 'index']);
    });
});
