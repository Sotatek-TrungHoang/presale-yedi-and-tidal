<?php

namespace App\Http\Requests\Applicant\VideoVerification;

use App\Models\VideoVerification;
use App\Rules\UploadRule;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Gate;

/**
 * @property VideoVerification $videoVerification
 */
class SubmitVideoVerificationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return Gate::authorize('update', $this->videoVerification)->allowed();
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'upload_id' => ['required', new UploadRule($this->videoVerification)],
        ];
    }
}
