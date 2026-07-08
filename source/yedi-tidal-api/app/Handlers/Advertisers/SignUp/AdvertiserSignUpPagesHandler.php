<?php

namespace App\Handlers\Advertisers\SignUp;

use App\Enums\ApplicantComplianceStatus;
use App\Models\Advertiser;
use App\Models\User;

class AdvertiserSignUpPagesHandler
{
    public function handle(?User $user)
    {
        /** @var Advertiser|null $advertiser */
        $advertiser = $user?->userable;

        $pages = [
            [
                'code' => 'choose_an_account',
                'title' => 'Choose an Account',
                'time_to_complete' => '',
                'complete' => $user !== null,
                'show_in_overview' => false,
            ],
            [
                'code' => 'overview',
                'title' => ___('Advertiser Sign Up Overview'),
                'time_to_complete' => '',
                'complete' => $user !== null,
                'show_in_overview' => false,
            ],
            [
                'code' => 'create_profile',
                'title' => 'Create Profile',
                'time_to_complete' => '3-5 mins',
                'complete' => $user !== null,
                'show_in_overview' => true,
            ],
            [
                'code' => 'account_created',
                'title' => 'Account Created',
                'time_to_complete' => '',
                'complete' => $user !== null,
                'show_in_overview' => false,
            ],
            [
                'code' => 'address',
                'title' => 'Address',
                'time_to_complete' => '3-5 mins',
                'complete' => $advertiser?->address()->exists() ?? false,
                'show_in_overview' => true,
            ],
            [
                'code' => 'photo_upload',
                'title' => 'Photo Upload',
                'time_to_complete' => '1-2 mins',
                'complete' => $advertiser?->photograph()->exists() ?? false,
                'show_in_overview' => true,
            ],
            [
                'code' => 'sign_up_complete',
                'title' => 'Sign Up Complete',
                'time_to_complete' => '',
                'complete' => $advertiser?->compliance_status !== ApplicantComplianceStatus::Incomplete,
                'show_in_overview' => false,
            ],
        ];

        return $pages;
    }
}
