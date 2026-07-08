<?php

namespace App\Handlers\Applicants\SignUp;

use App\Handlers\Settings\SettingsResolver;
use App\Http\Resources\Applicants\Declarations\DeclarationResource;
use App\Http\Resources\Applicants\Evidence\RequiredEvidenceResource;
use App\Models\Applicant;
use App\Models\Declaration;
use App\Models\RequiredEvidence;
use App\Models\User;

class ApplicantSignUpPagesHandler
{
    public function __construct(
        protected SettingsResolver $settingsResolver,
    ) {}

    public function handle(?User $user)
    {
        $settings = $this->settingsResolver->resolve();

        /** @var Applicant|null $applicant */
        $applicant = $user?->userable;

        $pages = [
            [
                'code' => 'choose_an_account',
                'title' => 'Choose an Account',
                'time_to_complete' => '',
                'complete' => $user !== null,
                'show_in_overview' => false,
            ],
            [
                'code' => 'overview',
                'title' => ___('Applicant Sign Up Overview'),
                'time_to_complete' => '',
                'complete' => $user !== null,
                'show_in_overview' => false,
            ],
            [
                'code' => 'create_profile',
                'title' => 'Create Profile',
                'time_to_complete' => '3-5 mins',
                'complete' => $user !== null,
                'show_in_overview' => true,
            ],
            [
                'code' => 'account_created',
                'title' => 'Account Created',
                'time_to_complete' => '',
                'complete' => $user !== null,
                'show_in_overview' => false,
            ],
            [
                'code' => 'compliance',
                'title' => 'Compliance',
                'time_to_complete' => '10 mins',
                'complete' => $applicant?->photograph()->exists() && $applicant?->evidenceOfId()->exists() && $applicant?->videoVerification()->exists() ?? false,
                'show_in_overview' => true,
            ],
            [
                'code' => 'address',
                'title' => 'Address',
                'time_to_complete' => '3-5 mins',
                'complete' => $applicant?->address()->exists() ?? false,
                'show_in_overview' => true,
            ],
            [
                'code' => 'qualifications',
                'title' => 'Qualifications',
                'time_to_complete' => '3-5 mins',
                'complete' => $applicant?->qualification !== null && (! $settings->require_teacher_number || $applicant?->teacher_number !== null),
                'show_in_overview' => true,
                'require_teacher_number' => $settings->require_teacher_number,
            ],
        ];

        if ($settings->references_required > 0) {
            $pages[] = [
                'code' => 'references',
                'title' => 'References',
                'time_to_complete' => '3-5 mins',
                'complete' => $applicant && $applicant->references()->count() >= $settings->references_required,
                'show_in_overview' => true,
                'references_required' => $settings->references_required,
            ];
        }

        $requiredEvidence = RequiredEvidence::query()->where('required', true)->get();
        foreach ($requiredEvidence as $requiredEvidence) {
            $pages[] = [
                'code' => 'evidence',
                'title' => $requiredEvidence->title,
                'time_to_complete' => $requiredEvidence->time_to_complete,
                'complete' => $applicant?->applicantEvidence()->where('required_evidence_id', $requiredEvidence->id)->exists() ?? false,
                'show_in_overview' => true,
                'required_evidence_id' => $requiredEvidence->id,
                'required_evidence' => new RequiredEvidenceResource($requiredEvidence),
            ];
        }

        $declarations = Declaration::query()->where('required', true)->get();
        foreach ($declarations as $declaration) {
            $pages[] = [
                'code' => 'declaration',
                'title' => $declaration->title,
                'time_to_complete' => $declaration->time_to_complete,
                'complete' => $applicant?->declarationAgreements()->where('declaration_id', $declaration->id)->exists() ?? false,
                'show_in_overview' => true,
                'declaration_id' => $declaration->id,
                'declaration' => new DeclarationResource($declaration),
            ];
        }

        $pages[] = [
            'code' => 'right_to_work_declaration',
            'title' => 'Right to Work Declaration',
            'time_to_complete' => '5 mins',
            'complete' => $applicant?->rightToWorkDeclaration()->exists() ?? false,
            'show_in_overview' => true,
        ];

        $pages[] = [
            'code' => 'compliance_completed',
            'title' => 'Compliance Completed',
            'time_to_complete' => '',
            'complete' => $applicant?->sign_up_completed_at !== null,
            'show_in_overview' => false,
        ];

        return $pages;
    }
}
