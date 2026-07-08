<?php

namespace App\Http\Controllers\Applicant;

use App\Http\Controllers\Controller;
use App\Http\Controllers\Traits\ApplicantPortalTrait;
use App\Http\Resources\Payslips\PayslipCollection;
use App\Models\Payslip;

class PayslipsController extends Controller
{
    use ApplicantPortalTrait;

    public function __construct() {}

    public function index()
    {
        $advertiser = $this->getApplicant();
        $query = Payslip::query()
            ->where('applicant_id', $advertiser->id)
            ->orderBy('created_at', 'desc');

        return new PayslipCollection($query->get());
    }
}
