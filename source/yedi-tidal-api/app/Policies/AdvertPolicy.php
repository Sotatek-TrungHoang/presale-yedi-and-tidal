<?php

namespace App\Policies;

use App\Enums\AdvertiserComplianceStatus;
use App\Enums\AdvertStatus;
use App\Enums\ApplicantComplianceStatus;
use App\Enums\ApplicationStatus;
use App\Enums\ProfileStatus;
use App\Enums\UserType;
use App\Models\Advert;
use App\Models\Advertiser;
use App\Models\Applicant;
use App\Models\Application;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class AdvertPolicy
{
    public function viewAny(User $user)
    {

        switch ($user->type) {
            case UserType::Admin:
                return true;
            case UserType::Applicant:
            case UserType::Advertiser:
                /** @var Applicant|Advertiser $userable */
                $userable = $user->userable;
                $profileStatus = $userable->profile_status;

                if ($profileStatus === ProfileStatus::Pending) {
                    return Response::deny('Your account is still pending approval. You cannot view jobs until your account is approved');
                }

                if ($profileStatus === ProfileStatus::Disabled) {
                    return Response::deny('Your account has been disabled. Please contact support for more information');
                }

                return true;
        }

        return false;
    }

    public function view(User $user, Advert $advert)
    {
        switch ($user->type) {
            case UserType::Admin:
                return true;
            case UserType::Advertiser:

                /** @var Advertiser $advertiser */
                $advertiser = $user->userable;

                switch ($advertiser->profile_status) {
                    case ProfileStatus::Pending:
                        return Response::deny('Your account is still pending approval. You cannot view jobs until your account is approved');
                    case ProfileStatus::Disabled:
                        return Response::deny('Your account has been disabled. Please contact support for more information');
                    default:
                        break;
                }

                return $advert->advertiser()->is($advertiser);
            case UserType::Applicant:

                /** @var Applicant $applicant */
                $applicant = $user->userable;
                switch ($applicant->profile_status) {
                    case ProfileStatus::Pending:
                        return Response::deny('Your account is still pending approval. You cannot view jobs until your account is approved');
                    case ProfileStatus::Disabled:
                        return Response::deny('Your account has been disabled. Please contact support for more information');
                    default:
                        break;
                }

                return $advert->status === AdvertStatus::Approved || $advert->applications()->where('applicant_id', $user->userable_id)->exists();
            default:
                return false;
        }
    }

    public function create(User $user)
    {

        if ($user->isAdmin()) {
            return true;
        }

        if (! $user->isAdvertiser()) {
            return Response::deny('Only advertisers can create jobs');
        }

        /** @var Advertiser $advertiser */
        $advertiser = $user->userable;

        switch ($advertiser->profile_status) {
            case ProfileStatus::Pending:
                return Response::deny('Your account is still pending approval. You cannot create jobs until your account is approved');
            case ProfileStatus::Disabled:
                return Response::deny('Your account has been disabled. Please contact support for more information');
            default:
                break;
        }

        if ($advertiser->compliance_status !== AdvertiserComplianceStatus::Compliant) {
            return Response::deny('Your account must be marked as compliant before you can create jobs. Please contact support for more information');
        }

        return true;
    }

    public function apply(User $user, Advert $advert)
    {
        if (! $user->isApplicant()) {
            return Response::deny('Only applicants can apply to jobs');
        }

        if ($advert->status !== AdvertStatus::Approved) {
            return Response::deny('This job can no longer be applied for');
        }

        if ($advert->applications()->where('applicant_id', $user->userable_id)->where('status', '!=', ApplicationStatus::Cancelled)->exists()) {
            return Response::deny('You have already applied for this job');
        }

        if (! $user->can('view', $advert)) {
            return Response::deny('You cannot apply for this job');
        }

        /** @var Applicant $applicant */
        $applicant = $user->userable;

        if ($applicant->compliance_status !== ApplicantComplianceStatus::Compliant) {
            return Response::deny('Your account must be marked as compliant before you can apply for jobs. Please contact support for more information');
        }

        return true;
    }

    public function cancelApplication(User $user, Advert $advert)
    {

        /** @var Application $application */
        $application = $advert->applications()
            ->where('applicant_id', $user->userable_id)
            ->where('status', ApplicationStatus::Pending)
            ->first();

        if (! $application) {
            return Response::deny('You do not have a pending application for this advert');
        }

        if ($application->status !== ApplicationStatus::Pending) {
            return Response::deny('You cannot cancel an application that is not pending');
        }

        return true;
    }

    public function delete(User $user, Advert $advert)
    {
        if ($user->isAdmin()) {
            return true;
        }

        if (! $user->isAdvertiser()) {
            return false;
        }

        if (! $user->can('view', $advert)) {
            return false;
        }

        switch ($advert->status) {
            case AdvertStatus::PendingApproval:
            case AdvertStatus::Rejected:
                return true;

                return true;
            case AdvertStatus::Approved:
                if ($advert->applications()->where('status', '!=', ApplicationStatus::Cancelled)->exists()) {
                    return Response::deny('You cannot delete this job because it has already had one or more applications');
                }

                return true;
            case AdvertStatus::PendingAllocation:
                return Response::deny('You cannot delete this job because it has already had one or more applications');
            case AdvertStatus::Filled:
                return Response::deny('You cannot delete this job because it has already been filled');
            case AdvertStatus::NotFilled:
                return Response::deny('You can no longer delete this job');
        }

        return false;
    }
}
