<?php

namespace App\Http\Integrations\GoogleMaps;

use Saloon\Http\Connector;
use Saloon\Traits\Plugins\AcceptsJson;
use Saloon\Traits\Plugins\AlwaysThrowOnErrors;

class GoogleMapsConnector extends Connector
{
    use AcceptsJson, AlwaysThrowOnErrors;

    public ?int $tries = 1;

    /**
     * The Base URL of the API
     */
    public function resolveBaseUrl(): string
    {
        return 'https://maps.googleapis.com/maps/api/';
    }

    protected function defaultQuery(): array
    {
        return [
            'key' => config('services.google_maps.api_key'),
        ];
    }
}
