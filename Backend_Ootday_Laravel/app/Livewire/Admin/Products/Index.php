<?php

namespace App\Livewire\Admin\Products;

use App\Models\Category;
use App\Models\Product;
use App\Models\Store;
use Illuminate\Support\Facades\Storage;
use Livewire\Attributes\Layout;
use Livewire\Component;
use Livewire\WithFileUploads;
use Livewire\WithPagination;

#[Layout('admin.layout')]
class Index extends Component
{
    use WithPagination;
    use WithFileUploads;

    public string $search = '';
    public string $storeFilter = '';
    public string $statusFilter = '';
    public ?int $viewingId = null;
    public ?int $editingId = null;
    public bool $showCreateForm = false;
    public ?int $confirmingDeleteId = null;

    public ?int $new_store_id = null;
    public ?int $new_category_id = null;
    public string $name = '';
    public string $price = '';
    public string $stock = '';
    public ?string $description = '';
    public string $status = 'active';

    /** @var \Livewire\Features\SupportFileUploads\TemporaryUploadedFile[] */
    public array $newImages = [];

    /** @var \Livewire\Features\SupportFileUploads\TemporaryUploadedFile[] */
    public array $editImages = [];

    public function updatingSearch()
    {
        $this->resetPage();
    }

    public function updatingStoreFilter()
    {
        $this->resetPage();
    }

    public function updatingStatusFilter()
    {
        $this->resetPage();
    }

    public function updatedNewStoreId()
    {
        $this->new_category_id = null;
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
        $this->reset(['new_store_id', 'new_category_id', 'name', 'price', 'stock', 'description', 'status', 'newImages']);
        $this->status = 'active';
        $this->showCreateForm = true;
    }

    public function edit(int $id)
    {
        $product = Product::findOrFail($id);
        $this->editingId = $id;
        $this->name = $product->name;
        $this->price = (string) $product->price;
        $this->stock = (string) $product->stock;
        $this->status = $product->status;
        $this->editImages = [];
    }

    public function cancelEdit()
    {
        $this->editingId = null;
        $this->showCreateForm = false;
    }

    public function removeNewImage(int $index)
    {
        unset($this->newImages[$index]);
        $this->newImages = array_values($this->newImages);
    }

    public function removeEditImage(int $index)
    {
        unset($this->editImages[$index]);
        $this->editImages = array_values($this->editImages);
    }

    public function saveNew()
    {
        $this->validate([
            'new_store_id' => ['required', 'integer', 'exists:stores,id'],
            'new_category_id' => ['nullable', 'integer', 'exists:categories,id'],
            'name' => ['required', 'string', 'max:255'],
            'price' => ['required', 'numeric', 'min:0'],
            'stock' => ['required', 'integer', 'min:0'],
            'description' => ['nullable', 'string'],
            'status' => ['required', 'in:active,inactive'],
            'newImages.*' => ['nullable', 'image', 'max:5120'],
        ]);

        $product = Product::create([
            'store_id' => $this->new_store_id,
            'category_id' => $this->new_category_id,
            'name' => $this->name,
            'price' => $this->price,
            'stock' => $this->stock,
            'description' => $this->description,
            'status' => $this->status,
        ]);

        foreach ($this->newImages as $index => $image) {
            $path = $image->store('products', 'public');

            $product->images()->create([
                'image_url' => Storage::url($path),
                'is_primary' => $index === 0,
                'sort_order' => $index,
            ]);
        }

        $this->showCreateForm = false;
        session()->flash('success', 'Produk berhasil ditambahkan.');
    }

    public function save()
    {
        $this->validate([
            'name' => ['required', 'string', 'max:255'],
            'price' => ['required', 'numeric', 'min:0'],
            'stock' => ['required', 'integer', 'min:0'],
            'status' => ['required', 'in:active,inactive'],
            'editImages.*' => ['nullable', 'image', 'max:5120'],
        ]);

        $product = Product::findOrFail($this->editingId);

        $product->update([
            'name' => $this->name,
            'price' => $this->price,
            'stock' => $this->stock,
            'status' => $this->status,
        ]);

        if (! empty($this->editImages)) {
            $nextSort = $product->images()->max('sort_order');
            $nextSort = $nextSort === null ? 0 : $nextSort + 1;
            $hasPrimary = $product->images()->where('is_primary', true)->exists();

            foreach ($this->editImages as $image) {
                $path = $image->store('products', 'public');

                $product->images()->create([
                    'image_url' => Storage::url($path),
                    'is_primary' => ! $hasPrimary,
                    'sort_order' => $nextSort++,
                ]);

                $hasPrimary = true;
            }
        }

        $this->editingId = null;
        session()->flash('success', 'Produk berhasil diperbarui.');
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
        Product::findOrFail($id)->delete();
        $this->confirmingDeleteId = null;
        session()->flash('success', 'Produk berhasil dihapus.');
    }

    public function render()
    {
        $products = Product::query()
            ->with(['store', 'category', 'images', 'variants'])
            ->when($this->search, fn ($q) => $q->where('name', 'like', "%{$this->search}%"))
            ->when($this->storeFilter, fn ($q) => $q->where('store_id', $this->storeFilter))
            ->when($this->statusFilter, fn ($q) => $q->where('status', $this->statusFilter))
            ->latest()
            ->paginate(15);

        return view('livewire.admin.products.index', [
            'products' => $products,
            'stores' => Store::orderBy('store_name')->get(['id', 'store_name']),
            'categoriesForNewStore' => $this->new_store_id
                ? Category::where('store_id', $this->new_store_id)->orderBy('name')->get(['id', 'name'])
                : collect(),
            'viewingProduct' => $this->viewingId ? Product::with(['images', 'variants', 'category', 'store'])->find($this->viewingId) : null,
        ]);
    }
}
