<?php

namespace App\Handlers\Advertisers\Adverts;

use App\Enums\AdvertStatus;
use App\Enums\ApplicationStatus;
use App\Handlers\Notifications\NotifyApplicantHandler;
use App\Models\Application;
use App\Notifications\Applicant\ApplicationDeclinedNotification;
use Illuminate\Support\Facades\DB;

class DeclineApplicationHandler
{
    public function __construct(
        protected NotifyApplicantHandler $notifyApplicantHandler,
    ) {}

    public function handle(Application $application)
    {
        try {
            DB::beginTransaction();
            $application->update([
                'status' => ApplicationStatus::Declined,
                'actioned_at' => now(),
            ]);

            if ($application->advert->applications()->where('status', ApplicationStatus::Pending)->count() === 0) {
                $application->advert->update([
                    'status' => AdvertStatus::NotFilled,
                ]);
            }

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        $this->notifyApplicantHandler->handle($application->applicant, new ApplicationDeclinedNotification($application));

        return $application;
    }
}
