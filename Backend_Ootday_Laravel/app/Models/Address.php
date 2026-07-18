<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['user_id', 'receiver_name', 'phone', 'full_address', 'is_main'])]
class Address extends Model
{
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
