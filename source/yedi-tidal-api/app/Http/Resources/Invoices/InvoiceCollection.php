<?php

namespace App\Http\Resources\Invoices;

use Illuminate\Http\Resources\Json\ResourceCollection;

class InvoiceCollection extends ResourceCollection
{
    public $collects = InvoiceResource::class;
}
