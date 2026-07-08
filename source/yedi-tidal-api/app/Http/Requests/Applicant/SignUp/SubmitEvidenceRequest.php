<?php

namespace App\Http\Requests\Applicant\SignUp;

use App\Http\Controllers\Traits\ApplicantPortalTrait;
use App\Models\RequiredEvidence;
use App\Rules\UploadRule;
use Illuminate\Foundation\Http\FormRequest;

/**
 * @property RequiredEvidence $requiredEvidence
 */
class SubmitEvidenceRequest extends FormRequest
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
            'upload_id' => ['required', new UploadRule($applicant)],
        ];
    }
}
