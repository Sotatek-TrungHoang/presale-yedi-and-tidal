<?php

namespace App\Rules;

use App\Models\Upload;
use Closure;
use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Database\Eloquent\Model;

class UploadRule implements ValidationRule
{
    public function __construct(
        protected ?Model $owner = null
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

        $upload = Upload::query()->find($value);
        if (! $upload) {
            $fail('The :attribute must be a valid document upload.');

            return;
        }

        $owner = $upload->owner;
        if ($this->owner) {
            if ($owner?->isNot($this->owner)) {
                $fail('The :attribute must be a valid document upload.');

                return;
            }
        } else {
            if ($owner) {
                $fail('The :attribute must be a valid document upload.');

                return;
            }
        }
    }
}
