<?php

namespace App\Notifications;

use App\Services\UrlService;
use Illuminate\Notifications\Notification;
use Illuminate\Support\Facades\App;

abstract class AbstractNotification extends Notification
{
    protected UrlService $urlService;

    public function __construct()
    {
        $this->urlService = App::get(UrlService::class);
    }

    protected function subject(string $subject)
    {
        return sprintf('%s | %s', $subject, config('app.name'));
    }

    protected function markdown(string $template)
    {
        return 'mail.'.$template;
    }
}
