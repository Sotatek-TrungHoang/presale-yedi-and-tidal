<?php

namespace App\Http\Resources\Applicants\Evidence;

use Illuminate\Http\Resources\Json\ResourceCollection;

class RequiredEvidenceCollection extends ResourceCollection
{
    public $collects = RequiredEvidenceResource::class;
}
