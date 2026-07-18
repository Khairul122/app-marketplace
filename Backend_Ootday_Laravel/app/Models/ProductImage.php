<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['product_id', 'image_url', 'is_primary', 'sort_order'])]
class ProductImage extends Model
{
    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
