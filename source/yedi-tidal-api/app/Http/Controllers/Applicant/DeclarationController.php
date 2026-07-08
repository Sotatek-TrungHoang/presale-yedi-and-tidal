<?php

namespace App\Http\Controllers\Applicant;

use App\Http\Controllers\Controller;
use App\Http\Controllers\Traits\ApplicantPortalTrait;
use App\Http\Resources\Applicants\Declarations\DeclarationResource;
use App\Models\Declaration;

class DeclarationController extends Controller
{
    use ApplicantPortalTrait;

    public function __construct()
    {
        //
    }

    public function show(Declaration $declaration)
    {
        return new DeclarationResource($declaration);
    }
}
