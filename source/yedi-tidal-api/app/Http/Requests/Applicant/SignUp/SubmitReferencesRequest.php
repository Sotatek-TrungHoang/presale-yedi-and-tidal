<?php

namespace App\Http\Requests\Applicant\SignUp;

use App\Handlers\Settings\SettingsResolver;
use Illuminate\Foundation\Http\FormRequest;

class SubmitReferencesRequest extends FormRequest
{
    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(SettingsResolver $settingsResolver): array
    {

        $settings = $settingsResolver->resolve();

        return [
            'references' => ['required', 'array', 'size:'.$settings->references_required],
            'references.*.name' => ['required', 'string'],
            'references.*.email' => ['required', 'email', 'distinct'],
            'references.*.telephone' => ['nullable', 'string'],
        ];
    }

    public function attributes()
    {
        return [
            'references' => 'references',
            'references.*.name' => 'name',
            'references.*.email' => 'email',
            'references.*.telephone' => 'telephone',
        ];
    }
}
