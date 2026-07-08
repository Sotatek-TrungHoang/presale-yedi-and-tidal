<?php

namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;
use League\ISO3166\ISO3166;

class CountryRule implements ValidationRule
{
    /**
     * Run the validation rule.
     *
     * @param  \Closure(string): \Illuminate\Translation\PotentiallyTranslatedString  $fail
     */
    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        if ($value === null) {
            return;
        }

        if (! is_string($value)) {
            return;
        }

        try {
            (new ISO3166)->alpha2($value);
        } catch (\Throwable $e) {
            $fail('The :attribute must be a valid ISO 3166-1 alpha-2 country code.');

            return;
        }
    }
}
