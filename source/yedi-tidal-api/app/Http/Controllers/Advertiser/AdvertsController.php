<?php

namespace App\Http\Controllers\Advertiser;

use App\DTOs\Adverts\CreateAdvertData;
use App\Enums\AdvertType;
use App\Handlers\Advertisers\Adverts\CreateAdvertHandler;
use App\Handlers\Advertisers\Adverts\DeleteAdvertHandler;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Traits\AdvertiserPortalTrait;
use App\Http\Requests\Advertiser\Adverts\CreateAdvertRequest;
use App\Http\Requests\Advertiser\Adverts\ListAdvertsRequest;
use App\Http\Resources\Adverts\AdvertCollection;
use App\Http\Resources\Adverts\AdvertResource;
use App\Models\Advert;
use Illuminate\Support\Facades\Gate;

class AdvertsController extends Controller
{
    use AdvertiserPortalTrait;

    public function __construct(
        protected CreateAdvertHandler $createAdvertHandler,
        protected DeleteAdvertHandler $deleteAdvertHandler,
    ) {}

    public function index(ListAdvertsRequest $request)
    {

        $validData = $request->validated();
        $type = AdvertType::from($validData['type']);
        $advertiser = $this->getAdvertiser();

        $query = Advert::query()
            ->where('type', $type)
            ->where('advertiser_id', $advertiser->id)
            ->orderBy('apply_by', 'asc');

        return new AdvertCollection($query->get());
    }

    public function show(Advert $advert)
    {
        Gate::authorize('view', $advert);

        return new AdvertResource($advert->load([
            'documents',
        ]));
    }

    public function store(CreateAdvertRequest $request)
    {
        $data = CreateAdvertData::from($request->validated());
        $advert = $this->createAdvertHandler->handle($data, $this->getAdvertiser());

        return new AdvertResource($advert);
    }

    public function destroy(Advert $advert)
    {
        Gate::authorize('delete', $advert);
        $advert = $this->deleteAdvertHandler->handle($advert);

        return $this->stdSuccess(message: 'Job deleted');
    }
}
