<?php

namespace App\Livewire\Admin\Categories;

use App\Models\Category;
use App\Models\Store;
use Livewire\Attributes\Layout;
use Livewire\Component;
use Livewire\WithPagination;

#[Layout('admin.layout')]
class Index extends Component
{
    use WithPagination;

    public string $storeFilter = '';
    public ?int $viewingId = null;
    public ?int $editingId = null;
    public bool $showCreateForm = false;
    public ?int $confirmingDeleteId = null;

    public ?int $store_id = null;
    public string $name = '';
    public ?string $icon_url = '';

    public function updatingStoreFilter()
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
        $this->reset(['store_id', 'name', 'icon_url']);
        $this->showCreateForm = true;
    }

    public function edit(int $id)
    {
        $category = Category::findOrFail($id);
        $this->editingId = $id;
        $this->name = $category->name;
        $this->icon_url = $category->icon_url;
    }

    public function cancelEdit()
    {
        $this->editingId = null;
        $this->showCreateForm = false;
    }

    public function saveNew()
    {
        $this->validate([
            'store_id' => ['required', 'integer', 'exists:stores,id'],
            'name' => ['required', 'string', 'max:100'],
            'icon_url' => ['nullable', 'string'],
        ]);

        Category::create([
            'store_id' => $this->store_id,
            'name' => $this->name,
            'icon_url' => $this->icon_url,
        ]);

        $this->showCreateForm = false;
        session()->flash('success', 'Kategori berhasil ditambahkan.');
    }

    public function save()
    {
        $this->validate([
            'name' => ['required', 'string', 'max:100'],
            'icon_url' => ['nullable', 'string'],
        ]);

        Category::findOrFail($this->editingId)->update([
            'name' => $this->name,
            'icon_url' => $this->icon_url,
        ]);

        $this->editingId = null;
        session()->flash('success', 'Kategori berhasil diperbarui.');
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
        Category::findOrFail($id)->delete();
        $this->confirmingDeleteId = null;
        session()->flash('success', 'Kategori berhasil dihapus.');
    }

    public function render()
    {
        $categories = Category::query()
            ->with('store')
            ->withCount('products')
            ->when($this->storeFilter, fn ($q) => $q->where('store_id', $this->storeFilter))
            ->latest()
            ->paginate(15);

        return view('livewire.admin.categories.index', [
            'categories' => $categories,
            'stores' => Store::orderBy('store_name')->get(['id', 'store_name']),
            'viewingCategory' => $this->viewingId
                ? Category::with(['store', 'products'])->withCount('products')->find($this->viewingId)
                : null,
        ]);
    }
}
