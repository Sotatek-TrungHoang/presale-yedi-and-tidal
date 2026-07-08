<?php

namespace App\Http\Resources\Applicants\Declarations;

use Illuminate\Http\Resources\Json\ResourceCollection;

class DeclarationCollection extends ResourceCollection
{
    public $collects = DeclarationResource::class;
}
