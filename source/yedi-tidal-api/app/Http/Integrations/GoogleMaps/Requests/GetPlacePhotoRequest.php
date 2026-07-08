<?php

namespace App\Http\Integrations\GoogleMaps\Requests;

use Saloon\Enums\Method;
use Saloon\Http\Request;

// https://developers.google.com/maps/documentation/places/web-service/photos
class GetPlacePhotoRequest extends Request
{
    /**
     * The HTTP method of the request
     */
    protected Method $method = Method::GET;

    public function __construct(
        protected string $photoRefrence,
    ) {}

    /**
     * The endpoint for the request
     */
    public function resolveEndpoint(): string
    {
        return 'place/photo';
    }

    protected function defaultQuery(): array
    {
        return [
            'photoreference' => $this->photoRefrence,
            'maxwidth' => 1200,
        ];
    }
}
