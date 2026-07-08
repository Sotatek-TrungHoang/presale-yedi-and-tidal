<?php

namespace App\DTOs\Adverts;

use App\DTOs\Documents\DocumentData;
use App\Enums\AdvertType;
use App\Enums\PayType;
use Brick\Money\Money;
use Illuminate\Support\Carbon;
use Spatie\LaravelData\Data;

class CreateAdvertData extends Data
{
    /**
     * @param  DocumentData[]  $documents
     */
    public function __construct(
        public AdvertType $type,
        public string $title,
        public string $description,
        public Carbon $starts_at,
        public Carbon $ends_at,
        public string $shift_start_time,
        public string $shift_end_time,
        public Money $advertiser_pay_rate,
        public PayType $advertiser_pay_rate_type,
        public ?Carbon $apply_by,
        public ?int $day_to_day_active_minutes,
        public string $contact_name,
        public ?string $contact_position = null,
        public ?string $contact_email = null,
        public ?string $contact_telephone = null,
        public array $documents = [],
    ) {}
}
