<?php

namespace App\Filament\Resources\RequiredEvidenceResource\Pages;

use App\Filament\Resources\RequiredEvidenceResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListRequiredEvidence extends ListRecords
{
    protected static string $resource = RequiredEvidenceResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
