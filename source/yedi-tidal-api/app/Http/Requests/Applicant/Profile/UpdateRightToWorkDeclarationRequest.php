<?php

namespace App\Http\Requests\Applicant\Profile;

use Illuminate\Foundation\Http\FormRequest;

class UpdateRightToWorkDeclarationRequest extends FormRequest
{
    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'right_to_work_uk' => ['required', 'boolean'],
            'require_visa_to_work_uk' => ['required', 'boolean'],
            'lived_or_worked_outside_uk_6_months' => ['required', 'boolean'],
            'has_criminal_convictions_or_prosecutions_pending' => ['required', 'boolean'],
        ];
    }
}
