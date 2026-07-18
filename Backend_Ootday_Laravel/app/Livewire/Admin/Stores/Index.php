<?php

namespace App\Livewire\Admin\Stores;

use App\Models\Store;
use App\Models\User;
use Livewire\Attributes\Layout;
use Livewire\Component;
use Livewire\WithPagination;

#[Layout('admin.layout')]
class Index extends Component
{
    use WithPagination;

    public string $search = '';
    public ?int $viewingId = null;
    public ?int $editingId = null;
    public bool $showCreateForm = false;
    public ?int $confirmingDeleteId = null;

    public ?int $owner_id = null;
    public string $store_name = '';
    public ?string $description = '';
    public ?string $address = '';
    public string $status = 'active';

    public function updatingSearch()
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

    public function create()
    {
        $this->reset(['owner_id', 'store_name', 'description', 'address', 'status']);
        $this->status = 'active';
        $this->showCreateForm = true;
    }

    public function edit(int $id)
    {
        $store = Store::findOrFail($id);
        $this->editingId = $id;
        $this->store_name = $store->store_name;
        $this->description = $store->description;
        $this->address = $store->address;
        $this->status = $store->status;
    }

    public function cancelEdit()
    {
        $this->editingId = null;
        $this->showCreateForm = false;
    }

    public function saveNew()
    {
        $this->validate([
            'owner_id' => ['required', 'integer', 'exists:users,id'],
            'store_name' => ['required', 'string', 'max:100'],
            'description' => ['nullable', 'string'],
            'address' => ['nullable', 'string'],
            'status' => ['required', 'in:active,inactive'],
        ]);

        Store::create([
            'owner_id' => $this->owner_id,
            'store_name' => $this->store_name,
            'description' => $this->description,
            'address' => $this->address,
            'status' => $this->status,
        ]);

        $this->showCreateForm = false;
        session()->flash('success', 'Toko berhasil ditambahkan.');
    }

    public function save()
    {
        $this->validate([
            'store_name' => ['required', 'string', 'max:100'],
            'description' => ['nullable', 'string'],
            'address' => ['nullable', 'string'],
            'status' => ['required', 'in:active,inactive'],
        ]);

        $store = Store::findOrFail($this->editingId);
        $store->update([
            'store_name' => $this->store_name,
            'description' => $this->description,
            'address' => $this->address,
            'status' => $this->status,
        ]);

        $this->editingId = null;
        session()->flash('success', 'Toko berhasil diperbarui.');
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
        Store::findOrFail($id)->delete();
        $this->confirmingDeleteId = null;
        session()->flash('success', 'Toko berhasil dihapus.');
    }

    public function render()
    {
        $stores = Store::query()
            ->with('owner')
            ->withCount('products')
            ->when($this->search, fn ($q) => $q->where('store_name', 'like', "%{$this->search}%"))
            ->latest()
            ->paginate(15);

        return view('livewire.admin.stores.index', [
            'stores' => $stores,
            'availableOwners' => User::where('role', 'owner')->doesntHave('store')->orderBy('name')->get(['id', 'name', 'email']),
            'viewingStore' => $this->viewingId
                ? Store::with(['owner', 'categories', 'products'])->withCount('products')->find($this->viewingId)
                : null,
        ]);
    }
}
