<?php

namespace App\Http\Requests\Applicant\Profile;

use Illuminate\Foundation\Http\FormRequest;

class CreateReferenceRequest extends FormRequest
{
    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {

        return [
            'name' => ['required', 'string'],
            'email' => ['required', 'email', 'distinct'],
            'telephone' => ['nullable', 'string'],
        ];
    }
}
