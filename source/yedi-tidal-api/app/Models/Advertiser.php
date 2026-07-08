<?php

namespace App\Models;

use App\Enums\AdvertiserComplianceStatus;
use App\Enums\ProfileStatus;
use App\Handlers\Notifications\NotifyAdvertiserHandler;
use App\Models\Interfaces\ImplementsAddresses;
use App\Models\Interfaces\ImplementsUploads;
use App\Models\Traits\HasAddresses;
use App\Models\Traits\HasUploads;
use App\Notifications\Advertiser\AccountActiveNotification;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\MorphMany;
use Illuminate\Database\Eloquent\Relations\MorphOne;
use Illuminate\Database\Eloquent\SoftDeletes;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class Advertiser extends Model implements AuditableContract, ImplementsAddresses, ImplementsUploads
{
    use Auditable, HasAddresses, HasFactory, HasUploads, SoftDeletes;

    protected $fillable = [
        'name',
        'email',
        'telephone',
        'bio',
        'additional_info',
        'compliance_status',
        'profile_status',
        'photograph_id',
        'sign_up_completed_at',
    ];

    protected function casts(): array
    {
        return [
            'compliance_status' => AdvertiserComplianceStatus::class,
            'profile_status' => ProfileStatus::class,
            'sign_up_completed_at' => 'datetime',
        ];
    }

    protected static function booted()
    {
        static::updated(function (self $model) {
            if ($model->isDirty('profile_status') && $model->profile_status === ProfileStatus::Active) {
                /** @var NotifyAdvertiserHandler $notifyAdvertiserHandler */
                $notifyAdvertiserHandler = app()->make(NotifyAdvertiserHandler::class);
                $notifyAdvertiserHandler->handle($model, new AccountActiveNotification);
            }
        });
    }

    /** @return MorphOne<User, Advertiser>  */
    public function user()
    {
        return $this->morphOne(User::class, 'userable');
    }

    /** @return HasMany<Advert, Advertiser>  */
    public function adverts()
    {
        return $this->hasMany(Advert::class);
    }

    /** @return BelongsTo<Address, Advertiser>  */
    public function address()
    {
        return $this->belongsTo(Address::class);
    }

    /** @return BelongsTo<Upload, Advertiser>  */
    public function photograph()
    {
        return $this->belongsTo(Upload::class, 'photograph_id');
    }

    /** @return MorphMany<Contract, Advertiser>  */
    public function contracts()
    {
        return $this->morphMany(Contract::class, 'owner');
    }

    /** @return HasMany<HeartedApplicant, Advertiser>  */
    public function heartedApplicants()
    {
        return $this->hasMany(HeartedApplicant::class);
    }
}
