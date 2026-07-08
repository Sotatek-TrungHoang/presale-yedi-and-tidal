<?php

namespace App\Models;

use App\Casts\MoneyCast;
use App\Enums\AdvertStatus;
use App\Enums\AdvertType;
use App\Enums\ApplicationStatus;
use App\Enums\PayType;
use Brick\Math\RoundingMode;
use Brick\Money\Money;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\Relations\MorphMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

/**
 * @property ?Application $acceptedApplication
 */
class Advert extends Model implements AuditableContract
{
    use Auditable, HasFactory, SoftDeletes;

    protected $fillable = [
        'advertiser_id',
        'type',
        'status',
        'title',
        'description',
        'address_id',
        'starts_at',
        'ends_at',
        'shift_start_time',
        'shift_end_time',
        'apply_by',
        'day_to_day_active_minutes',
        'advertiser_pay_rate',
        'advertiser_pay_rate_type',
        'applicant_charge_percentage',
        'advertiser_charge_percentage',
        'contact_name',
        'contact_position',
        'contact_email',
        'contact_telephone',
        'marked_as_completed_at',
    ];

    protected function casts(): array
    {
        return [
            'type' => AdvertType::class,
            'status' => AdvertStatus::class,
            'starts_at' => 'datetime',
            'ends_at' => 'datetime',
            'apply_by' => 'datetime',
            'advertiser_pay_rate' => MoneyCast::class,
            'advertiser_pay_rate_type' => PayType::class,
            'applicant_charge_percentage' => 'float',
            'advertiser_charge_percentage' => 'float',
            'marked_as_completed_at' => 'datetime',
        ];
    }

    protected static function booted()
    {
        static::saving(function (self $model) {

            if ($model->type === AdvertType::DayToDay && $model->day_to_day_active_minutes !== null && $model->isDirty('status')) {
                $oldStatus = $model->getOriginal('status');
                $newStatus = $model->status;

                if ($oldStatus === AdvertStatus::PendingApproval && $newStatus === AdvertStatus::Approved) {
                    $model->apply_by = now()->addMinutes($model->day_to_day_active_minutes);
                }
            }
        });
    }

    /** @return BelongsTo<Advertiser, Advert>  */
    public function advertiser()
    {
        return $this->belongsTo(Advertiser::class);
    }

    /** @return HasMany<Application, Advert>  */
    public function applications()
    {
        return $this->hasMany(Application::class);
    }

    /** @return HasOne<Application, Advert>  */
    public function acceptedApplication()
    {
        return $this->applications()->where('status', ApplicationStatus::Accepted)->one();
    }

    /** @return BelongsTo<Address, Advert>  */
    public function address()
    {
        return $this->belongsTo(Address::class);
    }

    /** @return HasOne<Invoice, Advert>  */
    public function invoice()
    {
        return $this->hasOne(Invoice::class);
    }

    /** @return HasOne<Payslip, Advert>  */
    public function payslip()
    {
        return $this->hasOne(Payslip::class);
    }

    /** @return MorphMany<Document, Advert>  */
    public function documents()
    {
        return $this->morphMany(Document::class, 'owner');
    }

    public function shifts()
    {
        return $this->hasMany(Shift::class);
    }

    /**
     * The total amount the advertiser is willing to pay Yedi for the advert
     */
    public function totalAdvertiserPay(): Attribute
    {
        return Attribute::make(
            get: function () {
                $advertiserPayRate = $this->advertiser_pay_rate;

                return match ($this->advertiser_pay_rate_type) {
                    PayType::Hourly => $this->shifts->reduce(fn (Money $carry, Shift $shift) => $carry->plus($advertiserPayRate->multipliedBy($shift->hours, roundingMode: RoundingMode::HALF_UP)), Money::zero('GBP')),
                    PayType::Daily => $advertiserPayRate->multipliedBy($this->shifts()->count(), roundingMode: RoundingMode::HALF_UP),
                };
            }
        )->shouldCache();
    }

    /** The rate at which the advertiser will be charged by Yedi */
    public function advertiserChargeRate(): Attribute
    {
        return Attribute::make(
            get: fn (): Money => $this->advertiser_pay_rate->multipliedBy($this->advertiser_charge_percentage / 100, roundingMode: RoundingMode::HALF_UP)
        )->shouldCache();
    }

    /** The total the advertiser charged by Yedi */
    public function advertiserCharge(): Attribute
    {
        return Attribute::make(
            get: function (): Money {
                $advertiserChargeRate = $this->advertiser_charge_rate;

                return match ($this->advertiser_pay_rate_type) {
                    PayType::Hourly => $this->shifts->reduce(fn (Money $carry, Shift $shift) => $carry->plus($advertiserChargeRate->multipliedBy($shift->hours, roundingMode: RoundingMode::HALF_UP)), Money::zero('GBP')),
                    PayType::Daily => $advertiserChargeRate->multipliedBy($this->shifts()->count(), roundingMode: RoundingMode::HALF_UP),
                };
            }
        )->shouldCache();
    }

    /** The rate at which the applicant will be charged by Yedi  */
    public function applicantChargeRate(): Attribute
    {
        return Attribute::make(
            get: fn (): Money => $this->advertiser_pay_rate->minus($this->advertiser_charge_rate)->multipliedBy($this->applicant_charge_percentage / 100, roundingMode: RoundingMode::HALF_UP)
        )->shouldCache();
    }

    /** The total the applicant is charged by Yedi  */
    public function applicantCharge(): Attribute
    {
        return Attribute::make(
            get: function (): Money {
                $applicantChargeRate = $this->applicant_charge_rate;

                return match ($this->advertiser_pay_rate_type) {
                    PayType::Hourly => $this->shifts->reduce(fn (Money $carry, Shift $shift) => $carry->plus($applicantChargeRate->multipliedBy($shift->hours, roundingMode: RoundingMode::HALF_UP)), Money::zero('GBP')),
                    PayType::Daily => $applicantChargeRate->multipliedBy($this->shifts()->count(), roundingMode: RoundingMode::HALF_UP),
                };
            }
        )->shouldCache();
    }

    /** The total the applicant is charged by Yedi  */
    public function applicantPayRate(): Attribute
    {
        return Attribute::make(
            get: function (): Money {

                $advertiserPayRate = $this->advertiser_pay_rate;
                $advertiserChargeRate = $this->advertiser_charge_rate;
                $applicantChargeRate = $this->applicant_charge_rate;

                return $advertiserPayRate->minus($advertiserChargeRate)->minus($applicantChargeRate);
            }
        )->shouldCache();
    }

    public function applicantPay(): Attribute
    {
        return Attribute::make(
            get: function (): Money {
                $applicantPayRate = $this->applicant_pay_rate;

                return match ($this->advertiser_pay_rate_type) {
                    PayType::Hourly => $this->shifts->reduce(fn (Money $carry, Shift $shift) => $carry->plus($applicantPayRate->multipliedBy($shift->hours, roundingMode: RoundingMode::HALF_UP)), Money::zero('GBP')),
                    PayType::Daily => $applicantPayRate->multipliedBy($this->shifts()->count(), roundingMode: RoundingMode::HALF_UP),
                };
            }
        )->shouldCache();
    }

    public function profit(): Attribute
    {
        return Attribute::make(
            get: fn (): Money => $this->total_advertiser_pay->minus($this->applicant_pay)
        )->shouldCache();
    }
}
