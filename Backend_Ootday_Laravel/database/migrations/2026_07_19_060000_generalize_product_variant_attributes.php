<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('product_variants', function (Blueprint $table) {
            $table->string('attribute1_name', 50)->nullable()->after('color');
            $table->string('attribute1_value', 50)->nullable()->after('attribute1_name');
            $table->string('attribute2_name', 50)->nullable()->after('attribute1_value');
            $table->string('attribute2_value', 50)->nullable()->after('attribute2_name');
        });

        DB::table('product_variants')->orderBy('id')->chunk(200, function ($variants) {
            foreach ($variants as $variant) {
                DB::table('product_variants')->where('id', $variant->id)->update([
                    'attribute1_name' => 'Ukuran',
                    'attribute1_value' => $variant->size,
                    'attribute2_name' => filled($variant->color) ? 'Warna' : null,
                    'attribute2_value' => filled($variant->color) ? $variant->color : null,
                ]);
            }
        });

        Schema::table('product_variants', function (Blueprint $table) {
            // MySQL needs a supporting index for the product_id foreign key
            // before `unique_variant` (which currently covers that role) can
            // be dropped, otherwise it errors with "needed in a foreign key
            // constraint".
            $table->index('product_id', 'product_variants_product_id_index');
        });

        Schema::table('product_variants', function (Blueprint $table) {
            $table->dropUnique('unique_variant');
            $table->dropColumn(['size', 'color']);
            $table->unique(['product_id', 'attribute1_value', 'attribute2_value'], 'unique_variant_attributes');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('product_variants', function (Blueprint $table) {
            $table->dropUnique('unique_variant_attributes');
            $table->string('size', 50)->nullable()->after('product_id');
            $table->string('color', 50)->nullable()->after('size');
        });

        DB::table('product_variants')->orderBy('id')->chunk(200, function ($variants) {
            foreach ($variants as $variant) {
                DB::table('product_variants')->where('id', $variant->id)->update([
                    'size' => $variant->attribute1_value,
                    'color' => $variant->attribute2_value,
                ]);
            }
        });

        Schema::table('product_variants', function (Blueprint $table) {
            $table->dropColumn(['attribute1_name', 'attribute1_value', 'attribute2_name', 'attribute2_value']);
            $table->unique(['product_id', 'size', 'color'], 'unique_variant');
        });
    }
};
