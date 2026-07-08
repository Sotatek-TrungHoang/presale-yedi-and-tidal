<?php

namespace App\Http\Resources\Applicants;

use Illuminate\Http\Resources\Json\ResourceCollection;

class ApplicantCollection extends ResourceCollection
{
    public $collects = ApplicantResource::class;
}
