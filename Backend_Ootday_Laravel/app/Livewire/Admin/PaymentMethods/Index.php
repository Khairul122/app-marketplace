<?php

namespace App\Livewire\Admin\PaymentMethods;

use App\Models\PaymentMethod;
use Livewire\Attributes\Layout;
use Livewire\Component;

#[Layout('admin.layout')]
class Index extends Component
{
    public bool $showForm = false;
    public ?int $editingId = null;
    public ?int $confirmingDeleteId = null;

    public string $name = '';
    public string $type = 'ewallet';
    public bool $is_active = true;

    public function create()
    {
        $this->reset(['editingId', 'name', 'type', 'is_active']);
        $this->is_active = true;
        $this->type = 'ewallet';
        $this->showForm = true;
    }

    public function edit(int $id)
    {
        $method = PaymentMethod::findOrFail($id);
        $this->editingId = $id;
        $this->name = $method->name;
        $this->type = $method->type;
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
            'name' => ['required', 'string', 'max:100', 'unique:payment_methods,name,'.$this->editingId],
            'type' => ['required', 'in:ewallet,bank_transfer,cod'],
            'is_active' => ['boolean'],
        ]);

        PaymentMethod::updateOrCreate(
            ['id' => $this->editingId],
            ['name' => $this->name, 'type' => $this->type, 'is_active' => $this->is_active]
        );

        $this->showForm = false;
        session()->flash('success', 'Metode pembayaran berhasil disimpan.');
    }

    public function toggleActive(int $id)
    {
        $method = PaymentMethod::findOrFail($id);
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
        PaymentMethod::findOrFail($id)->delete();
        $this->confirmingDeleteId = null;
        session()->flash('success', 'Metode pembayaran berhasil dihapus.');
    }

    public function render()
    {
        return view('livewire.admin.payment-methods.index', [
            'methods' => PaymentMethod::orderBy('name')->get(),
        ]);
    }
}
