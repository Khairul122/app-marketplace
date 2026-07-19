<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

/**
 * Gambar yang diunggah sebelumnya disimpan sebagai URL absolut yang
 * membekukan `APP_URL` saat itu (mis. http://127.0.0.1:8000/storage/...),
 * sehingga tidak bisa diakses dari device/emulator/tunnel lain. Migration
 * ini mengubahnya jadi path relatif (/storage/...) supaya klien selalu
 * resolve ke host yang sedang dipakai saat ini.
 */
return new class extends Migration
{
    private const TABLES = [
        'product_images' => 'image_url',
        'product_variants' => 'image_url',
        'stores' => 'photo_url',
    ];

    public function up(): void
    {
        foreach (self::TABLES as $table => $column) {
            DB::table($table)->whereNotNull($column)->where($column, 'like', 'http%')->orderBy('id')->chunkById(200, function ($rows) use ($table, $column) {
                foreach ($rows as $row) {
                    $relative = preg_replace('#^https?://[^/]+(/storage/.*)$#', '$1', $row->$column);
                    if ($relative !== $row->$column) {
                        DB::table($table)->where('id', $row->id)->update([$column => $relative]);
                    }
                }
            });
        }
    }

    public function down(): void
    {
        // Tidak ada rollback: URL absolut lama tidak berguna untuk dipulihkan
        // (host asalnya sudah tidak relevan).
    }
};
