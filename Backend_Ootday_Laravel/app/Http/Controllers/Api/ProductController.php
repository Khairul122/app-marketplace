<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\ProductImage;
use App\Models\ProductVariant;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $query = Product::with(['images', 'variants', 'category'])
            ->where('status', 'active');

        if ($request->filled('store_id')) {
            $query->where('store_id', $request->integer('store_id'));
        }

        if ($request->filled('category_id')) {
            $query->where('category_id', $request->integer('category_id'));
        }

        if ($request->filled('q')) {
            $query->where('name', 'like', '%'.$request->string('q').'%');
        }

        return response()->json($query->latest()->get());
    }

    public function show(Request $request, int $id)
    {
        $product = Product::with(['images', 'variants', 'category', 'store'])->findOrFail($id);

        return response()->json($product);
    }

    public function myProducts(Request $request)
    {
        $store = $request->user()->store;

        if (! $store) {
            return response()->json(['message' => 'Toko tidak ditemukan'], 404);
        }

        return response()->json(
            $store->products()->with(['images', 'variants', 'category'])->latest()->get()
        );
    }

    public function store(Request $request)
    {
        $store = $request->user()->store;

        if (! $store) {
            return response()->json(['message' => 'Toko tidak ditemukan'], 404);
        }

        $validator = Validator::make($request->all(), [
            'category_id' => ['nullable', 'integer', 'exists:categories,id'],
            'name' => ['required', 'string', 'max:255'],
            'price' => ['required', 'numeric', 'min:0'],
            'stock' => ['nullable', 'integer', 'min:0'],
            'description' => ['nullable', 'string'],
            'status' => ['nullable', 'in:active,inactive'],
            'images' => ['nullable', 'array'],
            'images.*' => ['file', 'image', 'max:5120'],
            'variants' => ['nullable', 'array'],
            'variants.*.size' => ['required_with:variants', 'string', 'max:50'],
            'variants.*.color' => ['required_with:variants', 'string', 'max:50'],
            'variants.*.stock' => ['nullable', 'integer', 'min:0'],
            'variants.*.price' => ['nullable', 'numeric', 'min:0'],
            'variants.*.price_adjustment' => ['nullable', 'numeric'],
            'variants.*.image_url' => ['nullable', 'string'],
            'variant_images' => ['nullable', 'array'],
            'variant_images.*' => ['file', 'image', 'max:5120'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();

        $product = $store->products()->create([
            'category_id' => $data['category_id'] ?? null,
            'name' => $data['name'],
            'price' => $data['price'],
            'stock' => $data['stock'] ?? 0,
            'description' => $data['description'] ?? null,
            'status' => $data['status'] ?? 'active',
        ]);

        foreach ($request->file('images', []) as $index => $file) {
            $path = $file->store('products', 'public');

            $product->images()->create([
                'image_url' => Storage::url($path),
                'is_primary' => $index === 0,
                'sort_order' => $index,
            ]);
        }

        $variantImages = $request->file('variant_images', []);
        foreach ($data['variants'] ?? [] as $index => $variant) {
            $imageUrl = $variant['image_url'] ?? null;
            if (isset($variantImages[$index]) && $variantImages[$index]->isValid()) {
                $path = $variantImages[$index]->store('variants', 'public');
                $imageUrl = Storage::url($path);
            }

            $product->variants()->create([
                'size' => $variant['size'],
                'color' => $variant['color'],
                'stock' => $variant['stock'] ?? 0,
                'price' => $variant['price'] ?? null,
                'price_adjustment' => $variant['price_adjustment'] ?? 0,
                'image_url' => $imageUrl,
            ]);
        }

        return response()->json([
            'message' => 'Produk ditambahkan',
            'product' => $product->load(['images', 'variants', 'category']),
        ], 201);
    }

    public function update(Request $request, int $id)
    {
        $store = $request->user()->store;

        if (! $store) {
            return response()->json(['message' => 'Toko tidak ditemukan'], 404);
        }

        $product = $store->products()->find($id);

        if (! $product) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }

        $validator = Validator::make($request->all(), [
            'category_id' => ['sometimes', 'nullable', 'integer', 'exists:categories,id'],
            'name' => ['sometimes', 'string', 'max:255'],
            'price' => ['sometimes', 'numeric', 'min:0'],
            'stock' => ['sometimes', 'integer', 'min:0'],
            'description' => ['sometimes', 'nullable', 'string'],
            'status' => ['sometimes', 'in:active,inactive'],
            'images' => ['nullable', 'array'],
            'images.*' => ['file', 'image', 'max:5120'],
            'variants' => ['nullable', 'array'],
            'variants.*.size' => ['required_with:variants', 'string', 'max:50'],
            'variants.*.color' => ['required_with:variants', 'string', 'max:50'],
            'variants.*.stock' => ['nullable', 'integer', 'min:0'],
            'variants.*.price' => ['nullable', 'numeric', 'min:0'],
            'variants.*.price_adjustment' => ['nullable', 'numeric'],
            'variants.*.image_url' => ['nullable', 'string'],
            'variant_images' => ['nullable', 'array'],
            'variant_images.*' => ['file', 'image', 'max:5120'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $product->update($data);

        // Upload main images if provided
        if ($request->hasFile('images')) {
            // Delete old images
            foreach ($product->images as $oldImg) {
                $filePath = str_replace('/storage/', '', $oldImg->image_url);
                Storage::disk('public')->delete($filePath);
                $oldImg->delete();
            }

            // Create new images
            foreach ($request->file('images') as $index => $file) {
                $path = $file->store('products', 'public');
                $product->images()->create([
                    'image_url' => Storage::url($path),
                    'is_primary' => $index === 0,
                    'sort_order' => $index,
                ]);
            }
        }

        // Update variants if provided
        if ($request->has('variants')) {
            $product->variants()->delete();
            $variantImages = $request->file('variant_images', []);
            foreach ($request->input('variants', []) as $index => $variant) {
                $imageUrl = $variant['image_url'] ?? null;
                if (isset($variantImages[$index]) && $variantImages[$index]->isValid()) {
                    $path = $variantImages[$index]->store('variants', 'public');
                    $imageUrl = Storage::url($path);
                }

                $product->variants()->create([
                    'size' => $variant['size'],
                    'color' => $variant['color'],
                    'stock' => $variant['stock'] ?? 0,
                    'price' => $variant['price'] ?? null,
                    'price_adjustment' => $variant['price_adjustment'] ?? 0,
                    'image_url' => $imageUrl,
                ]);
            }
        }

        return response()->json(['message' => 'Produk diperbarui', 'product' => $product->load(['images', 'variants', 'category'])]);
    }

    public function destroy(Request $request, int $id)
    {
        $store = $request->user()->store;

        if (! $store) {
            return response()->json(['message' => 'Toko tidak ditemukan'], 404);
        }

        $product = $store->products()->find($id);

        if (! $product) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }

        $product->delete();

        return response()->json(['message' => 'Produk dihapus']);
    }

    public function addImages(Request $request, int $id)
    {
        $store = $request->user()->store;

        if (! $store) {
            return response()->json(['message' => 'Toko tidak ditemukan'], 404);
        }

        $product = $store->products()->find($id);

        if (! $product) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }

        $validator = Validator::make($request->all(), [
            'images' => ['required', 'array'],
            'images.*' => ['file', 'image', 'max:5120'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $nextSort = $product->images()->max('sort_order');
        $nextSort = $nextSort === null ? 0 : $nextSort + 1;
        $hasPrimary = $product->images()->where('is_primary', true)->exists();

        foreach ($request->file('images') as $file) {
            $path = $file->store('products', 'public');

            $product->images()->create([
                'image_url' => Storage::url($path),
                'is_primary' => ! $hasPrimary,
                'sort_order' => $nextSort++,
            ]);

            $hasPrimary = true;
        }

        return response()->json(['message' => 'Gambar ditambahkan', 'images' => $product->images()->get()], 201);
    }
}
