<?php

namespace App\Http\Resources\Applicants\HeartedApplicants;

use Illuminate\Http\Resources\Json\ResourceCollection;

class HeartedApplicantCollection extends ResourceCollection
{
    public $collects = HeartedApplicantResource::class;
}
