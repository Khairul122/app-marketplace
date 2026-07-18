<?php

namespace App\Livewire\Admin\Orders;

use App\Models\Order;
use Livewire\Attributes\Layout;
use Livewire\Component;
use Livewire\WithPagination;

#[Layout('admin.layout')]
class Index extends Component
{
    use WithPagination;

    public string $search = '';
    public string $statusFilter = '';
    public ?int $viewingId = null;
    public ?int $confirmingDeleteId = null;

    public function updatingSearch()
    {
        $this->resetPage();
    }

    public function updatingStatusFilter()
    {
        $this->resetPage();
    }

    public function view(int $id)
    {
        $this->viewingId = $id;
    }

    public function closeView()
    {
        $this->viewingId = null;
    }

    public function updateStatus(int $id, string $status)
    {
        if (! in_array($status, Order::STATUSES, true)) {
            return;
        }

        Order::findOrFail($id)->update(['status' => $status]);
        session()->flash('success', 'Status pesanan berhasil diperbarui.');
    }

    public function confirmDelete(int $id)
    {
        $this->confirmingDeleteId = $id;
    }

    public function cancelDelete()
    {
        $this->confirmingDeleteId = null;
    }

    public function delete(int $id)
    {
        Order::findOrFail($id)->delete();
        $this->confirmingDeleteId = null;
        session()->flash('success', 'Pesanan berhasil dihapus.');
    }

    public function render()
    {
        $orders = Order::query()
            ->with(['user', 'store', 'paymentMethod', 'shippingMethod'])
            ->when($this->search, fn ($q) => $q->where('order_code', 'like', "%{$this->search}%"))
            ->when($this->statusFilter, fn ($q) => $q->where('status', $this->statusFilter))
            ->latest('ordered_at')
            ->paginate(15);

        return view('livewire.admin.orders.index', [
            'orders' => $orders,
            'statuses' => Order::STATUSES,
            'viewingOrder' => $this->viewingId
                ? Order::with(['items', 'user', 'store', 'paymentMethod', 'shippingMethod'])->find($this->viewingId)
                : null,
        ]);
    }
}
