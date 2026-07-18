<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Store;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class StoreController extends Controller
{
    public function show(Request $request, int $id)
    {
        $store = Store::withCount('products')->findOrFail($id);

        return response()->json($store);
    }

    public function myStore(Request $request)
    {
        $store = $request->user()->store;

        if (! $store) {
            return response()->json(['message' => 'Toko tidak ditemukan'], 404);
        }

        return response()->json($store);
    }

    public function updateMyStore(Request $request)
    {
        $store = $request->user()->store;

        if (! $store) {
            return response()->json(['message' => 'Toko tidak ditemukan'], 404);
        }

        $validator = Validator::make($request->all(), [
            'store_name' => ['sometimes', 'string', 'max:100'],
            'description' => ['sometimes', 'nullable', 'string'],
            'address' => ['sometimes', 'nullable', 'string'],
            'photo_url' => ['sometimes', 'nullable', 'string'],
            'photo' => ['sometimes', 'file', 'image', 'max:5120'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        unset($data['photo']);

        if ($request->hasFile('photo')) {
            $path = $request->file('photo')->store('stores', 'public');
            $data['photo_url'] = Storage::url($path);
        }

        $store->update($data);

        return response()->json(['message' => 'Toko diperbarui', 'store' => $store]);
    }
}
