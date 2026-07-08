<?php

namespace App\Filament\Widgets;

use App\Enums\AdvertStatus;
use App\Models\Advert;
use Brick\Money\Money;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class ExpenditureOverview extends BaseWidget
{
    protected function getStats(): array
    {

        $adverts = Advert::query()
            ->where('marked_as_completed_at', '!=', null)
            ->where('status', AdvertStatus::Filled)
            ->get();

        if ($adverts->isNotEmpty()) {
            $totalIncome = Money::total(...$adverts->map(fn (Advert $advert) => $advert->total_advertiser_pay));
            $totalExpenditure = Money::total(...$adverts->map(fn (Advert $advert) => $advert->applicant_pay));
            $advertiserCharge = Money::total(...$adverts->map(fn (Advert $advert) => $advert->advertiser_charge));
            $applicantCharge = Money::total(...$adverts->map(fn (Advert $advert) => $advert->applicant_charge));
            $profit = Money::total(...$adverts->map(fn (Advert $advert) => $advert->profit));
        } else {
            $totalIncome = Money::zero('GBP');
            $totalExpenditure = Money::zero('GBP');
            $advertiserCharge = Money::zero('GBP');
            $applicantCharge = Money::zero('GBP');
            $profit = Money::zero('GBP');
        }

        return [
            Stat::make('Total Income', $totalIncome->formatTo(app()->getLocale())),
            Stat::make(___('Expenditure'), $totalExpenditure->formatTo(app()->getLocale())),
            Stat::make(___('advertiser').' Charges', $advertiserCharge->formatTo(app()->getLocale())),
            Stat::make(___('applicant').' Charges', $applicantCharge->formatTo(app()->getLocale())),
            Stat::make('Total Profit', $profit->formatTo(app()->getLocale())),
        ];
    }
}
