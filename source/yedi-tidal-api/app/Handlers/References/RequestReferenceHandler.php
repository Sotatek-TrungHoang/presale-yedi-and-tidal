<?php

namespace App\Handlers\References;

use App\Enums\ReferenceStatus;
use App\Models\Reference;
use App\Notifications\Public\NewReferenceRequestNotification;
use Illuminate\Support\Facades\Notification;

class RequestReferenceHandler
{
    public function handle(Reference $reference, bool $notifyNow = false)
    {
        if ($notifyNow) {
            Notification::route('mail', $reference->email)->notifyNow(new NewReferenceRequestNotification($reference));
        } else {
            Notification::route('mail', $reference->email)->notify(new NewReferenceRequestNotification($reference));
        }
        $reference->update(['status' => ReferenceStatus::SentToReferee]);

        return $reference;
    }
}
