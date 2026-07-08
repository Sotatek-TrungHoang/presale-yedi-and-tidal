<?php

namespace App\Http\Requests\Common\ChangeEmail;

use Illuminate\Foundation\Http\FormRequest;

class VerifyEmailChangeCodeRequest extends FormRequest
{
    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'new_email' => ['required', 'string', 'email'],
            'code' => ['required', 'string', 'size:6'],
        ];
    }

    public function attributes()
    {
        return [
            'code' => 'verification code',
        ];
    }
}
