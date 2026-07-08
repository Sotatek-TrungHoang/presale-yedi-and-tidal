<?php

namespace App\Filament\Resources\AdvertiserResource\Pages;

use App\Enums\AdvertiserComplianceStatus;
use App\Enums\ProfileStatus;
use App\Filament\Resources\AdvertiserResource;
use App\Models\Advertiser;
use Filament\Resources\Pages\CreateRecord;

class CreateAdvertiser extends CreateRecord
{
    protected static string $resource = AdvertiserResource::class;

    protected function handleRecordCreation(array $data): Advertiser
    {

        $advertiser = Advertiser::create([
            ...$data,
            'profile_status' => ProfileStatus::Incomplete,
            'compliance_status' => AdvertiserComplianceStatus::Pending,
        ]);

        return $advertiser;

    }
}
