<?php

namespace App\Http\Controllers\Advertiser;

use App\Enums\ApplicationStatus;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Traits\AdvertiserPortalTrait;
use App\Http\Requests\Advertiser\Applications\ListApplicationsRequest;
use App\Http\Resources\Applications\ApplicationCollection;
use App\Models\Application;
use Illuminate\Support\Facades\Gate;

class ApplicationsController extends Controller
{
    use AdvertiserPortalTrait;

    public function index(ListApplicationsRequest $request)
    {

        Gate::authorize('viewAny', Application::class);

        $validData = $request->validated();
        $status = ApplicationStatus::tryFrom($validData['status']);

        $advertiser = $this->getAdvertiser();
        $query = Application::query()
            ->whereHas('advert', fn ($query) => $query->where('advertiser_id', $advertiser->id))
            ->when($status, fn ($query, $status) => $query->where('status', $status))
            ->with([
                'advert',
                'applicant',
                'applicant.photograph',
                'applicant.user',
            ])
            ->orderBy('created_at', 'asc');

        return new ApplicationCollection($query->get());
    }
}
