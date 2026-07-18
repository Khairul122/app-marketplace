<?php

namespace Database\Seeders;

use App\Models\PaymentMethod;
use App\Models\ShippingMethod;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        User::firstOrCreate(
            ['email' => 'admin@ootday.com'],
            ['name' => 'Admin Ootday', 'role' => 'admin', 'password' => Hash::make('admin12345')]
        );

        $paymentMethods = [
            ['name' => 'DANA', 'type' => 'ewallet'],
            ['name' => 'GoPay', 'type' => 'ewallet'],
            ['name' => 'OVO', 'type' => 'ewallet'],
            ['name' => 'BCA Transfer', 'type' => 'bank_transfer'],
            ['name' => 'Mandiri Transfer', 'type' => 'bank_transfer'],
            ['name' => 'COD', 'type' => 'cod'],
        ];

        foreach ($paymentMethods as $method) {
            PaymentMethod::firstOrCreate(['name' => $method['name']], $method + ['is_active' => true]);
        }

        $shippingMethods = [
            ['name' => 'SPX Hemat', 'base_cost' => 10000],
            ['name' => 'SPX Reguler', 'base_cost' => 15000],
            ['name' => 'J&T Express', 'base_cost' => 25000],
        ];

        foreach ($shippingMethods as $method) {
            ShippingMethod::firstOrCreate(['name' => $method['name']], $method + ['is_active' => true]);
        }
    }
}
