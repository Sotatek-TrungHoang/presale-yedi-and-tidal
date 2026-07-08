<?php

namespace App\Http\Requests\Advertiser\SignUp;

use App\Http\Controllers\Traits\AdvertiserPortalTrait;
use App\Rules\UploadRule;
use Illuminate\Foundation\Http\FormRequest;

class SubmitPhotographRequest extends FormRequest
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

        return [
            'photograph_id' => ['required', new UploadRule($advertiser)],
        ];
    }
}
