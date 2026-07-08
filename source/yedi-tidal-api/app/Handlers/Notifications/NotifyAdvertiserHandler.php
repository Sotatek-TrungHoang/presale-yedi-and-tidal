<?php

namespace App\Handlers\Notifications;

use App\Models\Advertiser;
use Illuminate\Notifications\Notification;

class NotifyAdvertiserHandler
{
    public function handle(Advertiser $advertiser, Notification $notification, bool $notifyNow = false)
    {
        // This handler might seem pointless but if an advertiser ever has multiple users,
        // it will come in handy.
        $notifyNow
            ? $advertiser->user?->notifyNow($notification)
            : $advertiser->user?->notify($notification);
    }
}
