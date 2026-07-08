<?php

namespace App\DTOs\Notifications;

use Spatie\LaravelData\Data;

class FcmNotificationData extends Data
{
    public function __construct(
        public string $title,
        public ?string $body = null,
        public array $data = [],
    ) {}
}
