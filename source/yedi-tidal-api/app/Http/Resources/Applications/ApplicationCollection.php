<?php

namespace App\Http\Resources\Applications;

use Illuminate\Http\Resources\Json\ResourceCollection;

class ApplicationCollection extends ResourceCollection
{
    public $collects = ApplicationResource::class;
}
