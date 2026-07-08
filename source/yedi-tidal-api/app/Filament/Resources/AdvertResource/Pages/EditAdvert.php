<?php

namespace App\Filament\Resources\AdvertResource\Pages;

use App\Filament\Resources\AdvertResource;
use Filament\Resources\Pages\EditRecord;

class EditAdvert extends EditRecord
{
    protected static string $resource = AdvertResource::class;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('view', ['record' => $this->record]);
    }

    public function getRelationManagers(): array
    {
        return [];
    }
}
