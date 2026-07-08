<?php

namespace App\Http\Requests\Applicant\Profile;

use App\Enums\UserTitle;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Enum;

class UpdateProfileRequest extends FormRequest
{
    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        $rules = [
            'title' => ['required', 'string', new Enum(UserTitle::class)],
            'first_name' => ['required', 'string'],
            'last_name' => ['required', 'string'],
            'date_of_birth' => ['sometimes', 'nullable', 'date_format:Y-m-d'],
            'telephone' => ['required', 'string'],
            'type_of_work_id' => ['sometimes', 'required', Rule::exists('types_of_work', 'id')],
            'job_role_id' => ['sometimes', 'required', Rule::exists('job_roles', 'id')],
        ];

        return $rules;
    }
}
