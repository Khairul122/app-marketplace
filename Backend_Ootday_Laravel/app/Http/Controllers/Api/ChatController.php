<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ChatThread;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ChatController extends Controller
{
    public function threads(Request $request)
    {
        $user = $request->user();

        if ($user->isOwner()) {
            $threads = $user->store
                ? $user->store->chatThreads()->with(['customer', 'store'])->latest('last_message_at')->get()
                : collect();
        } else {
            $threads = ChatThread::where('customer_id', $user->id)
                ->with(['customer', 'store'])
                ->latest('last_message_at')
                ->get();
        }

        return response()->json($threads);
    }

    public function startThread(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'store_id' => ['required', 'integer', 'exists:stores,id'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $thread = ChatThread::firstOrCreate([
            'customer_id' => $request->user()->id,
            'store_id' => $request->integer('store_id'),
        ]);

        return response()->json(['message' => 'Thread siap', 'thread' => $thread->load(['customer', 'store'])]);
    }

    public function messages(Request $request, int $threadId)
    {
        $thread = $this->authorizedThread($request, $threadId);

        if (! $thread) {
            return response()->json(['message' => 'Thread tidak ditemukan'], 404);
        }

        return response()->json($thread->messages()->with('sender')->oldest()->get());
    }

    public function sendMessage(Request $request, int $threadId)
    {
        $thread = $this->authorizedThread($request, $threadId);

        if (! $thread) {
            return response()->json(['message' => 'Thread tidak ditemukan'], 404);
        }

        $validator = Validator::make($request->all(), [
            'message' => ['required', 'string'],
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Validasi gagal', 'errors' => $validator->errors()], 422);
        }

        $user = $request->user();

        $message = $thread->messages()->create([
            'sender_role' => $user->role,
            'sender_id' => $user->id,
            'message' => $request->string('message'),
        ]);

        $thread->update(['last_message_at' => now()]);

        return response()->json(['message' => 'Pesan terkirim', 'chat_message' => $message->load('sender')], 201);
    }

    private function authorizedThread(Request $request, int $threadId): ?ChatThread
    {
        $user = $request->user();
        $thread = ChatThread::find($threadId);

        if (! $thread) {
            return null;
        }

        if ($user->isOwner()) {
            return $user->store && $thread->store_id === $user->store->id ? $thread : null;
        }

        return $thread->customer_id === $user->id ? $thread : null;
    }
}
