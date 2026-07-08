<?php

namespace App\Http\Requests\Applicant\Profile;

use App\Http\Controllers\Traits\ApplicantPortalTrait;
use App\Rules\UploadRule;
use Illuminate\Foundation\Http\FormRequest;

class UpdateComplianceRequest extends FormRequest
{
    use ApplicantPortalTrait;

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        $applicant = $this->getApplicant();

        return [
            'photograph_id' => ['required', new UploadRule($applicant)],
            'evidence_of_id_id' => ['required', new UploadRule($applicant)],
            // 'video_verification_id' => ['required', Rule::exists('video_verifications', 'id')->where('applicant_id', $applicant->id)->whereNotNull('upload_id')],
        ];
    }
}
