<?php

namespace App\Livewire\Admin;

use App\Models\Order;
use App\Models\Product;
use App\Models\Store;
use App\Models\User;
use Livewire\Attributes\Layout;
use Livewire\Component;

#[Layout('admin.layout')]
class Dashboard extends Component
{
    public function render()
    {
        $usersByRole = User::selectRaw('role, count(*) as total')->groupBy('role')->pluck('total', 'role');

        $ordersByStatus = collect(Order::STATUSES)
            ->mapWithKeys(fn ($status) => [$status => Order::where('status', $status)->count()]);

        return view('livewire.admin.dashboard', [
            'totalUsers' => User::count(),
            'usersByRole' => $usersByRole,
            'totalStores' => Store::count(),
            'totalProducts' => Product::count(),
            'totalOrders' => Order::count(),
            'ordersByStatus' => $ordersByStatus,
            'revenue' => Order::where('status', 'selesai')->sum('total_price'),
        ]);
    }
}
