<?php

namespace App\Filament\Widgets;

use App\Enums\ProfileStatus;
use App\Models\Advertiser;
use Filament\Widgets\ChartWidget;

class AdvertiserStatusChart extends ChartWidget
{
    public function getHeading(): string
    {
        return ___('advertiser').' Status';
    }

    protected static ?string $maxHeight = '300px';

    protected static ?int $sort = 10;

    public function getColumnSpan(): int
    {
        return 1;
    }

    protected function getData(): array
    {

        $active = Advertiser::query()->where('profile_status', ProfileStatus::Active)->count();
        $pending = Advertiser::query()->where('profile_status', ProfileStatus::Pending)->count();
        $incomplete = Advertiser::query()->where('profile_status', ProfileStatus::Incomplete)->count();
        $disabled = Advertiser::query()->where('profile_status', ProfileStatus::Disabled)->count();

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
