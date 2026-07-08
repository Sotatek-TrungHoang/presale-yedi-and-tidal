<?php

namespace App\Http\Controllers\Applicant;

use App\Enums\ApplicationStatus;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Traits\ApplicantPortalTrait;
use App\Http\Resources\Adverts\AdvertCollection;
use App\Models\Advert;
use Illuminate\Database\Eloquent\Builder;

class BookingsController extends Controller
{
    use ApplicantPortalTrait;

    public function __construct() {}

    public function confirmed()
    {
        $applicant = $this->getApplicant();
        $query = Advert::query()
            ->whereHas('acceptedApplication', fn (Builder $q) => $q->where('applicant_id', $applicant->id))
            ->with(['advertiser'])
            ->orderBy('starts_at', 'asc');

        return new AdvertCollection($query->get());
    }

    public function appliedTo()
    {
        $applicant = $this->getApplicant();
        $query = Advert::query()
            ->whereHas('applications', fn (Builder $q) => $q
                ->where('applicant_id', $applicant->id)
                ->where('status', '!=', ApplicationStatus::Cancelled)
                ->where('status', '!=', ApplicationStatus::Accepted)
            )
            ->with(['advertiser'])
            ->orderBy('starts_at', 'asc');

        return new AdvertCollection($query->get());
    }
}
