<?php

namespace App\Http\Requests\Advertiser\Profile;

use App\Http\Controllers\Traits\AdvertiserPortalTrait;
use App\Rules\UploadRule;
use Illuminate\Foundation\Http\FormRequest;

class UpdateProfileRequest extends FormRequest
{
    use AdvertiserPortalTrait;

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        $advertiser = $this->getAdvertiser();
        $rules = [
            'name' => ['required', 'string'],
            'email' => ['required', 'string', 'email'],
            'telephone' => ['required', 'string'],
            'bio' => ['required', 'string'],
            'additional_info' => ['nullable', 'string'],
            'photograph_id' => ['required', new UploadRule($advertiser)],
        ];

        return $rules;
    }
}
