<?php

namespace App\Filament\Widgets;

use App\Enums\AdvertStatus;
use App\Enums\ApplicantComplianceStatus;
use App\Enums\ProfileStatus;
use App\Models\Advert;
use App\Models\Advertiser;
use App\Models\Applicant;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class Dashboard extends BaseWidget
{
    protected function getStats(): array
    {
        $advertisers = Advertiser::count();
        $advertisersActive = Advertiser::query()->where('profile_status', ProfileStatus::Active)->count();
        $advertisersPending = Advertiser::query()->where('profile_status', ProfileStatus::Pending)->count();
        $applicants = Applicant::count();
        $applicantsActive = Applicant::query()->where('profile_status', ProfileStatus::Active)->count();
        $applicantsPending = Applicant::query()->where('profile_status', ProfileStatus::Pending)->count();
        $nonCompliantApplicantCount = Applicant::query()->where('compliance_status', ApplicantComplianceStatus::NonCompliant)->count();
        $adverts = Advert::count();
        $advertsComplete = Advert::where('marked_as_completed_at')->count();
        $advertsNotFilled = Advert::where('status', AdvertStatus::NotFilled)->count();

        return [
            Stat::make(___('advertiser').'s', $advertisers)
                ->icon(___('advertiser-icon'))
                ->description("$advertisersActive active | $advertisersPending pending"),
            Stat::make(___('applicant').'s', $applicants)
                ->icon('heroicon-o-user-group')
                ->description("$applicantsActive active | $applicantsPending pending"),
            Stat::make('Non-compliant '.___('applicant').'s', $nonCompliantApplicantCount)
                ->icon('heroicon-o-user-group'),
            Stat::make(___('advert').'s', $adverts)
                ->icon('heroicon-o-newspaper')
                ->description("$advertsComplete completed | $advertsNotFilled not filled"),
        ];
    }
}
