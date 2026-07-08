<?php

namespace App\Filament\Widgets;

use App\Enums\AdvertiserComplianceStatus;
use App\Models\Advertiser;
use Filament\Widgets\ChartWidget;

class AdvertiserComplianceChart extends ChartWidget
{
    public function getHeading(): string
    {
        return ___('advertiser').' Compliance';
    }

    protected static ?string $maxHeight = '300px';

    protected static ?int $sort = 10;

    protected function getData(): array
    {

        $compliant = Advertiser::query()->where('compliance_status', AdvertiserComplianceStatus::Compliant)->count();
        $nonCompliant = Advertiser::query()->where('compliance_status', AdvertiserComplianceStatus::NonCompliant)->count();
        $pendingCompliant = Advertiser::query()->where('compliance_status', AdvertiserComplianceStatus::Pending)->count();

        $compliantColor = AdvertiserComplianceStatus::Compliant->getColor()[500];
        $nonCompliantColor = AdvertiserComplianceStatus::NonCompliant->getColor()[500];
        $pendingCompliantColor = AdvertiserComplianceStatus::Pending->getColor()[500];

        return [
            'datasets' => [
                [

                    'data' => [$compliant, $nonCompliant, $pendingCompliant],
                    'backgroundColor' => [
                        "rgb($compliantColor)",
                        "rgb($nonCompliantColor)",
                        "rgb($pendingCompliantColor)",
                    ],
                ],
            ],
            'labels' => ['Compliant',  'Non-compliant', 'Pending'],
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
