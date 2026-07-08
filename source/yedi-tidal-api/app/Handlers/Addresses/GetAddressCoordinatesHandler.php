<?php

namespace App\Handlers\Addresses;

use App\Http\Integrations\GoogleMaps\GoogleMapsConnector;
use App\Http\Integrations\GoogleMaps\Requests\GeocodeRequest;
use App\Models\Address;
use Illuminate\Support\Facades\Log;
use Saloon\Exceptions\Request\RequestException;

class GetAddressCoordinatesHandler
{
    public function __construct(
        protected GoogleMapsConnector $connector
    ) {}

    /**
     * @return null|array{latitude: float, longitude: float}
     */
    public function handle(Address $address)
    {

        $existing = Address::query()
            ->when($address->exists, fn ($query) => $query->where('id', '!=', $address->id))
            ->where('line_1', $address->line_1)
            ->where('postcode', $address->postcode)
            ->where('country', $address->country['alpha2'])
            ->where('latitude', '!=', null)
            ->where('longitude', '!=', null)
            ->first();

        if ($existing) {
            Log::channel('google_maps')->info("Coordinates for address already exist, reusing: {$address->line_1}, {$address->postcode}, {$address->country['alpha2']}");

            return [
                'latitude' => $existing->latitude,
                'longitude' => $existing->longitude,
            ];
        }

        if (! config('services.google_maps.enabled')) {
            return null;
        }

        $formatted = collect([
            $address->line_1,
            $address->postcode,
            $address->country['alpha2'],
        ])->filter()->join(', ');

        $request = new GeocodeRequest($formatted);
        Log::channel('google_maps')->info("Requesting coordinates for address: {$formatted}");
        try {
            $response = $this->connector->send($request);
        } catch (RequestException $e) {
            report($e);

            return null;
        }

        return [
            'latitude' => $response->json('results.0.geometry.location.lat'),
            'longitude' => $response->json('results.0.geometry.location.lng'),
        ];
    }
}
