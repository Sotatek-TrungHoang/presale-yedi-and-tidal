<?php

namespace App\Http\Resources\Applicants\References;

use Illuminate\Http\Resources\Json\ResourceCollection;

class ReferenceCollection extends ResourceCollection
{
    public $collects = ReferenceResource::class;
}
