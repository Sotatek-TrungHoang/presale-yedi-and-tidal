<?php

namespace App\Http\Requests\Advertiser\Adverts;

use App\Enums\AdvertType;
use App\Enums\PayType;
use App\Models\Advert;
use App\Rules\TimeRule;
use App\Rules\UploadRule;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Gate;
use Illuminate\Validation\Rules\Enum;

class CreateAdvertRequest extends FormRequest
{
    public function authorize(): bool
    {
        return Gate::authorize('create', Advert::class)->allowed();
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        $rules = [
            'type' => ['required', new Enum(AdvertType::class)],
            'title' => ['required', 'string'],
            'description' => ['required', 'string'],
            'starts_at' => ['required', 'date', 'before_or_equal:ends_at', 'after:today'],
            'ends_at' => ['required', 'date', 'after_or_equal:starts_at'],
            'shift_start_time' => ['required', 'string', new TimeRule],
            'shift_end_time' => ['required', 'string', new TimeRule],
            'advertiser_pay_rate' => ['required', 'numeric', 'decimal:0,2', 'min:0'],
            'advertiser_pay_rate_type' => ['required', new Enum(PayType::class)],

            'contact_name' => ['required', 'string'],
            'contact_position' => ['present', 'nullable', 'string'],
            'contact_email' => ['required_without:contact_telephone', 'nullable', 'string', 'email'],
            'contact_telephone' => ['required_without:contact_email', 'nullable', 'string'],

            'documents' => ['array', 'min:0'],
            'documents.*' => ['array'],
            'documents.*.title' => ['required', 'string'],
            'documents.*.upload_id' => ['required', new UploadRule],
        ];

        if ($this->input('type') === AdvertType::DayToDay->value) {
            $rules['day_to_day_active_minutes'] = ['required', 'integer', 'min:1'];
        }

        if ($this->input('type') === AdvertType::LongTerm->value) {
            $rules['apply_by'] = ['required', 'date', 'before:starts_at'];
        }

        return $rules;
    }
}
