<?php

namespace App\Policies;

use App\Enums\AdvertStatus;
use App\Enums\ApplicationStatus;
use App\Enums\ProfileStatus;
use App\Models\Application;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class ApplicationPolicy
{
    public function viewAny(User $user)
    {
        if ($user->isAdmin()) {
            return true;
        }

        if (! $user->isAdvertiser()) {
            return Response::deny('Only advertisers can accept applications');
        }

        /** @var Advertiser $advertiser */
        $advertiser = $user->userable;

        switch ($advertiser->profile_status) {
            case ProfileStatus::Pending:
                return Response::deny('Your account is still pending approval. You cannot view applications until your account is approved');
            case ProfileStatus::Disabled:
                return Response::deny('Your account has been disabled. Please contact support for more information');
            default:
                break;
        }

        return true;
    }

    public function accept(User $user, Application $application)
    {
        if (! $user->isAdvertiser()) {
            return Response::deny('Only advertisers can accept applications');
        }

        if (! $user->can('view', $application->advert)) {
            return Response::deny('You do not have permission to view this application');
        }

        if ($application->status !== ApplicationStatus::Pending) {
            return Response::deny('You cannot accept an application that is not pending');
        }

        if ($application->advert->acceptedApplication()->exists()) {
            return Response::deny('You cannot accept an application for an advert that already has an accepted application');
        }

        if ($application->advert->status != AdvertStatus::PendingAllocation) {
            return Response::deny('You cannot accept an application for an advert that is not pending allocation');
        }

        return true;
    }

    public function decline(User $user, Application $application)
    {
        if (! $user->isAdvertiser()) {
            return Response::deny('Only advertisers can decline applications');
        }

        if (! $user->can('view', $application->advert)) {
            return Response::deny('You do not have permission to view this application');
        }

        if ($application->status !== ApplicationStatus::Pending) {
            return Response::deny('You cannot decline an application that is not pending');
        }

        if ($application->advert->status != AdvertStatus::PendingAllocation) {
            return Response::deny('You cannot decline an application for an advert that is not pending allocation');
        }

        return true;
    }

    public function rate(User $user, Application $application)
    {
        if (! $user->isAdvertiser()) {
            return Response::deny('Only advertisers can rate applicants');
        }

        if (! $user->can('view', $application->advert)) {
            return Response::deny('You do not have permission to view this application');
        }

        if ($application->status !== ApplicationStatus::Accepted) {
            return Response::deny('You cannot rate an application that is not accepted');
        }

        if ($application->advert->ends_at > now()) {
            return Response::deny('You cannot rate an application for an job that has not ended');
        }

        if ($application->rating !== null) {
            return Response::deny('You have already rated this application');
        }

        return true;
    }
}
