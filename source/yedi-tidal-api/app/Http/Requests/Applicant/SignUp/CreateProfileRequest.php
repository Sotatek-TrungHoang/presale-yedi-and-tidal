<?php

namespace App\Http\Requests\Applicant\SignUp;

use App\Enums\UserTitle;
use App\Models\User;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Enum;
use Illuminate\Validation\Rules\Password;

class CreateProfileRequest extends FormRequest
{
    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {

        /** @var User|null $user */
        $user = auth('sanctum')->user();

        $rules = [
            'title' => ['required', 'string', new Enum(UserTitle::class)],
            'first_name' => ['required', 'string'],
            'last_name' => ['required', 'string'],
            'date_of_birth' => ['sometimes', 'nullable', 'date_format:Y-m-d'],
            'telephone' => ['required', 'string'],
            'type_of_work_id' => ['sometimes', 'required', Rule::exists('types_of_work', 'id')],
            'job_role_id' => ['sometimes', 'required', Rule::exists('job_roles', 'id')],
        ];

        if (! $user) {
            $rules['email'] = ['required', 'email', Rule::unique('users', 'email')->ignore($user?->id)];
            $rules['password'] = ['required', 'string', Password::default()];
            $rules['password_confirmation'] = ['required', 'string', 'same:password'];
        }

        return $rules;
    }
}
