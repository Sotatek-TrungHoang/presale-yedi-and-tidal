<?php

namespace App\Filament\Resources\RequiredEvidenceResource\Pages;

use App\Filament\Resources\RequiredEvidenceResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditRequiredEvidence extends EditRecord
{
    protected static string $resource = RequiredEvidenceResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
