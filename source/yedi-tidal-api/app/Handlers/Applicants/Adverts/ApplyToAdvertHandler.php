<?php

namespace App\Handlers\Applicants\Adverts;

use App\Enums\ApplicationStatus;
use App\Handlers\Notifications\NotifyAdvertiserHandler;
use App\Models\Advert;
use App\Models\Applicant;
use App\Models\Application;
use App\Notifications\Advertiser\NewApplicationNotification;
use Illuminate\Support\Facades\DB;

class ApplyToAdvertHandler
{
    public function __construct(
        protected NotifyAdvertiserHandler $notifyAdvertiserHandler,
    ) {}

    public function handle(Advert $advert, Applicant $applicant)
    {
        try {
            DB::beginTransaction();

            $application = $advert->applications()->where('applicant_id', $applicant->id)->where('status', ApplicationStatus::Cancelled)->first();
            if ($application) {
                $application->status = ApplicationStatus::Pending;
                $applicant->created_at = now();
            } else {
                $application = new Application([
                    'status' => ApplicationStatus::Pending,
                ]);
                $application->applicant()->associate($applicant);
                $application->advert()->associate($advert);
            }

            $application->save();

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        $this->notifyAdvertiserHandler->handle($advert->advertiser, new NewApplicationNotification($application));

        return $advert;
    }
}
