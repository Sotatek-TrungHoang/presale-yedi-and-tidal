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

// https://developers.google.com/maps/documentation/places/web-service/search-find-place
class FindPlaceRequest extends Request implements Cacheable
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
        return 'place/findplacefromtext/json';
    }

    protected function defaultQuery(): array
    {
        return [
            'input' => $this->address,
            'inputtype' => 'textquery',
            'fields' => 'photo',
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
