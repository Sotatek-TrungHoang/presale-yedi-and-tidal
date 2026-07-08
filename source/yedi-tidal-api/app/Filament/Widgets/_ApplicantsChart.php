<?php

namespace App\Filament\Widgets;

use App\Enums\ProfileStatus;
use App\Models\Applicant;
use Filament\Widgets\ChartWidget;

class ApplicantsChart extends ChartWidget
{
    public function getHeading(): string
    {
        return ___('applicants');
    }

    protected static ?string $maxHeight = '300px';

    protected static ?int $sort = 10;

    protected function getData(): array
    {

        $active = Applicant::query()->where('profile_status', ProfileStatus::Active)->count();
        $pending = Applicant::query()->where('profile_status', ProfileStatus::Pending)->count();
        $incomplete = Applicant::query()->where('profile_status', ProfileStatus::Incomplete)->count();
        $disabled = Applicant::query()->where('profile_status', ProfileStatus::Disabled)->count();

        $activeColor = ProfileStatus::Active->getColor()[500];
        $pendingColor = ProfileStatus::Pending->getColor()[500];
        $incompleteColor = ProfileStatus::Incomplete->getColor()[500];
        $disabledColor = ProfileStatus::Disabled->getColor()[500];

        return [
            'datasets' => [
                [

                    'data' => [$active, $pending, $incomplete, $disabled],
                    'backgroundColor' => [
                        "rgb($activeColor)",
                        "rgb($pendingColor)",
                        "rgb($incompleteColor)",
                        "rgb($disabledColor)",
                    ],
                ],
            ],
            'labels' => ['Active',  'Pending', 'Incomplete', 'Disabled'],
            'axisX' => false,

        ];
    }

    protected static ?array $options = [
        'scales' => [
            'x' => [
                'display' => false,
            ],
            'y' => [
                'display' => false,
            ],
        ],
    ];

    protected function getType(): string
    {
        return 'pie';
    }
}
