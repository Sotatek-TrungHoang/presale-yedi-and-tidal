<?php

namespace App\Handlers\Notifications;

use App\Models\Applicant;
use Illuminate\Notifications\Notification;

class NotifyApplicantHandler
{
    public function handle(Applicant $applicant, Notification $notification, bool $notifyNow = false)
    {
        $notifyNow
            ? $applicant->user?->notifyNow($notification)
            : $applicant->user?->notify($notification);
    }
}
