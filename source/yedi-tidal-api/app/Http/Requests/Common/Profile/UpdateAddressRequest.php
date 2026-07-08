<?php

namespace App\Http\Requests\Common\Profile;

use App\Rules\CountryRule;
use Illuminate\Foundation\Http\FormRequest;

class UpdateAddressRequest extends FormRequest
{
    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'line_1' => ['required', 'string'],
            'line_2' => ['sometimes', 'nullable', 'string'],
            'town_city' => ['required', 'string'],
            'postcode' => ['required', 'string'],
            'country' => ['required', 'string', new CountryRule],
        ];
    }
}
