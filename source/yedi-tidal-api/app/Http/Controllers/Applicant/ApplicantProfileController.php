<?php

namespace App\Http\Controllers\Applicant;

use App\Enums\ApplicantComplianceStatus;
use App\Handlers\Settings\SettingsResolver;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Traits\ApplicantPortalTrait;
use App\Http\Requests\Applicant\Profile\UpdateComplianceRequest;
use App\Http\Requests\Applicant\Profile\UpdateEvidenceRequest;
use App\Http\Requests\Applicant\Profile\UpdateProfileRequest;
use App\Http\Requests\Applicant\Profile\UpdateQualificationsRequest;
use App\Http\Requests\Applicant\Profile\UpdateRightToWorkDeclarationRequest;
use App\Http\Requests\Common\Profile\UpdateAddressRequest;
use App\Models\Address;
use App\Models\Applicant;
use App\Models\ApplicantEvidence;
use App\Models\Declaration;
use App\Models\DeclarationAgreement;
use App\Models\RequiredEvidence;
use App\Models\Upload;
use App\Models\User;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\DB;

class ApplicantProfileController extends Controller
{
    use ApplicantPortalTrait;

    public function __construct(
        protected SettingsResolver $settingsResolver
    ) {
        //
    }

    public function index()
    {
        // this will populate the applicant's home screen blocks on the app.
        // profile, compliance, address, and Qualifications will always be present
        // so don't need to be sent back here.

        $applicant = $this->getApplicant();
        $settings = $this->settingsResolver->resolve();
        $referencesRequired = $settings->references_required;

        $blocks = collect();

        if ($referencesRequired > 0) {
            $blocks->push([
                'type' => 'references',
                'title' => 'References',
                'completed' => $applicant->references()->count() >= $referencesRequired,
            ]);
        }

        $requiredEvidenceRecords = RequiredEvidence::query()->where('required', 1)->orderBy('title')->get();
        foreach ($requiredEvidenceRecords as $requiredEvidence) {
            $blocks->push([
                'type' => 'evidence',
                'title' => $requiredEvidence->title,
                'evidence_id' => $requiredEvidence->id,
                'completed' => $applicant->applicantEvidence()->where('required_evidence_id', $requiredEvidence->id)->exists(),
            ]);
        }

        $declarations = Declaration::query()->where('required', 1)->orderBy('title')->get();
        foreach ($declarations as $declaration) {
            $blocks->push([
                'type' => 'declaration',
                'title' => $declaration->title,
                'declaration_id' => $declaration->id,
                'completed' => $applicant->declarationAgreements()->where('declaration_id', $declaration->id)->exists(),
            ]);
        }

        // RTW declaration will technically always be there, but we want to put
        // it at the bottom of the list.
        $blocks->push([
            'type' => 'rtw_declaration',
            'title' => 'Right to Work Dec',
            'completed' => $applicant->rightToWorkDeclaration()->exists(),
        ]);

        return $this->stdSuccess(data: $blocks);
    }

    private function needToResetCompliance(Applicant $applicant, ?User $user = null)
    {

        if ($applicant->compliance_status === ApplicantComplianceStatus::PendingApproval) {
            return false;
        }

        if ($applicant->isDirty(['address_id', 'photograph_id', 'evidence_of_id_id', 'teacher_number', 'qualification'])) {
            return true;
        }

        if ($user && $user->isDirty(['title', 'first_name', 'last_name', 'date_of_birth', 'telephone'])) {
            return true;
        }

        return false;
    }

