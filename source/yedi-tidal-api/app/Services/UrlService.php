<?php

namespace App\Services;

use Illuminate\Support\Str;

class UrlService
{
    public string $baseUrl;

    protected string $prefix = 'admin';

    public function __construct(string $baseUrl)
    {
        // Remove trailing slash from base
        $baseUrl = Str::endsWith($baseUrl, '/') ? Str::substr($baseUrl, 0, -1) : $baseUrl;
        $this->baseUrl = "$baseUrl/$this->prefix";
    }

    public function create(string $path = '', array $query = []): string
    {

        if (! Str::startsWith($path, '/')) {
            $path = "/$path";
        }

        $query = count($query)
            ? '?'.http_build_query($query)
            : '';

        return sprintf('%s%s%s', $this->baseUrl, $path, $query);
    }

    public function root(): string
    {
        return $this->create();
    }

    public function applicant($applicantId): string
    {
        return $this->create(sprintf('applicants/%s/view', $applicantId));
    }

    public function advertiser($advertiserId): string
    {
        return $this->create(sprintf('advertisers/%s', $advertiserId));
    }

    public function advert($advertId): string
    {
        return $this->create(sprintf('adverts/%s', $advertId));
    }
}
