<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Cv extends Model
{
    protected $table = 'cvs';

    protected $fillable = [
        'name',
        'phone',
        'email',
        'city',
        'age',
        'gender',
        'graduation_year',
        'field',
        'education_level',
        'experience',
        'skills',
        'languages',
        'notes',
        'photo',
        'is_reviewed',
    ];

    protected $casts = [
        'is_reviewed' => 'boolean',
        'age' => 'integer',
    ];

    /**
     * Get gender label in Kurdish
     */
    public function getGenderLabelAttribute(): string
    {
        return match($this->gender) {
            'male' => 'نێر',
            'female' => 'مێ',
            'other' => 'تر',
            default => '-',
        };
    }

    /**
     * Map for API response
     */
    public function toArray()
    {
        $array = parent::toArray();
        
        // Ensure photo path starts with /storage/ for API consumers
        if (!empty($array['photo']) && !str_starts_with($array['photo'], 'http') && !str_starts_with($array['photo'], '/storage/')) {
            $array['photo'] = '/storage/' . ltrim($array['photo'], '/');
        }

        // Add gender label
        $array['gender_label'] = $this->gender_label;

        return $array;
    }
}
