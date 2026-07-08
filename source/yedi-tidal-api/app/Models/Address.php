<?php

namespace App\Models;

use App\Casts\CountryCast;
use App\Handlers\Addresses\GetAddressCoordinatesHandler;
use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\HasBuilder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\MorphTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Carbon;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

/**
 * @property-read array{name:string, alpha2:string, alpha3:string, numeric:numeric-string, currency:string[]} $country
 */
class Address extends Model implements AuditableContract
{
    use Auditable, HasBuilder, HasFactory, SoftDeletes;

    protected const EXPIRE_MINS = 15;

    protected $fillable = [
        'line_1',
        'line_2',
        'town_city',
        'postcode',
        'country',
        'owner_id',
        'owner_type',
        'latitude',
        'longitude',
    ];

    protected $casts = [
        'expires_at' => 'datetime',
        'country' => CountryCast::class,
        'latitude' => 'float',
        'longitude' => 'float',
    ];

    protected static function booted()
    {
        static::saving(function (self $model) {
            if (! $model->exists || $model->isDirty(['line_1', 'line_2', 'town_city', 'postcode', 'country'])) {
                /** @var GetAddressCoordinatesHandler $handler */
                $handler = app()->make(GetAddressCoordinatesHandler::class);
                $result = $handler->handle($model);

                if ($result) {
                    $model->latitude = $result['latitude'];
                    $model->longitude = $result['longitude'];
                }
            }
        });

        static::creating(function (self $model) {
            if (! $model->expires_at) {
                $model->expires_at = Carbon::now()->addMinutes(self::EXPIRE_MINS);
            }
        });
    }

    public function owner(): MorphTo
    {
        return $this->morphTo();
    }

    public function formatted(): Attribute
    {
        return Attribute::make(
            get: fn (): string => collect([
                $this->line_1,
                $this->line_2,
                $this->town_city,
                $this->postcode,
                $this->country['name'],
            ])->filter()->join(', ')
        )->shouldCache();
    }

    public function components(): Attribute
    {
        return Attribute::make(
            get: fn (): array => array_values(array_filter([
                'line_1' => $this->line_1,
                'line_2' => $this->line_2,
                'town_city' => $this->town_city,
                'postcode' => $this->postcode,
            ]))
        );
    }

    public function isSameAs(self $address): bool
    {
        return $this->formatted === $address->formatted;
    }
}
