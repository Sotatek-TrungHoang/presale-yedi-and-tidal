<?php

namespace App\Http\Controllers\Advertiser;

use App\Http\Controllers\Controller;
use App\Http\Controllers\Traits\AdvertiserPortalTrait;
use App\Http\Resources\Invoices\InvoiceCollection;
use App\Models\Invoice;

class InvoicesController extends Controller
{
    use AdvertiserPortalTrait;

    public function __construct() {}

    public function index()
    {

        $advertiser = $this->getAdvertiser();
        $query = Invoice::query()
            ->whereHas('advert', fn ($query) => $query->where('advertiser_id', $advertiser->id))
            ->orderBy('created_at', 'desc');

        return new InvoiceCollection($query->get());
    }
}
