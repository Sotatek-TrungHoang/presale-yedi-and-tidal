<?php

namespace App\Http\Controllers\Advertiser;

use App\Http\Controllers\Controller;
use App\Http\Controllers\Traits\AdvertiserPortalTrait;
use App\Http\Resources\Contracts\ContractCollection;
use App\Models\Contract;

class ContractsController extends Controller
{
    use AdvertiserPortalTrait;

    public function __construct() {}

    public function index()
    {
        $advertiser = $this->getAdvertiser();
        $query = Contract::query()
            ->whereMorphedTo('owner', $advertiser)
            ->orderBy('created_at', 'desc');

        return new ContractCollection($query->get());
    }
}
