<?php

namespace App\Http\Requests\Common\Dropdowns;

use App\Registries\Dropdowns\DropdownRegistry;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class DropdownRequest extends FormRequest
{
    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(DropdownRegistry $dropdownRegistry): array
    {
        return [
            'code' => ['required', 'string', Rule::in($dropdownRegistry->ids())],
            'search' => ['sometimes', 'nullable', 'string'],
            'additional' => ['sometimes', 'nullable', 'array'],
        ];
    }
}
