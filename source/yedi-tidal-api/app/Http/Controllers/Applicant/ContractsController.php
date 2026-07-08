<?php

namespace App\Http\Controllers\Applicant;

use App\Http\Controllers\Controller;
use App\Http\Controllers\Traits\ApplicantPortalTrait;
use App\Http\Resources\Contracts\ContractCollection;
use App\Models\Contract;

class ContractsController extends Controller
{
    use ApplicantPortalTrait;

    public function __construct() {}

    public function index()
    {
        $applicant = $this->getApplicant();
        $query = Contract::query()
            ->whereMorphedTo('owner', $applicant)
            ->orderBy('created_at', 'desc');

        return new ContractCollection($query->get());
    }
}
