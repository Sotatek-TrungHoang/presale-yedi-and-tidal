<?php

namespace App\Handlers\Notifications;

use App\Enums\UserType;
use App\Models\User;
use Illuminate\Notifications\Notification;

class NotifyAdminsHandler
{
    public function handle(Notification $notification, bool $notifyNow = false)
    {
        User::query()
            ->where('type', UserType::Admin)
            // ->whereNotNull('email_verified_at')
            ->each(fn (User $user) => $notifyNow ? $user->notifyNow($notification) : $user->notify($notification));
    }
}
