<?php

namespace App\Handlers\Applicants\Adverts;

use App\Enums\ApplicationStatus;
use App\Handlers\Notifications\NotifyAdvertiserHandler;
use App\Models\Advert;
use App\Models\Applicant;
use App\Models\Application;

class CancelApplicationHandler
{
    public function __construct(
        protected NotifyAdvertiserHandler $notifyAdvertiserHandler,
    ) {}

    public function handle(Advert $advert, Applicant $applicant)
    {
        /** @var Application $application */
        $application = $advert->applications()
            ->where('applicant_id', $applicant->id)
            ->where('status', ApplicationStatus::Pending)
            ->firstOrFail();
        $application->update(['status' => ApplicationStatus::Cancelled]);

        return $advert;
    }
}
