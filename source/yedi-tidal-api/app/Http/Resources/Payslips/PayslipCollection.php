<?php

namespace App\Http\Resources\Payslips;

use Illuminate\Http\Resources\Json\ResourceCollection;

class PayslipCollection extends ResourceCollection
{
    public $collects = PayslipResource::class;
}
