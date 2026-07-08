<?php

namespace App\Http\Requests\Public;

use App\Enums\ReferenceRating;
use App\Enums\ReferenceStatus;
use App\Models\Reference;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Enum;

/**
 * @property Reference $reference
 */
class CompleteReferenceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->reference->status === ReferenceStatus::SentToReferee;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {

        $rules = [
            'job_title' => ['required', 'string', 'max:255'],
            'employment_start_date' => ['required', 'date'],
            'employment_end_date' => ['required', 'date', 'after_or_equal:employment_start_date'],
            'advertiser_name' => ['required', 'string', 'max:255'],
            'referee_name' => ['required', 'string', 'max:255'],
            'referee_job_title' => ['required', 'string', 'max:255'],
            'relationship_to_applicant' => ['required', 'string', 'max:255'],
            'how_long_has_known_applicant' => ['required', 'string', 'max:255'],
            'comments' => ['required', 'string'],
            'any_disciplinary_procedures' => ['required', 'boolean'],
            'was_dismissed' => ['required', 'boolean'],
            'would_reemploy' => ['required', 'boolean'],
            'not_suitable_to_work_with_under_18s' => ['required', 'boolean'],
            'may_share_with_new_employers' => ['required', 'boolean'],
            'signature_name' => ['required', 'string', 'max:255'],
            'signature' => ['required', 'string'],
        ];

        if (config('app.configuration') === 'yedi') {

            $rules['curriculum_knowledge'] = ['required', new Enum(ReferenceRating::class)];
            $rules['ability_to_support_groups'] = ['required', new Enum(ReferenceRating::class)];
            $rules['ability_to_support_on_1_1_basis'] = ['required', new Enum(ReferenceRating::class)];
            $rules['relationships_with_colleagues'] = ['required', new Enum(ReferenceRating::class)];
            $rules['rapport_with_students'] = ['required', new Enum(ReferenceRating::class)];
            $rules['pupil_management'] = ['required', new Enum(ReferenceRating::class)];
            $rules['communication_and_attitude'] = ['required', new Enum(ReferenceRating::class)];
            $rules['reliability_and_punctuality'] = ['required', new Enum(ReferenceRating::class)];
            $rules['additional_comments'] = ['nullable', 'string'];
        }

        if ($this->input('would_reemploy') === '0') {
            $rules['would_reemploy_reason'] = ['required', 'string'];
        }

        return $rules;
    }
}
