<?php

namespace App\Http\Controllers\Advertiser;

use App\Http\Controllers\Controller;
use App\Http\Controllers\Traits\AdvertiserPortalTrait;
use App\Http\Resources\Applicants\HeartedApplicants\HeartedApplicantCollection;
use App\Models\Applicant;
use App\Models\Application;
use App\Models\HeartedApplicant;

class HeartedApplicantsController extends Controller
{
    use AdvertiserPortalTrait;

    public function __construct() {}

    public function index()
    {
        $advertiser = $this->getAdvertiser();

        return new HeartedApplicantCollection(
            $advertiser->heartedApplicants()
                ->whereHas('applicant.user')
                ->with([
                    'applicant.photograph',
                    'applicant.user',
                ])
                ->get()
        );
    }

    public function heart(Applicant $applicant)
    {

        $advertiser = $this->getAdvertiser();

        $hasApplication = Application::query()
            ->where('applicant_id', $applicant->id)
            ->whereHas('advert', fn ($q) => $q->where('advertiser_id', $advertiser->id))
            ->exists();

        if (! $hasApplication) {
            return $this->stdError(message: 'You are not authorised to access this resource', status: 403);
        }

        HeartedApplicant::query()
            ->withTrashed()
            ->updateOrCreate([
                'applicant_id' => $applicant->id,
                'advertiser_id' => $advertiser->id,
            ], [
                'deleted_at' => null,
            ]);

        return $this->stdSuccess(message: ucwords(___('applicant')).' favourited');
    }

    public function unheart(Applicant $applicant)
    {

        $advertiser = $this->getAdvertiser();
        HeartedApplicant::query()
            ->where([
                'applicant_id' => $applicant->id,
                'advertiser_id' => $advertiser->id,
            ])
            ->delete();

        return $this->stdSuccess(message: ucwords(___('applicant')).' unfavourited');
    }
}
