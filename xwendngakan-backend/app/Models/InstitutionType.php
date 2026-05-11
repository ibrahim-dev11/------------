<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class InstitutionType extends Model
{
    protected static function booted(): void
    {
        static::creating(function (InstitutionType $type) {
            if (empty($type->key)) {
                $base = Str::slug($type->name, '_');
                if (empty($base)) {
                    $base = 'type_' . Str::random(6);
                }
                $key = $base;
                $i = 1;
                while (InstitutionType::where('key', $key)->exists()) {
                    $key = $base . '_' . $i++;
                }
                $type->key = $key;
            }

            if (empty($type->icon)) {
                $type->icon = 'category';
            }
        });
    }

    protected $fillable = [
        'key',
        'name',
        'name_en',
        'name_ar',
        'emoji',
        'icon',
        'sort_order',
        'is_active',
        'has_colleges',
        'has_departments',
    ];

    protected $casts = [
        'is_active'       => 'boolean',
        'sort_order'      => 'integer',
        'has_colleges'    => 'boolean',
        'has_departments' => 'boolean',
    ];

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeOrdered($query)
    {
        return $query->orderBy('sort_order');
    }
}
