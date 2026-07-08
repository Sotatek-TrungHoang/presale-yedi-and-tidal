<?php

namespace App\Casts\Data;

use Brick\Money\Money;
use Spatie\LaravelData\Casts\Cast;
use Spatie\LaravelData\Support\Creation\CreationContext;
use Spatie\LaravelData\Support\DataProperty;

class MoneyCast implements Cast
{
    public function __construct(
        protected readonly bool $ofMinor = false,
    ) {}

    public function cast(DataProperty $property, mixed $value, array $properties, CreationContext $context): Money
    {

        $amount = $value;
        $currency = 'GBP';

        return $this->ofMinor
            ? Money::ofMinor($amount, $currency)
            : Money::of($amount, $currency);
    }
}
