<?php

namespace App\Http\Resources\Contracts;

use Illuminate\Http\Resources\Json\ResourceCollection;

class ContractCollection extends ResourceCollection
{
    public $collects = ContractResource::class;
}
