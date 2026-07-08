<?php

namespace App\Http\Controllers\Applicant;

use App\Http\Controllers\Controller;
use App\Http\Controllers\Traits\ApplicantPortalTrait;
use App\Http\Resources\Applicants\Evidence\RequiredEvidenceResource;
use App\Models\RequiredEvidence;

class RequiredEvidenceController extends Controller
{
    use ApplicantPortalTrait;

    public function __construct()
    {
        //
    }

    public function show(RequiredEvidence $requiredEvidence)
    {
        return new RequiredEvidenceResource($requiredEvidence);
    }
}
