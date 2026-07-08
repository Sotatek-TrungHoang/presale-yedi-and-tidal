<?php

namespace App\Filament\Resources\TypeOfWorkResource\Pages;

use App\Filament\Resources\TypeOfWorkResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListTypesOfWork extends ListRecords
{
    protected static string $resource = TypeOfWorkResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
