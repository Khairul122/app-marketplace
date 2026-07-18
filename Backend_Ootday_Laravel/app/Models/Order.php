<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;

#[Fillable([
    'order_code', 'user_id', 'store_id', 'payment_method_id', 'shipping_method_id',
    'subtotal', 'shipping_cost', 'total_price', 'status', 'ordered_at',
])]
class Order extends Model
{
    public const STATUSES = ['menunggu_pembayaran', 'diproses', 'dikirim', 'selesai', 'dibatalkan'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function store()
    {
        return $this->belongsTo(Store::class);
    }

    public function paymentMethod()
    {
        return $this->belongsTo(PaymentMethod::class);
    }

    public function shippingMethod()
    {
        return $this->belongsTo(ShippingMethod::class);
    }

    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }
}
