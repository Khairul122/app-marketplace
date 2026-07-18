<?php

namespace App\Livewire\Admin\ShippingMethods;

use App\Models\ShippingMethod;
use Livewire\Attributes\Layout;
use Livewire\Component;

#[Layout('admin.layout')]
class Index extends Component
{
    public bool $showForm = false;
    public ?int $editingId = null;
    public ?int $confirmingDeleteId = null;

    public string $name = '';
    public string $base_cost = '';
    public bool $is_active = true;

    public function create()
    {
        $this->reset(['editingId', 'name', 'base_cost', 'is_active']);
        $this->is_active = true;
        $this->showForm = true;
    }

    public function edit(int $id)
    {
        $method = ShippingMethod::findOrFail($id);
        $this->editingId = $id;
        $this->name = $method->name;
        $this->base_cost = (string) $method->base_cost;
        $this->is_active = $method->is_active;
        $this->showForm = true;
    }

    public function cancel()
    {
        $this->showForm = false;
    }

    public function save()
    {
        $this->validate([
            'name' => ['required', 'string', 'max:100', 'unique:shipping_methods,name,'.$this->editingId],
            'base_cost' => ['required', 'numeric', 'min:0'],
            'is_active' => ['boolean'],
        ]);

        ShippingMethod::updateOrCreate(
            ['id' => $this->editingId],
            ['name' => $this->name, 'base_cost' => $this->base_cost, 'is_active' => $this->is_active]
        );

        $this->showForm = false;
        session()->flash('success', 'Metode pengiriman berhasil disimpan.');
    }

    public function toggleActive(int $id)
    {
        $method = ShippingMethod::findOrFail($id);
        $method->update(['is_active' => ! $method->is_active]);
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
        ShippingMethod::findOrFail($id)->delete();
        $this->confirmingDeleteId = null;
        session()->flash('success', 'Metode pengiriman berhasil dihapus.');
    }

    public function render()
    {
        return view('livewire.admin.shipping-methods.index', [
            'methods' => ShippingMethod::orderBy('name')->get(),
        ]);
    }
}
