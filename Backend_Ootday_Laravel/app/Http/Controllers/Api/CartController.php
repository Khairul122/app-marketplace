<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProductVariant;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CartController extends Controller
{
    public function index(Request $request)
    {
        $items = $request->user()->cartItems()
            ->with(['variant.product.images', 'variant.product.store'])
            ->get();

        return response()->json($items);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'variant_id' => ['required', 'integer', 'exists:product_variants,id'],
            'quantity' => ['nullable', 'integer', 'min:1'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $user = $request->user();

        $item = $user->cartItems()->where('variant_id', $data['variant_id'])->first();

        if ($item) {
            $item->increment('quantity', $data['quantity'] ?? 1);
        } else {
            $item = $user->cartItems()->create([
                'variant_id' => $data['variant_id'],
                'quantity' => $data['quantity'] ?? 1,
                'is_selected' => true,
            ]);
        }

        return response()->json([
            'message' => 'Ditambahkan ke keranjang',
            'item' => $item->load('variant.product.images'),
        ], 201);
    }

    public function update(Request $request, int $id)
    {
        $item = $request->user()->cartItems()->find($id);

        if (! $item) {
            return response()->json(['message' => 'Item keranjang tidak ditemukan'], 404);
        }

        $validator = Validator::make($request->all(), [
            'quantity' => ['sometimes', 'integer', 'min:1'],
            'is_selected' => ['sometimes', 'boolean'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $item->update($validator->validated());

        return response()->json(['message' => 'Keranjang diperbarui', 'item' => $item]);
    }

    public function selectAll(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'is_selected' => ['required', 'boolean'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $request->user()->cartItems()->update(['is_selected' => $request->boolean('is_selected')]);

        return response()->json(['message' => 'Keranjang diperbarui']);
    }

    public function destroy(Request $request, int $id)
    {
        $item = $request->user()->cartItems()->find($id);

        if (! $item) {
            return response()->json(['message' => 'Item keranjang tidak ditemukan'], 404);
        }

        $item->delete();

        return response()->json(['message' => 'Item dihapus dari keranjang']);
    }
}
