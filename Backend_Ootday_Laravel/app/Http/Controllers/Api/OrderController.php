<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $orders = $request->user()->orders()
            ->with(['items', 'store', 'paymentMethod', 'shippingMethod'])
            ->latest('ordered_at')
            ->get();

        return response()->json($orders);
    }

    public function show(Request $request, int $id)
    {
        $order = $request->user()->orders()
            ->with(['items', 'store', 'paymentMethod', 'shippingMethod'])
            ->find($id);

        if (! $order) {
            $order = $request->user()->store?->orders()
                ->with(['items', 'store', 'paymentMethod', 'shippingMethod', 'user'])
                ->find($id);
        }

        if (! $order) {
            return response()->json(['message' => 'Pesanan tidak ditemukan'], 404);
        }

        return response()->json($order);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'cart_item_ids' => ['required', 'array', 'min:1'],
            'cart_item_ids.*' => ['integer', 'exists:cart_items,id'],
            'payment_method_id' => ['nullable', 'integer', 'exists:payment_methods,id'],
            'shipping_method_id' => ['nullable', 'integer', 'exists:shipping_methods,id'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $user = $request->user();

        $cartItems = $user->cartItems()
            ->with('variant.product')
            ->whereIn('id', $data['cart_item_ids'])
            ->get();

        if ($cartItems->isEmpty()) {
            return response()->json(['message' => 'Keranjang kosong'], 422);
        }

        $storeId = $cartItems->first()->variant->product->store_id;

        if ($cartItems->contains(fn ($item) => $item->variant->product->store_id !== $storeId)) {
            return response()->json(['message' => 'Semua item harus dari toko yang sama'], 422);
        }

        $shippingCost = 0;
        if (! empty($data['shipping_method_id'])) {
            $shippingCost = \App\Models\ShippingMethod::find($data['shipping_method_id'])->base_cost;
        }

        $subtotal = $cartItems->sum(fn ($item) => $item->variant->effectivePrice() * $item->quantity);

        $order = DB::transaction(function () use ($user, $storeId, $cartItems, $data, $subtotal, $shippingCost) {
            $order = Order::create([
                'order_code' => 'ORD-'.strtoupper(Str::random(10)),
                'user_id' => $user->id,
                'store_id' => $storeId,
                'payment_method_id' => $data['payment_method_id'] ?? null,
                'shipping_method_id' => $data['shipping_method_id'] ?? null,
                'subtotal' => $subtotal,
                'shipping_cost' => $shippingCost,
                'total_price' => $subtotal + $shippingCost,
                'status' => 'menunggu_pembayaran',
                'ordered_at' => now(),
            ]);

            foreach ($cartItems as $item) {
                $product = $item->variant->product;

                $order->items()->create([
                    'product_id' => $product->id,
                    'variant_id' => $item->variant->id,
                    'product_name' => $product->name,
                    'variant_label' => trim($item->variant->attribute1_value.' / '.($item->variant->attribute2_value ?? ''), ' /'),
                    'image_url' => $product->images()->where('is_primary', true)->first()?->image_url,
                    'price' => $item->variant->effectivePrice(),
                    'quantity' => $item->quantity,
                ]);

                $product->increment('sold_count', $item->quantity);
            }

            $user->cartItems()->whereIn('id', $cartItems->pluck('id'))->delete();

            return $order;
        });

        return response()->json([
            'message' => 'Pesanan berhasil dibuat',
            'order' => $order->load(['items', 'store', 'paymentMethod', 'shippingMethod']),
        ], 201);
    }

    public function myOrders(Request $request)
    {
        $store = $request->user()->store;

        if (! $store) {
            return response()->json(['message' => 'Toko tidak ditemukan'], 404);
        }

        $orders = $store->orders()
            ->with(['items', 'user', 'paymentMethod', 'shippingMethod'])
            ->latest('ordered_at')
            ->get();

        return response()->json($orders);
    }

    public function updateStatus(Request $request, int $id)
    {
        $store = $request->user()->store;

        if (! $store) {
            return response()->json(['message' => 'Toko tidak ditemukan'], 404);
        }

        $order = $store->orders()->find($id);

        if (! $order) {
            return response()->json(['message' => 'Pesanan tidak ditemukan'], 404);
        }

        $validator = Validator::make($request->all(), [
            'status' => ['required', 'in:'.implode(',', Order::STATUSES)],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $order->update(['status' => $request->string('status')]);

        $order->user->notificationsApp()->create([
            'title' => 'Status pesanan diperbarui',
            'body' => "Pesanan {$order->order_code} sekarang berstatus {$order->status}.",
            'type' => 'order',
        ]);

        return response()->json(['message' => 'Status pesanan diperbarui', 'order' => $order]);
    }
}
