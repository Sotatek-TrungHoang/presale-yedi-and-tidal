<?php

namespace App\Http\Resources\Applicants\Evidence;

use Illuminate\Http\Resources\Json\ResourceCollection;

class ApplicantEvidenceCollection extends ResourceCollection
{
    public $collects = ApplicantEvidenceResource::class;
}
