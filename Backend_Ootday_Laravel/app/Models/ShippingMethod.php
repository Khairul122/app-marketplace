<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['name', 'base_cost', 'is_active'])]
class ShippingMethod extends Model
{
    //
}
