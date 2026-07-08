<?php

namespace App\Http\Requests\Common\ChangeEmail;

use Illuminate\Foundation\Http\FormRequest;

class RequestEmailChangeRequest extends FormRequest
{
    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'new_email' => ['required', 'string', 'email', 'unique:users,email'],
        ];
    }

    public function messages()
    {
        return [
            'new_email.unique' => 'This email has already been taken.',
        ];
    }
}
