<?php

namespace App\Http\Controllers\Advertiser;

use App\Handlers\Advertisers\Adverts\AcceptApplicationHandler;
use App\Handlers\Advertisers\Adverts\DeclineApplicationHandler;
use App\Handlers\Advertisers\Adverts\RateApplicationHandler;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Traits\AdvertiserPortalTrait;
use App\Http\Requests\Advertiser\Applications\RateApplicationRequest;
use App\Http\Resources\Applications\ApplicationCollection;
use App\Http\Resources\Applications\ApplicationResource;
use App\Models\Advert;
use App\Models\Application;
use Illuminate\Support\Facades\Gate;

class AdvertApplicationsController extends Controller
{
    use AdvertiserPortalTrait;

    public function __construct(
        protected DeclineApplicationHandler $declineApplicationHandler,
        protected AcceptApplicationHandler $acceptApplicationHandler,
        protected RateApplicationHandler $rateApplicationHandler,
    ) {}

    public function index(Advert $advert)
    {
        Gate::authorize('view', $advert);

        $query = Application::query()
            ->where('advert_id', $advert->id)
            ->with([
                'applicant',
                'applicant.photograph',
                'applicant.user',
            ])
            ->orderBy('created_at', 'asc');

        return new ApplicationCollection($query->get());
    }

    public function accept(Application $application)
    {
        Gate::authorize('accept', $application);
        $application = $this->acceptApplicationHandler->handle($application);

        return new ApplicationResource(
            $application->load([
                'applicant',
                'applicant.photograph',
                'applicant.user',
            ])
        );
    }

    public function decline(Application $application)
    {
        Gate::authorize('decline', $application);
        $application = $this->declineApplicationHandler->handle($application);

        return new ApplicationResource(
            $application->load([
                'applicant',
                'applicant.photograph',
                'applicant.user',
            ])
        );
    }

    public function rate(RateApplicationRequest $request, Application $application)
    {

        $rating = $request->validated('rating');
        $application = $this->rateApplicationHandler->handle($application, $rating);

        return new ApplicationResource($application->load([
            'advert',
            'applicant',
            'applicant.photograph',
            'applicant.user',
        ]));
    }
}
