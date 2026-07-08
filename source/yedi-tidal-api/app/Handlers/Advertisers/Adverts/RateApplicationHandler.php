<?php

namespace App\Handlers\Advertisers\Adverts;

use App\Enums\ApplicationStatus;
use App\Models\Application;
use Illuminate\Support\Facades\DB;

class RateApplicationHandler
{
    public function handle(Application $application, int $rating)
    {

        try {
            DB::beginTransaction();

            $application->update([
                'rating' => $rating,
            ]);

            $applicantRating = $application->applicant->applications()
                ->where('status', ApplicationStatus::Accepted)
                ->whereNotNull('rating')
                ->avg('rating');

            $application->applicant->update([
                'rating' => $applicantRating,
            ]);

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        return $application->fresh();

    }
}
