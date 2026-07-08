<?php

namespace App\Http\Requests\Common\ChangePassword;

use App\Models\User;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\Validator;

class ChangePasswordRequest extends FormRequest
{
    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'current_password' => ['required', 'string'],
            'password' => ['required', 'string', Password::default()],
            'password_confirmation' => ['required', 'string', 'same:password'],
        ];
    }

    /**
     * Get the "after" validation callables for the request.
     */
    public function after(): array
    {
        return [
            function (Validator $validator) {
                $currentPassword = $this->input('current_password');
                if (! empty($currentPassword)) {

                    /** @var User $user */
                    $user = $this->user();

                    if (! Hash::check($currentPassword, $user->password)) {
                        $validator->errors()->add('current_password', 'The provided password does not match your current password.');
                    }
                }
            },
        ];
    }
}
