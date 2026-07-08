<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;

use App\Enums\UserTitle;
use App\Enums\UserType;
use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\MorphTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class User extends Authenticatable implements AuditableContract, FilamentUser
{
    use Auditable, HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'type',
        'first_name',
        'last_name',
        'name',
        'email',
        'new_email',
        'new_email_code',
        'new_email_code_expires_at',
        'password',
        'title',
        'date_of_birth',
        'telephone',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'type' => UserType::class,
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'title' => UserTitle::class,
            'date_of_birth' => 'date',
            'new_email_code_expires_at' => 'datetime',
            'is_super_admin' => 'bool',
        ];
    }

    protected static function booted()
    {
        static::saving(function (self $model) {
            if ($model->isDirty(['first_name', 'last_name'])) {
                $model->name = sprintf('%s %s', $model->first_name, $model->last_name);
            }
        });
    }

    /** @return MorphTo<Advertiser|Applicant, User>  */
    public function userable()
    {
        return $this->morphTo();
    }

    /** @return HasMany<DeviceToken, User>  */
    public function deviceTokens()
    {
        return $this->hasMany(DeviceToken::class);
    }

    public function canAccessPanel(Panel $panel): bool
    {
        return $this->type === UserType::Admin;
    }

    public function isAdmin()
    {
        return $this->type === UserType::Admin;
    }

    public function isSuperAdmin()
    {
        return $this->type === UserType::Admin && $this->is_super_admin;
    }

    public function isAdvertiser()
    {
        return $this->type === UserType::Advertiser;
    }

    public function isApplicant()
    {
        return $this->type === UserType::Applicant;
    }
}
