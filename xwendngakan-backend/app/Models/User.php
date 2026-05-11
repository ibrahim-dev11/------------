<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'is_admin',
        'is_approved',
        'fcm_token',
        'notifications_enabled',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
        'fcm_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_admin' => 'boolean',
            'is_approved' => 'boolean',
            'notifications_enabled' => 'boolean',
        ];
    }

    /**
     * Get user's favorite institutions.
     */
    public function favorites(): HasMany
    {
        return $this->hasMany(Favorite::class);
    }

    /**
     * Get favorite institutions directly.
     */
    public function favoriteInstitutions(): BelongsToMany
    {
        return $this->belongsToMany(Institution::class, 'favorites')
            ->withTimestamps();
    }

    /**
     * Check if user has favorited an institution.
     */
    public function hasFavorited(int $institutionId): bool
    {
        return $this->favorites()->where('institution_id', $institutionId)->exists();
    }

    /**
     * Get user's reports.
     */
    public function reports(): HasMany
    {
        return $this->hasMany(Report::class);
    }

    /**
     * Get the institution associated with the user.
     */
    public function institution(): \Illuminate\Database\Eloquent\Relations\HasOne
    {
        return $this->hasOne(Institution::class);
    }
}
