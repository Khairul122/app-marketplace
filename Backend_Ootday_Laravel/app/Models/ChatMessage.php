<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['thread_id', 'sender_role', 'sender_id', 'message', 'is_read'])]
class ChatMessage extends Model
{
    public function thread()
    {
        return $this->belongsTo(ChatThread::class, 'thread_id');
    }

    public function sender()
    {
        return $this->belongsTo(User::class, 'sender_id');
    }
}
