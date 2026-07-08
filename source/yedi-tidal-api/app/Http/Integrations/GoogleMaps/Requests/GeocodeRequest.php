<?php

namespace App\Http\Integrations\GoogleMaps\Requests;

use Illuminate\Support\Facades\Cache;
use Saloon\CachePlugin\Contracts\Cacheable;
use Saloon\CachePlugin\Contracts\Driver;
use Saloon\CachePlugin\Drivers\LaravelCacheDriver;
use Saloon\CachePlugin\Traits\HasCaching;
use Saloon\Enums\Method;
use Saloon\Http\Request;
use Saloon\Http\Response;

// https://developers.google.com/maps/documentation/geocoding/requests-geocoding
class GeocodeRequest extends Request implements Cacheable
{
    use HasCaching;

    /**
     * The HTTP method of the request
     */
    protected Method $method = Method::GET;

    public function __construct(
        protected string $address
    ) {}

    /**
     * The endpoint for the request
     */
    public function resolveEndpoint(): string
    {
        return 'geocode/json';
    }

    protected function defaultQuery(): array
    {
        return [
            'address' => $this->address,
        ];
    }

    public function hasRequestFailed(Response $response): ?bool
    {
        $status = $response->json('status');

        return ! in_array($status, ['OK', 'ZERO_RESULTS']);
    }

    public function resolveCacheDriver(): Driver
    {
        return new LaravelCacheDriver(Cache::store());
    }

    public function cacheExpiryInSeconds(): int
    {
        return 60 * 5;
    }
}
