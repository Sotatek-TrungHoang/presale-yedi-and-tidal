<?php

namespace App\Filament\Resources\TypeOfWorkResource\Pages;

use App\Filament\Resources\TypeOfWorkResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditTypeOfWork extends EditRecord
{
    protected static string $resource = TypeOfWorkResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
