<?php

namespace App\Http\Requests\Applicant\SignUp;

use App\Enums\ApplicantQualification;
use App\Handlers\Settings\SettingsResolver;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Enum;

class SubmitQualificationsRequest extends FormRequest
{
    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(SettingsResolver $settingsResolver): array
    {
        $settings = $settingsResolver->resolve();

        $rules = [
            'qualification' => ['required', new Enum(ApplicantQualification::class)],
        ];

        if ($settings->require_teacher_number) {
            $rules['teacher_number'] = ['required', 'string'];
        }

        return $rules;
    }
}
