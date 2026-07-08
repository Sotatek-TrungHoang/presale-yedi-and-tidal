<?php

namespace App\Http\Controllers\Traits;

use App\Models\Applicant;
use Exception;
use Illuminate\Support\Facades\Auth;

trait ApplicantPortalTrait
{
    /**
     * @return Applicant
     *
     * @throws Exception
     */
    protected function getApplicant()
    {
        $user = Auth::user();
        if (! $user) {
            throw new \Exception('User not found');
        }

        if (! $user->userable instanceof Applicant) {
            throw new \Exception('User is not an applicant');
        }

        return $user->userable;
    }
}
