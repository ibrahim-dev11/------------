<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Teacher extends Model
{
    protected $fillable = [
        'name',
        'phone',
        'type',
        'city',
        'experience_years',
        'hourly_rate',
        'subject',
        'about',
        'video_url',
        'photo',
        'subject_photo',
        'is_approved',
    ];

    protected $casts = [
        'is_approved' => 'boolean',
        'experience_years' => 'integer',
        'hourly_rate' => 'integer',
    ];

    /**
     * Get type label in Kurdish
     */
    public function getTypeLabelAttribute(): string
    {
        return match($this->type) {
            'university' => 'ماموستای زانکۆ',
            'school' => 'ماموستای قوتابخانە',
            default => '-',
        };
    }

    /**
     * Scope: filter by type
     */
    public function scopeOfType($query, string $type)
    {
        return $query->where('type', $type);
    }

    /**
     * Map for API response
     */
    public function toArray()
    {
        $array = parent::toArray();

        // Ensure photo paths start with /storage/ for API consumers
        if (!empty($array['photo']) && !str_starts_with($array['photo'], 'http') && !str_starts_with($array['photo'], '/storage/')) {
            $array['photo'] = '/storage/' . ltrim($array['photo'], '/');
        }
        if (!empty($array['subject_photo']) && !str_starts_with($array['subject_photo'], 'http') && !str_starts_with($array['subject_photo'], '/storage/')) {
            $array['subject_photo'] = '/storage/' . ltrim($array['subject_photo'], '/');
        }

        $array['type_label'] = $this->type_label;

        return $array;
    }
}
