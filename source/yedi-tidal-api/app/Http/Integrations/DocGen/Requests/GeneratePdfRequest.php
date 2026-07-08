<?php

namespace App\Http\Integrations\DocGen\Requests;

use Saloon\Contracts\Body\HasBody;
use Saloon\Enums\Method;
use Saloon\Http\Request;
use Saloon\Traits\Body\HasJsonBody;

class GeneratePdfRequest extends Request implements HasBody
{
    use HasJsonBody;

    protected bool $landscape = false;

    protected string $format = 'A4';

    /**
     * The HTTP method of the request
     */
    protected Method $method = Method::POST;

    public function __construct(
        protected readonly string $html
    ) {}

    /**
     * The endpoint for the request
     */
    public function resolveEndpoint(): string
    {
        return '/';
    }

    protected function defaultBody(): array
    {
        return [
            'html' => $this->html,
            'landscape' => $this->landscape,
            'format' => $this->format,
        ];
    }

    public function getLandscape(): bool
    {
        return $this->landscape;
    }

    public function setLandscape(bool $landscape): self
    {
        $this->landscape = $landscape;

        return $this;
    }

    public function getFormat(): string
    {
        return $this->format;
    }

    public function setFormat(string $format): self
    {
        $this->format = $format;

        return $this;
    }
}
