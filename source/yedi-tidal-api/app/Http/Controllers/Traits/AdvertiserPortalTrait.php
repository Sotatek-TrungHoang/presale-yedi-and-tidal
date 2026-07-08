<?php

namespace App\Http\Controllers\Traits;

use App\Models\Advertiser;
use Exception;
use Illuminate\Support\Facades\Auth;

trait AdvertiserPortalTrait
{
    /**
     * @return Advertiser
     *
     * @throws Exception
     */
    protected function getAdvertiser()
    {
        $user = Auth::user();
        if (! $user) {
            throw new \Exception('User not found');
        }

        if (! $user->userable instanceof Advertiser) {
            throw new \Exception('User is not an advertiser');
        }

        return $user->userable;
    }
}