    public function updateProfile(UpdateProfileRequest $request)
    {
        $validData = $request->validated();
        $applicant = $this->getApplicant();
        $user = $applicant->user;

        try {
            DB::beginTransaction();

            $user->fill(Arr::except($validData, ['type_of_work_id', 'job_role_id']));
            $applicant->fill(Arr::only($validData, ['type_of_work_id', 'job_role_id']));

            if ($this->needToResetCompliance($applicant, $user)) {
                $applicant->compliance_status = ApplicantComplianceStatus::PendingApproval;
            }

            $user->save();
            $applicant->save();

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        return $this->stdSuccess(message: 'Profile updated successfully');
    }

    public function updateCompliance(UpdateComplianceRequest $request)
    {

        $applicant = $this->getApplicant();
        $validData = $request->validated();

        $photograph = Upload::query()->findOrFail($validData['photograph_id']);
        $evidenceOfId = Upload::query()->findOrFail($validData['evidence_of_id_id']);
        // $videoVerification = VideoVerification::query()->findOrFail($validData['video_verification_id']);

        try {
            DB::beginTransaction();

            $applicant->photograph()->associate($photograph);
            $applicant->evidenceOfId()->associate($evidenceOfId);
            // $applicant->videoVerification()->associate($videoVerification);

            if ($this->needToResetCompliance($applicant)) {
                $applicant->compliance_status = ApplicantComplianceStatus::PendingApproval;
            }

            $applicant->save();

            $photograph->owner()->associate($applicant)->save();
            $evidenceOfId->owner()->associate($applicant)->save();

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        return $this->stdSuccess(message: 'Compliance updated successfully');
    }

    public function updateAddress(UpdateAddressRequest $request)
    {
        $validData = $request->validated();
        $applicant = $this->getApplicant();

        $existingAddress = $applicant->address;
        $address = new Address($validData);
        $address->owner()->associate($applicant);

        if (! $existingAddress || ! $existingAddress->isSameAs($address)) {
            try {
                DB::beginTransaction();
                $address->save();

                $applicant->compliance_status = ApplicantComplianceStatus::PendingApproval;
                $applicant->address()->associate($address)->save();

                DB::commit();
            } catch (\Throwable $th) {
                DB::rollBack();
                throw $th;
            }
        }

        return $this->stdSuccess(message: 'Address updated successfully');
    }

    public function updateQualifications(UpdateQualificationsRequest $request)
    {
        $validData = $request->validated();
        $applicant = $this->getApplicant();

        try {
            DB::beginTransaction();

            $applicant->fill($validData);
            if ($this->needToResetCompliance($applicant)) {
                $applicant->compliance_status = ApplicantComplianceStatus::PendingApproval;
            }
            $applicant->save();

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        return $this->stdSuccess(message: 'Qualifications updated successfully');
    }

    public function updateEvidence(UpdateEvidenceRequest $request, RequiredEvidence $requiredEvidence)
    {

        $applicant = $this->getApplicant();
        $validData = $request->validated();

        $upload = Upload::query()->findOrFail($validData['upload_id']);
        /** @var ApplicantEvidence|null $existing */
        $existing = $applicant->applicantEvidence()->where('required_evidence_id', $requiredEvidence->id)->first();

        if ($existing?->upload_id === $upload->id) {
            return $this->stdSuccess(message: 'Evidence updated successfully');
        }

        try {
            DB::beginTransaction();

            if ($existing) {
                $existing->upload()->associate($upload)->save();
                $applicant->compliance_status = ApplicantComplianceStatus::PendingApproval;
                $applicant->save();
            } else {
                $evidence = new ApplicantEvidence;
                $evidence->applicant()->associate($applicant);
                $evidence->requiredEvidence()->associate($requiredEvidence);
                $evidence->upload()->associate($upload);
                $evidence->save();
            }

            $upload->owner()->associate($applicant)->save();

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        return $this->stdSuccess(message: 'Evidence updated successfully');
    }

    public function agreeToDeclaration(Declaration $declaration)
    {

        $applicant = $this->getApplicant();

        /** @var DeclarationAgreement|null $existing */
        $existing = $applicant->declarationAgreements()->where('declaration_id', $declaration->id)->first();

        if ($existing) {
            $existing->touch();
        } else {
            $existing = new DeclarationAgreement;
            $existing->declaration()->associate($declaration);
            $existing->applicant()->associate($applicant);
            $existing->save();
        }

        return $this->stdSuccess(message: 'Declaration agreed to successfully');
    }

    public function updateRightToWorkDeclaration(UpdateRightToWorkDeclarationRequest $request)
    {
        $applicant = $this->getApplicant();
        $validData = $request->validated();

        $existing = $applicant->rightToWorkDeclaration;

        try {
            DB::beginTransaction();

            if ($existing) {
                $existing->fill($validData);

                if ($existing->isDirty()) {
                    $applicant->compliance_status = ApplicantComplianceStatus::PendingApproval;
                    $applicant->save();
                }

                $existing->save();
            } else {
                $applicant->rightToWorkDeclaration()->create($validData);
            }

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        return $this->stdSuccess(message: 'Right to work declaration updated');
    }
}
