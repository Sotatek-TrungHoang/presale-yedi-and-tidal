<?php

namespace App\Http\Requests\Common\Uploads;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Auth;

class UploadFromGoogleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return Auth::user()->isAdvertiser();
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string'],
            'postcode' => ['required', 'string'],
        ];
    }
}
