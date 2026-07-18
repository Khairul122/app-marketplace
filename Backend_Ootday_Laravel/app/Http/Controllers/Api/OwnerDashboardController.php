<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;

class OwnerDashboardController extends Controller
{
    public function index(Request $request)
    {
        $store = $request->user()->store;

        if (! $store) {
            return response()->json(['message' => 'Toko tidak ditemukan'], 404);
        }

        $ordersByStatus = $store->orders()
            ->selectRaw('status, count(*) as total')
            ->groupBy('status')
            ->pluck('total', 'status');

        $statusCounts = collect(Order::STATUSES)
            ->mapWithKeys(fn ($status) => [$status => (int) ($ordersByStatus[$status] ?? 0)]);

        $revenue = (float) $store->orders()->where('status', 'selesai')->sum('total_price');

        $topProducts = $store->products()
            ->orderByDesc('sold_count')
            ->take(5)
            ->get(['id', 'name', 'sold_count', 'price']);

        return response()->json([
            'total_products' => $store->products()->count(),
            'total_orders' => $store->orders()->count(),
            'orders_by_status' => $statusCounts,
            'revenue' => $revenue,
            'top_products' => $topProducts,
        ]);
    }
}
