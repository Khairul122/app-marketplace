<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['user_id', 'title', 'body', 'type', 'is_read'])]
class AppNotification extends Model
{
    protected $table = 'notifications_app';

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
