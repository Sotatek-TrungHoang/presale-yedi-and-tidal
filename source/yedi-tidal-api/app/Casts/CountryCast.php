<?php

namespace App\Casts;

use Illuminate\Contracts\Database\Eloquent\CastsAttributes;
use Illuminate\Database\Eloquent\Model;
use League\ISO3166\ISO3166;

class CountryCast implements CastsAttributes
{
    /**
     * Cast the given value.
     *
     * @param  array<string, mixed>  $attributes
     * @return array{name:string, alpha2:string, alpha3:string, numeric:numeric-string, currency:string[]}
     */
    public function get(Model $model, string $key, mixed $value, array $attributes): array
    {
        return (new ISO3166)->alpha2($value);
    }

    /**
     * Prepare the given value for storage.
     *
     * @param  array<string, mixed>  $attributes
     */
    public function set(Model $model, string $key, mixed $value, array $attributes): mixed
    {

        if (is_array($value)) {
            return $value['alpha2'];
        }

        return $value;
    }
}
