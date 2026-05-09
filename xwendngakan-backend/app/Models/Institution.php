<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Institution extends Model
{
    protected $fillable = [
        'user_id', 'nku', 'nen', 'nar', 'type', 'country', 'city',
        'web', 'phone', 'email', 'addr', 'desc',
        'lat', 'lng',
        'colleges', 'depts',
        'fee', 'meal', 'uniform', 'books', 'level',
        'kg_fee', 'kg_meal', 'kg_uniform', 'kg_age', 'kg_hours',
        'fb', 'ig', 'tg', 'wa', 'tk', 'yt',
        'logo', 'img', 'video',
        'founded_year', 'students_count',
        'approved',
    ];

    protected $casts = [
        'approved' => 'boolean',
        'lat' => 'double',
        'lng' => 'double',
        'founded_year' => 'integer',
        'students_count' => 'integer',
    ];

    // Map snake_case DB columns to camelCase for Flutter JSON
    public function toArray()
    {
        $array = parent::toArray();
        $array['kgAge'] = $array['kg_age'] ?? '';
        $array['kgHours'] = $array['kg_hours'] ?? '';

        // Ensure file paths start with /storage/ for API consumers
        foreach (['logo', 'img', 'video'] as $key) {
            if (!empty($array[$key]) && !str_starts_with($array[$key], 'http') && !str_starts_with($array[$key], '/storage/')) {
                $array[$key] = '/storage/' . ltrim($array[$key], '/');
            }
        }

        return $array;
    }


    /**
     * Get posts for this institution.
     */
    public function posts(): HasMany
    {
        return $this->hasMany(Post::class);
    }
}
