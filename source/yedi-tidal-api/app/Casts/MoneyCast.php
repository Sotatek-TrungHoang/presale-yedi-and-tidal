<?php

namespace App\Casts;

use Brick\Money\Money as BrickMoney;
use Exception;
use Illuminate\Contracts\Database\Eloquent\CastsAttributes;
use Illuminate\Database\Eloquent\Model;

// https://andy.cowan.me.uk/handling-money-types-in-laravel
class MoneyCast implements CastsAttributes
{
    /**
     * Cast the given value.
     *
     * @param  array<string, mixed>  $attributes
     */
    public function get(Model $model, string $key, mixed $value, array $attributes): BrickMoney
    {
        $fields = json_decode($value);

        return BrickMoney::ofMinor($fields->amount, $fields->currency);
    }

    /**
     * Prepare the given value for storage.
     *
     * @param  array<string, mixed>  $attributes
     */
    public function set(Model $model, string $key, mixed $value, array $attributes): mixed
    {

        if (! $value instanceof BrickMoney) {
            throw new Exception('Invalid money type provided');
        }

        return json_encode([
            'amount' => $value->getMinorAmount(),
            'currency' => $value->getCurrency()->getCurrencyCode(),
        ]);
    }
}
