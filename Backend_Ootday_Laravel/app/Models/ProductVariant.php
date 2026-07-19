<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['product_id', 'size', 'color', 'stock', 'price', 'price_adjustment', 'image_url'])]
class ProductVariant extends Model
{
    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    public function effectivePrice(): float
    {
        if ($this->price !== null) {
            return (float) $this->price;
        }

        return (float) $this->product->price + (float) $this->price_adjustment;
    }
}
