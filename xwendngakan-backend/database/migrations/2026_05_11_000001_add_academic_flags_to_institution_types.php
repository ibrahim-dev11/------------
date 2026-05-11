<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('institution_types', function (Blueprint $table) {
            $table->boolean('has_colleges')->default(false)->after('is_active');
            $table->boolean('has_departments')->default(false)->after('has_colleges');
        });

        // Universities — show colleges AND departments
        DB::table('institution_types')
            ->whereIn('key', ['gov', 'priv', 'eve_uni'])
            ->update(['has_colleges' => true, 'has_departments' => true]);

        // Institutes — show departments only (no colleges)
        DB::table('institution_types')
            ->whereIn('key', ['inst5', 'inst2', 'eve_inst'])
            ->update(['has_colleges' => false, 'has_departments' => true]);

        // Schools, KG, DC, language centers, etc — no academic fields
        // (default false already, no update needed)
    }

    public function down(): void
    {
        Schema::table('institution_types', function (Blueprint $table) {
            $table->dropColumn(['has_colleges', 'has_departments']);
        });
    }
};
