<?php

namespace App\Http\Integrations\DocGen;

use Saloon\Contracts\Authenticator;
use Saloon\Http\Auth\BasicAuthenticator;
use Saloon\Http\Connector;
use Saloon\Traits\Plugins\AcceptsJson;
use Saloon\Traits\Plugins\AlwaysThrowOnErrors;

class DocGenConnector extends Connector
{
    use AcceptsJson, AlwaysThrowOnErrors;

    /**
     * The Base URL of the API
     */
    public function resolveBaseUrl(): string
    {
        return config('services.docgen.url');
    }

    protected function defaultAuth(): ?Authenticator
    {
        if (config('services.docgen.username') && config('services.docgen.password')) {
            return new BasicAuthenticator(
                config('services.docgen.username'),
                config('services.docgen.password')
            );
        }

        return null;
    }
}
