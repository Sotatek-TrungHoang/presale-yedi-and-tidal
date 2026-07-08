<?php

namespace App\Http\Controllers\Applicant;

use App\Enums\AdvertiserComplianceStatus;
use App\Enums\AdvertStatus;
use App\Enums\AdvertType;
use App\Handlers\Applicants\Adverts\ApplyToAdvertHandler;
use App\Handlers\Applicants\Adverts\CancelApplicationHandler;
use App\Handlers\Notifications\NotifyAdvertiserHandler;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Traits\ApplicantPortalTrait;
use App\Http\Requests\Applicant\Adverts\ListAdvertsRequest;
use App\Http\Resources\Adverts\AdvertCollection;
use App\Http\Resources\Adverts\AdvertResource;
use App\Models\Advert;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Gate;

class AdvertsController extends Controller
{
    use ApplicantPortalTrait;

    public function __construct(
        protected NotifyAdvertiserHandler $notifyAdvertiserHandler,
        protected ApplyToAdvertHandler $applyToAdvertHandler,
        protected CancelApplicationHandler $cancelApplicationHandler,
    ) {}

    public function index(ListAdvertsRequest $request)
    {

        $validData = $request->validated();

        $type = AdvertType::from($validData['type']);
        $query = Advert::query()
            ->where('type', $type)
            ->where('status', AdvertStatus::Approved)
            ->whereHas('advertiser', fn (Builder $q) => $q->where('compliance_status', AdvertiserComplianceStatus::Compliant))
            ->with(['advertiser'])
            ->orderBy('apply_by', 'asc');

        return new AdvertCollection($query->get());
    }

    public function show(Advert $advert)
    {
        Gate::authorize('view', $advert);

        return new AdvertResource($advert->load([
            'advertiser',
            'documents',
        ]));
    }

    public function apply(Advert $advert)
    {
        Gate::authorize('apply', $advert);

        $applicant = $this->getApplicant();
        $advert = $this->applyToAdvertHandler->handle($advert, $applicant);

        return new AdvertResource($advert);
    }

    public function cancelApplication(Advert $advert)
    {
        Gate::authorize('cancelApplication', $advert);

        $applicant = $this->getApplicant();
        $advert = $this->cancelApplicationHandler->handle($advert, $applicant);

        return new AdvertResource($advert);
    }
}
