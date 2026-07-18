<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        return response()->json(
            $request->user()->notificationsApp()->latest()->get()
        );
    }

    public function markRead(Request $request, int $id)
    {
        $notification = $request->user()->notificationsApp()->find($id);

        if (! $notification) {
            return response()->json(['message' => 'Notifikasi tidak ditemukan'], 404);
        }

        $notification->update(['is_read' => true]);

        return response()->json(['message' => 'Notifikasi ditandai dibaca', 'notification' => $notification]);
    }

    public function markAllRead(Request $request)
    {
        $request->user()->notificationsApp()->update(['is_read' => true]);

        return response()->json(['message' => 'Semua notifikasi ditandai dibaca']);
    }
}
