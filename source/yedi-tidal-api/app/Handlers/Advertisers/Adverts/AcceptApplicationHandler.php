<?php

namespace App\Handlers\Advertisers\Adverts;

use App\Enums\AdvertStatus;
use App\Enums\ApplicationStatus;
use App\Handlers\Notifications\NotifyApplicantHandler;
use App\Models\Application;
use App\Notifications\Applicant\ApplicationAcceptedNotification;
use App\Notifications\Applicant\ApplicationDeclinedNotification;
use Illuminate\Support\Facades\DB;

class AcceptApplicationHandler
{
    public function __construct(
        protected NotifyApplicantHandler $notifyApplicantHandler,
    ) {}

    public function handle(Application $application)
    {
        try {
            DB::beginTransaction();
            $application->update([
                'status' => ApplicationStatus::Accepted,
                'actioned_at' => now(),
            ]);

            $declinedApplications = $application
                ->advert
                ->applications()
                ->where('applications.id', '!=', $application->id)
                ->where('status', ApplicationStatus::Pending)
                ->get();

            foreach ($declinedApplications as $declinedApplication) {
                $declinedApplication->update([
                    'status' => ApplicationStatus::Declined,
                    'actioned_at' => now(),
                ]);
            }

            $application->advert()->update(['status' => AdvertStatus::Filled]);

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        $this->notifyApplicantHandler->handle($application->applicant, new ApplicationAcceptedNotification($application));
        foreach ($declinedApplications as $declinedApplication) {
            $this->notifyApplicantHandler->handle($declinedApplication->applicant, new ApplicationDeclinedNotification($declinedApplication));
        }

        return $application;
    }
}
