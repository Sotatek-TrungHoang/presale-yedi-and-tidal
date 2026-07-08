<?php

namespace App\Http\Resources\Common;

use App\Http\Resources\Applicants\Declarations\DeclarationAgreementCollection;
use App\Http\Resources\Applicants\Evidence\ApplicantEvidenceCollection;
use App\Http\Resources\Applicants\JobRoles\JobRoleResource;
use App\Http\Resources\Applicants\References\ReferenceCollection;
use App\Http\Resources\Applicants\RightToWorkDeclarations\RightToWorkDeclarationResource;
use App\Http\Resources\Applicants\TypesOfWork\TypeOfWorkResource;
use App\Http\Resources\Applicants\VideoVerifications\VideoVerificationResource;
use App\Http\Resources\Common\Addresses\AddressResource;
use App\Http\Resources\Common\Uploads\UploadResource;
use App\Models\Advertiser;
use App\Models\Applicant;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin User
 *
 * @property User $resource
 */
class AuthUserResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $userable = $this->userable;

        return [
            'id' => $this->id,
            'type' => $this->type->value,
            'title' => $this->title->value,
            'title_label' => $this->title->label(),
            'first_name' => $this->first_name,
            'last_name' => $this->last_name,
            'email' => $this->email,
            'telephone' => $this->telephone,
            'date_of_birth' => $this->date_of_birth,
            'created_at' => $this->created_at,
            $this->mergeWhen($userable instanceof Applicant, fn () => [
                'applicant' => [
                    'id' => $userable->id,
                    'compliance_status' => $userable->compliance_status->value,
                    'compliance_status_label' => $userable->compliance_status->getLabel(),
                    'profile_status' => $userable->profile_status->value,
                    'profile_status_label' => $userable->profile_status->getLabel(),
                    'qualification' => $userable->qualification?->value,
                    'qualification_label' => $userable->qualification?->label(),

                    'type_of_work' => new TypeOfWorkResource($userable->typeOfWork),
                    'job_role' => new JobRoleResource($userable->jobRole),

                    'rating' => $userable->rating,
                    'teacher_number' => $userable->teacher_number,
                    'address' => new AddressResource($userable->address),
                    'photograph' => new UploadResource($userable->photograph),
                    'evidence_of_id' => new UploadResource($userable->evidenceOfId),
                    'video_verification' => new VideoVerificationResource($userable->videoVerification),
                    'applicant_evidence' => new ApplicantEvidenceCollection($userable->applicantEvidence),
                    'references' => new ReferenceCollection($userable->references),
                    'declaration_agreements' => new DeclarationAgreementCollection($userable->declarationAgreements),
                    'right_to_work_declaration' => new RightToWorkDeclarationResource($userable->rightToWorkDeclaration),
                    'sign_up_completed_at' => $userable->sign_up_completed_at,
                ],
            ]),
            $this->mergeWhen($userable instanceof Advertiser, fn () => [
                'advertiser' => [
                    'id' => $userable->id,
                    'name' => $userable->name,
                    'email' => $userable->email,
                    'telephone' => $userable->telephone,
                    'bio' => $userable->bio,
                    'additional_info' => $userable->additional_info,
                    'compliance_status' => $userable->compliance_status->value,
                    'compliance_status_label' => $userable->compliance_status->getLabel(),
                    'profile_status' => $userable->profile_status->value,
                    'profile_status_label' => $userable->profile_status->getLabel(),
                    'address' => new AddressResource($userable->address),
                    'photograph' => new UploadResource($userable->photograph),
                    'sign_up_completed_at' => $userable->sign_up_completed_at,
                ],
            ]),
        ];
    }
}
