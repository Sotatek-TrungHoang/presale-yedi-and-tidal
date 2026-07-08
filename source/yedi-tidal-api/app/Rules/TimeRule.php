<?php

namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Support\Str;

class TimeRule implements ValidationRule
{
    /**
     * Run the validation rule.
     *
     * @param  \Closure(string): \Illuminate\Translation\PotentiallyTranslatedString  $fail
     */
    public function validate(string $attribute, mixed $value, Closure $fail): void
    {

        $message = 'The :attribute must be a valid time.';
        $regex = "/\d\d:\d\d/";
        if (! preg_match($regex, $value)) {
            $fail($message);

            return;
        }

        if (strlen($value) !== 5) {
            $fail($message);

            return;
        }

        $hour = (int) (string) Str::of($value)->substr(0, 2);
        $mins = (int) (string) Str::of($value)->substr(3, 2);

        if ($hour > 23) {
            $fail($message);

            return;
        }

        if ($mins > 59) {
            $fail($message);

            return;
        }

    }
}
