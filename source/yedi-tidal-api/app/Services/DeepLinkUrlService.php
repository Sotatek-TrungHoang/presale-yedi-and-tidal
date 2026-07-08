<?php

namespace App\Services;

use Illuminate\Support\Str;

class DeepLinkUrlService
{
    public string $baseUrl;

    public function __construct(string $baseUrl)
    {
        // Remove trailing slash from base
        $baseUrl = Str::endsWith($baseUrl, '/') ? Str::substr($baseUrl, 0, -1) : $baseUrl;
        $this->baseUrl = "$baseUrl";
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

    public function resetPassword(string $email, string $token, array $additional = []): string
    {
        return $this->create('landing/login/reset-password', ['email' => $email, 'token' => $token, ...$additional]);
    }
}
