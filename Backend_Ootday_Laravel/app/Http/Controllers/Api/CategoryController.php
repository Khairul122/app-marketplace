<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CategoryController extends Controller
{
    public function index(Request $request)
    {
        $query = Category::query();

        if ($request->filled('store_id')) {
            $query->where('store_id', $request->integer('store_id'));
        }

        return response()->json($query->get());
    }

    public function myCategories(Request $request)
    {
        $store = $request->user()->store;

        if (! $store) {
            return response()->json(['message' => 'Toko tidak ditemukan'], 404);
        }

        return response()->json($store->categories);
    }

    public function store(Request $request)
    {
        $store = $request->user()->store;

        if (! $store) {
            return response()->json(['message' => 'Toko tidak ditemukan'], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => ['required', 'string', 'max:100'],
            'icon_url' => ['nullable', 'string'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $category = $store->categories()->create($validator->validated());

        return response()->json(['message' => 'Kategori ditambahkan', 'category' => $category], 201);
    }

    public function update(Request $request, int $id)
    {
        $store = $request->user()->store;

        if (! $store) {
            return response()->json(['message' => 'Toko tidak ditemukan'], 404);
        }

        $category = $store->categories()->find($id);

        if (! $category) {
            return response()->json(['message' => 'Kategori tidak ditemukan'], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => ['sometimes', 'string', 'max:100'],
            'icon_url' => ['sometimes', 'nullable', 'string'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $category->update($validator->validated());

        return response()->json(['message' => 'Kategori diperbarui', 'category' => $category]);
    }

    public function destroy(Request $request, int $id)
    {
        $store = $request->user()->store;

        if (! $store) {
            return response()->json(['message' => 'Toko tidak ditemukan'], 404);
        }

        $category = $store->categories()->find($id);

        if (! $category) {
            return response()->json(['message' => 'Kategori tidak ditemukan'], 404);
        }

        $category->delete();

        return response()->json(['message' => 'Kategori dihapus']);
    }
}
