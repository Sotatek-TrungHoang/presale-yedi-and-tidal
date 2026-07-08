<?php

namespace App\Http\Resources\Adverts;

use Illuminate\Http\Resources\Json\ResourceCollection;

class AdvertCollection extends ResourceCollection
{
    public $collects = AdvertResource::class;
}
