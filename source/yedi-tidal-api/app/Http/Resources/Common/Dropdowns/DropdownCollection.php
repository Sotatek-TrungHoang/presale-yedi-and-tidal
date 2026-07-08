<?php

namespace App\Http\Resources\Common\Dropdowns;

use Illuminate\Http\Resources\Json\ResourceCollection;

class DropdownCollection extends ResourceCollection
{
    public $collects = DropdownResource::class;
}
