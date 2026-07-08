<?php

namespace App\Http\Resources\Applicants\Declarations;

use Illuminate\Http\Resources\Json\ResourceCollection;

class DeclarationAgreementCollection extends ResourceCollection
{
    public $collects = DeclarationAgreementResource::class;
}
