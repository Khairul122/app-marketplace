<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AddressController extends Controller
{
    public function index(Request $request)
    {
        return response()->json($request->user()->addresses);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'receiver_name' => ['required', 'string', 'max:100'],
            'phone' => ['required', 'string', 'max:20'],
            'full_address' => ['required', 'string'],
            'is_main' => ['nullable', 'boolean'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();
        $user = $request->user();

        if ($data['is_main'] ?? false) {
            $user->addresses()->update(['is_main' => false]);
        }

        $address = $user->addresses()->create($data);

        return response()->json(['message' => 'Alamat ditambahkan', 'address' => $address], 201);
    }

    public function update(Request $request, int $id)
    {
        $address = $request->user()->addresses()->find($id);

        if (! $address) {
            return response()->json(['message' => 'Alamat tidak ditemukan'], 404);
        }

        $validator = Validator::make($request->all(), [
            'receiver_name' => ['sometimes', 'string', 'max:100'],
            'phone' => ['sometimes', 'string', 'max:20'],
            'full_address' => ['sometimes', 'string'],
            'is_main' => ['sometimes', 'boolean'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $data = $validator->validated();

        if ($data['is_main'] ?? false) {
            $request->user()->addresses()->where('id', '!=', $id)->update(['is_main' => false]);
        }

        $address->update($data);

        return response()->json(['message' => 'Alamat diperbarui', 'address' => $address]);
    }

    public function destroy(Request $request, int $id)
    {
        $address = $request->user()->addresses()->find($id);

        if (! $address) {
            return response()->json(['message' => 'Alamat tidak ditemukan'], 404);
        }

        $address->delete();

        return response()->json(['message' => 'Alamat dihapus']);
    }
}
