<?php

namespace App\Http\Controllers\Applicant;

use App\Enums\ApplicantComplianceStatus;
use App\Enums\ProfileStatus;
use App\Enums\UserType;
use App\Handlers\Applicants\SignUp\ApplicantSignUpPagesHandler;
use App\Handlers\Notifications\NotifyAdminsHandler;
use App\Handlers\References\RequestReferenceHandler;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Traits\ApplicantPortalTrait;
use App\Http\Requests\Applicant\SignUp\CreateProfileRequest;
use App\Http\Requests\Applicant\SignUp\SubmitAddressRequest;
use App\Http\Requests\Applicant\SignUp\SubmitComplianceRequest;
use App\Http\Requests\Applicant\SignUp\SubmitEvidenceRequest;
use App\Http\Requests\Applicant\SignUp\SubmitQualificationsRequest;
use App\Http\Requests\Applicant\SignUp\SubmitReferencesRequest;
use App\Http\Requests\Applicant\SignUp\SubmitRightToWorkDeclarationRequest;
use App\Http\Resources\Common\AuthUserResource;
use App\Jobs\CreateApplicantContractJob;
use App\Models\Address;
use App\Models\Applicant;
use App\Models\ApplicantEvidence;
use App\Models\Declaration;
use App\Models\DeclarationAgreement;
use App\Models\RequiredEvidence;
use App\Models\Upload;
use App\Models\User;
use App\Models\VideoVerification;
use App\Notifications\Admin\ApplicantSignUpCompleteNotification;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class ApplicantSignUpController extends Controller
{
    use ApplicantPortalTrait;

    public function __construct(
        protected ApplicantSignUpPagesHandler $applicantSignUpPagesHandler,
        protected NotifyAdminsHandler $notifyAdminsHandler,
        protected RequestReferenceHandler $requestReferenceHandler,
    ) {
        //
    }

    public function pages()
    {
        /** @var User|null $user */
        $user = auth('sanctum')->user();

        $pages = $this->applicantSignUpPagesHandler->handle($user);

        $currentPageIndex = collect($pages)->search(function ($page) {
            return $page['complete'] === false;
        });

        if ($currentPageIndex === null || $currentPageIndex === false) {
            $currentPageIndex = count($pages) - 1;
        }

        return response()->json([
            'pages' => $pages,
            'current_page_index' => $currentPageIndex,
        ]);
    }

    public function createProfile(CreateProfileRequest $request)
    {

        $validData = $request->validated();

        /** @var User|null $user */
        $user = auth('sanctum')->user();
        $existingUser = $user !== null;

        try {
            DB::beginTransaction();

            $applicant = $user?->userable ?? new Applicant([
                'compliance_status' => ApplicantComplianceStatus::Incomplete,
                'profile_status' => ProfileStatus::Incomplete,
                'job_role_id' => $validData['job_role_id'] ?? null,
                'type_of_work_id' => $validData['type_of_work_id'] ?? null,
            ]);
            $applicant->save();

            if (! $user) {
                $user = new User([
                    ...$validData,
                    'type' => UserType::Applicant,
                    'password' => Hash::make($validData['password']),
                ]);
            } else {
                $user->fill($validData);
            }

            $user->userable()->associate($applicant);
            $user->save();

            $token = $existingUser ? null : $user->createToken('sign_up')->plainTextToken;

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        return response()->json([
            'token' => $token,
            'user' => new AuthUserResource($user),
        ]);
    }

    public function submitCompliance(SubmitComplianceRequest $request)
    {
        $applicant = $this->getApplicant();
        $validData = $request->validated();

        $photograph = Upload::query()->findOrFail($validData['photograph_id']);
        $evidenceOfId = Upload::query()->findOrFail($validData['evidence_of_id_id']);
        $videoVerification = VideoVerification::query()->findOrFail($validData['video_verification_id']);

        try {
            DB::beginTransaction();

            $applicant->photograph()->associate($photograph);
            $applicant->evidenceOfId()->associate($evidenceOfId);
            $applicant->videoVerification()->associate($videoVerification);
            $applicant->save();

            $photograph->owner()->associate($applicant)->save();
            $evidenceOfId->owner()->associate($applicant)->save();

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        return new AuthUserResource(Auth::user());
    }

    public function submitAddress(SubmitAddressRequest $request)
    {

        $applicant = $this->getApplicant();
        $validData = $request->validated();

        try {
            DB::beginTransaction();

            $address = new Address($validData);
            $address->owner()->associate($applicant);
            $address->save();

            $applicant->address()->associate($address)->save();

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        return new AuthUserResource(Auth::user());
    }

    public function submitQualifications(SubmitQualificationsRequest $request)
    {
        $applicant = $this->getApplicant();
        $validData = $request->validated();

        $applicant->update($validData);

        return new AuthUserResource(Auth::user());
    }

    public function submitReferences(SubmitReferencesRequest $request)
    {
        $applicant = $this->getApplicant();
        $validData = $request->validated();

        try {
            DB::beginTransaction();
            $applicant->references()->delete();
            $applicant->references()->createMany($validData['references']);
            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        return new AuthUserResource(Auth::user());
    }

    public function submitEvidence(SubmitEvidenceRequest $request, RequiredEvidence $requiredEvidence)
    {

        $applicant = $this->getApplicant();
        $validData = $request->validated();

        try {
            DB::beginTransaction();

            $applicant->applicantEvidence()->where('required_evidence_id', $requiredEvidence->id)->delete();

            $upload = Upload::query()->findOrFail($validData['upload_id']);

            $evidence = new ApplicantEvidence;
            $evidence->applicant()->associate($applicant);
            $evidence->requiredEvidence()->associate($requiredEvidence);
            $evidence->upload()->associate($upload);
            $evidence->save();

            $upload->owner()->associate($applicant)->save();

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        return new AuthUserResource(Auth::user());
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

        return new AuthUserResource(Auth::user());
    }

    public function submitRightToWorkDeclaration(SubmitRightToWorkDeclarationRequest $request)
    {
        $applicant = $this->getApplicant();
        $validData = $request->validated();

        $applicant->rightToWorkDeclaration()->updateOrCreate([], $validData);

        return new AuthUserResource(Auth::user());
    }

    public function completeSignUp()
    {

        $user = Auth::user();
        $pages = $this->applicantSignUpPagesHandler->handle($user);

        $canCompleteSignUp = collect($pages)->every(function ($page) {
            return $page['complete'] === true || $page['code'] === 'compliance_completed';
        });

        if (! $canCompleteSignUp) {
            return response()->json([
                'message' => 'Please complete all the required sign up steps',
            ], 400);
        }

        $applicant = $this->getApplicant();
        $applicant->update([
            'compliance_status' => ApplicantComplianceStatus::PendingApproval,
            'profile_status' => ProfileStatus::Pending,
            'sign_up_completed_at' => now(),
        ]);

        foreach ($applicant->references as $reference) {
            $this->requestReferenceHandler->handle($reference);
        }

        $this->notifyAdminsHandler->handle(new ApplicantSignUpCompleteNotification($applicant));
        CreateApplicantContractJob::dispatch($applicant->fresh());

        return new AuthUserResource(Auth::user());
    }

    public function cancelSignUp()
    {

        $user = Auth::user();
        $applicant = $this->getApplicant();

        if ($applicant->sign_up_completed_at !== null) {
            return response()->json([
                'message' => 'You cannot cancel sign up after completing the process',
            ], 400);
        }

        try {
            DB::beginTransaction();
            $applicant->evidenceOfId()->delete();
            $applicant->photograph()->delete();
            $applicant->videoVerifications()->delete();
            $applicant->addresses()->delete();
            $applicant->references()->delete();
            $applicant->declarationAgreements()->delete();
            $applicant->rightToWorkDeclaration()->delete();
            $applicant->applicantEvidence()->delete();
            $applicant->uploads()->delete();
            $applicant->contracts()->delete();
            $applicant->payslips()->delete();
            $applicant->delete();
            $user->update(['email' => sprintf('%s_deleted_%s', $user->email, now()->timestamp)]);
            $user->deviceTokens()->delete();
            $user->delete();
            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        return $this->stdSuccess(message: 'Sign up cancelled');
    }
}
