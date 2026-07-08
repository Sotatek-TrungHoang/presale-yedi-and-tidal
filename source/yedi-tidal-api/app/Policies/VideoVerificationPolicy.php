<?php

namespace App\Policies;

use App\Models\User;
use App\Models\VideoVerification;

class VideoVerificationPolicy
{
    public function update(User $user, VideoVerification $videoVerification): bool
    {
        return $videoVerification->applicant()->is($user->userable) && $videoVerification->upload()->doesntExist();
    }
}
