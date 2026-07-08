<?php

namespace App\Rules;

use App\Models\Address;
use App\Models\Interfaces\ImplementsAddresses;
use Closure;
use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Database\Eloquent\Model;

class AddressRule implements ValidationRule
{
    public function __construct(
        protected (ImplementsAddresses&Model)|null $owner = null
    ) {}

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

        $address = Address::query()->find($value);
        if (! $address) {
            $fail('The :attribute must be a valid address ID.');

            return;
        }

        $addressOwner = $address->owner;
        if ($this->owner) {
            if ($addressOwner?->isNot($this->owner)) {
                $fail('The :attribute must be a valid address ID.');

                return;
            }
        } else {
            if ($addressOwner) {
                $fail('The :attribute must be a valid address ID.');

                return;
            }
        }
    }
}
