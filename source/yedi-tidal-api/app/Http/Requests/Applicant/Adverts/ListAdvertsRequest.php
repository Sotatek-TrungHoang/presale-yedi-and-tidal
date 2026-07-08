<?php

namespace App\Http\Requests\Applicant\Adverts;

use App\Enums\AdvertType;
use App\Models\Advert;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\Rules\Enum;

class ListAdvertsRequest extends FormRequest
{
    public function authorize(): bool
    {
        return Gate::authorize('viewAny', Advert::class)->allowed();
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'type' => ['required', new Enum(AdvertType::class)],
        ];
    }
}
